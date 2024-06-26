import 'dart:async';
import 'dart:io';
import 'package:analyzer_x/analyzer_x.dart';
import 'package:analyzer_x/application/code_gen/auto_build/buildMinimize.dart';
import 'package:analyzer_x/application/gitAnalyzer.dart';
import 'package:analyzer_x/base/log.dart';
import 'package:analyzer_x/path/package.dart';

///在主项目执行dart run analyzer_x命令
Future<void> main(List<String> args) async {
  ///生成参数校验文件
  AnalyzerX.instance.generate();
  ///增量build方法，减少数据模型build时间,可能还存在问题，待完善
  // List<DartFile> restoreFiles = BuildMinimize.instance.execute();
  analyzerLog('Build Start');
  bool isEnd = false;
  int time = 1;
  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (isEnd) {
      timer.cancel();
    } else {
      analyzerLog('Build Start $time');
      time++;
    }
  });
  await Process.run(
    'dart',
    [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs'
    ],
    runInShell: true,
    workingDirectory: PackageConfig.projPath,
  ).then((value) {
    isEnd = true;
    analyzerLog(value.stdout.toString());
    // List<String> rollBackTar = value.stdout
    //     .toString()
    //     .split('\n')
    //     .where(
    //         (element) => element.startsWith('[SEVERE] json_serializable on '))
    //     .toList();
    // if (rollBackTar.isNotEmpty) {
    //   restoreFiles = restoreFiles
    //       .where(
    //         (element) => rollBackTar.first.contains(element.libName),
    //       )
    //       .toList();
    // }
  });

  // for (DartFile file in restoreFiles) {
  //   analyzerLog(file.filePath);
  //   Process.runSync(
  //     'git',
  //     [
  //       'restore',
  //       file.filePath.replaceAll('.dart', '.freezed.dart'),
  //     ],
  //     runInShell: true,
  //     workingDirectory: PackageConfig.projPath,
  //   );
  // }
  GitAnalyzer.instance.analyzeChangeFiles(PackageConfig.projPath);
  GitAnalyzer.instance.addSomeChangeFiles((p0) =>
      p0.filePath.endsWith('.g.dart') || p0.filePath.endsWith('.freezed.dart'));
  analyzerLog('Git Add End');
  // File buildFile =
  //     File('${PackageConfig.projPath}${Platform.pathSeparator}build.yaml');
  // buildFile.deleteSync();
}
