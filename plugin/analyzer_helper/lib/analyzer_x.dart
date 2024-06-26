import 'application/code_gen/eventFactoryGen.dart';
import 'application/code_gen/paramFactoryGen.dart';

class AnalyzerX {
  static AnalyzerX? _instance;

  static AnalyzerX get instance {
    return _instance ??= AnalyzerX();
  }

  ///调用此方法，进行文件生成
  void generate() {
    EventFactoryGen().execute();
    ParamFactoryGen().execute();
  }
}
