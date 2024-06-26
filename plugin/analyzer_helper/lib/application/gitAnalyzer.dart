import 'dart:io';
import 'package:intl/intl.dart';

import '../path/package.dart';

///分析git版本号[tag]与commit信息
class GitAnalyzer {
  String workingPlace = PackageConfig.projPath;

  static List<DartFile> changeFiles = [];

  List<BranchHistory> histories = [];

  ///{分支号：所在版本号}
  Map<String, String> versions = {};

  static GitAnalyzer? _instance;

  static GitAnalyzer get instance => _instance ??= GitAnalyzer();

  GitAnalyzer() {
    _gitLog();
    _processLog();
  }

  void reset() {
    if (workingPlace != PackageConfig.projPath) {
      changeFiles.clear();
      histories.clear();
      versions.clear();
      workingPlace = PackageConfig.projPath;
    }
  }

  _gitLog() {
    _processLog();
    _processTag();
    _splitVersion();
  }

  _processLog() {
    ProcessResult logs =
        Process.runSync('git', ['log'], workingDirectory: workingPlace);
    List<String> slices = logs.stdout.toString().split('\n');
    BranchHistory? h;
    for (var s in slices) {
      if (s.startsWith('commit ')) {
        if (h != null) {
          histories.add(h);
        }
        h = BranchHistory.instance;
        h.branchId = s.replaceAll('commit ', '');
      } else if (s.startsWith('Date: ')) {
        const String dateFormat = 'E MMM dd HH:mm:ss yyyy Z';
        h?.timeStamp = DateFormat(dateFormat)
            .parse(s.replaceAll('Date: ', '').trim())
            .millisecondsSinceEpoch;
      } else if (s.isNotEmpty) {
        h?.commitMsg += '$s\n';
      }
    }
  }

  _processTag() {
    ProcessResult tags =
        Process.runSync('git', ['tag'], workingDirectory: workingPlace);
    List<String> slices = tags.stdout.toString().split('\n');
    for (var slice in slices) {
      ProcessResult msg = Process.runSync(
        'git',
        ['show', slice],
        workingDirectory: workingPlace,
      );
      for (var m in msg.stdout.toString().split('\n')) {
        if (m.startsWith('commit ')) {
          try {
            String branchId = m.split(' ')[1];
            histories.firstWhere((e) => e.branchId == branchId).tag.add(slice);
          } catch (e) {
            print('unknown commit: $m');
          }
          break;
        }
      }
    }
  }

  _splitVersion() {
    String version = 'latest';
    for (var history in histories) {
      if (history.tag.isNotEmpty) {
        version = history.tag.first;
      }
      versions[history.branchId] = version;
    }
  }

  ///返回所选范围涉及的最大的版本号
  String analyzeVersion(String filePath, int startLine, int endLine) {
    reset();
    return versions[_analyzeBranch(filePath, startLine, endLine)] ?? '0.0.0';
  }

  ///返回所选范围涉及的最新时间
  int analyzeDate(String filePath, int startLine, int endLine) {
    reset();
    String branchId = _analyzeBranch(filePath, startLine, endLine);
    if (branchId.isEmpty) {
      return 0;
    }
    return histories
        .firstWhere((element) => element.branchId == branchId)
        .timeStamp;
  }

  ///返回所选范围涉及的最新分支id
  String _analyzeBranch(String filePath, int startLine, int endLine) {
    ProcessResult logs = Process.runSync(
        'git', ['blame', '-L', '$startLine,$endLine', filePath],
        workingDirectory: workingPlace);
    String branchId = '';
    int timestamp = 0;
    for (String log in logs.stdout.toString().split('\n')) {
      ///log格式为”分支号前8位 (修改人 日期) 代码“
      String shortId = log.split(' ')[0];
      if (shortId.isEmpty) {
        continue;
      }
      BranchHistory h = histories
          .firstWhere((element) => element.branchId.startsWith(shortId));
      if (h.timeStamp > timestamp) {
        timestamp = h.timeStamp;
        branchId = h.branchId;
      }
    }
    return branchId;
  }

  ///分析主项目及插件中发生变化的文件并存放至[changeFiles]
  List<DartFile> analyzeChangeFiles(String workingPlace) {
    reset();
    ProcessResult status = Process.runSync(
      'git',
      ['status', '-s'],
      runInShell: true,
      workingDirectory: workingPlace,
    );
    List<String> paths = [];
    for (String rawPath in status.stdout.toString().split('\n')) {
      paths.add(rawPath.split(' ').last);
    }
    paths.removeWhere((element) => element.isEmpty);
    List<DartFile> files = getDartFiles();
    List<DartFile> tar = [];
    for (DartFile file in files) {
      if (paths
          .where((element) => file.filePath.endsWith(element))
          .isNotEmpty) {
        tar.add(file);
      }
    }
    changeFiles = tar;
    return tar;
  }

  addSomeChangeFiles(bool Function(DartFile) target) {
    for (DartFile file in changeFiles) {
      if (target.call(file)) {
        Process.runSync(
          'git',
          [
            'add',
            file.filePath,
          ],
          workingDirectory: PackageConfig.projPath,
        );
      }
    }
  }

  addNewFiles(List<String> files) {
    for (String file in files) {
      Process.runSync(
        'git',
        [
          'add',
          file,
        ],
        workingDirectory: PackageConfig.projPath,
      );
    }
  }
}

class BranchHistory {
  ///分支时间
  int timeStamp;

  ///分支包含tag
  List<String> tag;

  ///分支的提交信息
  String commitMsg;

  ///分支的id
  String branchId;

  BranchHistory({
    required this.timeStamp,
    required this.tag,
    required this.commitMsg,
    required this.branchId,
  });

  static BranchHistory get instance => BranchHistory(
        timeStamp: 0,
        tag: [],
        commitMsg: '',
        branchId: '',
      );
}
