import 'dart:async';

import 'package:build/build.dart';

import '../../../analyzer_x.dart';
import '../../../base/log.dart';

int _count = 0;

Builder myBuilder(BuilderOptions options) => MyBuilder();

class MyBuilder extends Builder {
  @override
  FutureOr<void> build(BuildStep buildStep) {
    String buildMsg = '';
    if (_count == 0) {
      try {
        AnalyzerX.instance.generate();
        buildMsg = 'Build Success';
      } catch (e) {
        buildMsg = '$e';
      }
      analyzerLog(buildMsg);
    }
    _count++;
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        '.dart': ['.x.dart']
      };
}
