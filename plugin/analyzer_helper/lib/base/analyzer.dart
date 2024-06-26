import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer_x/base/base.dart';
import 'package:pub_semver/pub_semver.dart';

///Ast分析主入口
class MainAnalyzer {
  ///指定需要分析的Dart文件路径
  final String? filePath;

  ///指定需要分析的Dart语言文本
  final String? fileText;

  ///指定用于获取数据的getter
  final List<Getter> getters;

  MainAnalyzer({
    required this.getters,
    this.filePath,
    this.fileText,
  }) {
    ParseStringResult result;
    try {
      if (fileText != null) {
        result = parseString(
          content: fileText!,
          featureSet: FeatureSet.fromEnableFlags2(
            sdkLanguageVersion: Version(3, 1, 5),
            flags: [],
          ),
        );
      } else if (filePath != null) {
        result = parseFile(
          path: filePath!,
          featureSet: FeatureSet.fromEnableFlags2(
            sdkLanguageVersion: Version(3, 1, 5),
            flags: [],
          ),
        );
      } else {
        assert(false);
        return;
      }
      result.unit.accept(
        FullVisitor(
            patterns: getters.expand((e) => e.patterns).toSet().toList(),
            currentPath: [],
            trigger: (node, step) {
              for (var getter in getters) {
                getter.trigger(node, step);
              }
            }),
      );
      for (var getter in getters) {
        getter.reset();
      }
    } catch (e) {
      analyzerLog('$filePath   $e');
    }
  }
}
