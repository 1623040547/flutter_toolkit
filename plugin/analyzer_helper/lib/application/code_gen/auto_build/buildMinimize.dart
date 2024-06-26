import 'dart:io';

import 'package:analyzer_x/application/gitAnalyzer.dart';
import 'package:analyzer_x/base/analyzer.dart';

import '../../../base/log.dart';
import '../../../getter/directiveGetter.dart';
import '../../../path/package.dart';

///通过git status 命令获修改文件在此基础之上进行设计范围最小的dart build,
///减少dart build执行时间
class BuildMinimize {
  static BuildMinimize? _instance;

  static BuildMinimize get instance {
    return _instance ??= BuildMinimize();
  }

  List<DartFile> execute() {
    analyzerLog('BuildMinimize Start');
    List<DartFile> files =
        GitAnalyzer.instance.analyzeChangeFiles(PackageConfig.projPath);
    List<String> buildSource = [
      '- pubspec.*',
      '- \$package\$',
    ];
    List<String> buildTarget = [];
    List<DartFile> buildSourceDart = [];
    for (DartFile file in files) {
      String fileStr = File(file.filePath).readAsStringSync();
      bool isTarget =
          fileStr.contains('@unfreezed') || fileStr.contains('@freezed');
      if (isTarget) {
        buildTarget.add('- ${file.libName}');
        try {
          File(file.filePath.replaceAll('.dart', '.g.dart')).deleteSync();
          File(file.filePath.replaceAll('.dart', '.freezed.dart')).deleteSync();
        } catch (e) {}
        var getter = DirectiveGetter();
        MainAnalyzer(
          getters: [getter],
          fileText: fileStr,
        );
        List<DartFile> projFiles = getDartFiles();
        for (String importStr in getter.unit.dImport) {
          String fileName = Uri.tryParse(importStr)?.pathSegments.last ?? '';
          if (fileName.isNotEmpty) {
            List<DartFile> f = projFiles
                .where((element) =>
                    element.fileNameWithFix == fileName &&
                    element.package.isMainProj)
                .toList();
            buildSourceDart.addAll(f);
            buildSource.addAll(f.map((e) => '- ${e.libName}'));
          }
        }
      }
    }

    String buildYaml = """
targets:
  \$default:
    sources:
${buildTarget.map((e) => '      $e').join('\n')}
${buildSource.map((e) => '      $e').join('\n')}
    builders:
      spiritrue:
        generate_for:
${buildTarget.map((e) => '          $e').join('\n')}
    """;

    File buildFile =
        File('${PackageConfig.projPath}${Platform.pathSeparator}build.yaml');
    if (!buildFile.existsSync()) {
      buildFile.createSync();
    }
    buildFile.writeAsStringSync(buildYaml);
    analyzerLog('BuildMinimize End');
    return buildSourceDart
        .where((e) => files.where((e2) => e2.filePath == e.filePath).isEmpty)
        .toList();
  }
}
