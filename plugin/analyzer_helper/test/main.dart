import 'dart:async';
import 'package:analyzer_x/application/code_gen/auto_build/buildMinimize.dart';
import 'package:analyzer_x/application/eventToJson.dart';
import 'package:analyzer_x/application/gitAnalyzer.dart';
import 'package:analyzer_x/application/image_handler/imageHandler.dart';
import 'package:analyzer_x/application/jsonToFreeze.dart';
import 'package:analyzer_x/base/analyzer.dart';
import 'package:analyzer_x/getter/imageClassGetter.dart';
import 'package:analyzer_x/getter/jsonSerializableGetter.dart';

Future<void> main() async {
  //代码自动生成
  //AnalyzerX.instance.generate();
  //程序打桩插入
  //ProgramTracer.inject();
  //程序打桩取出
  // ProgramTracer.reject();
  //ProgramTracer.createProgramStream();
  // ParamGetter getter = ParamGetter();
  // var files = getDartFiles();
  // for (var file in files) {
  //   MainAnalyzer(getters: [getter], filePath: file.filePath);
  // }
  //  EventToJson.instance.analyze();
  // EventToJson.instance.toJson();
  // GitAnalyzer.instance.gitLog();
  // var files = getDartFiles();
  // Map<String, List<JsonSerializableUnit>> map = {};
  // for (var file in files) {
  //   if (file.package.isMainProj &&
  //       !file.filePath.contains('.g.dart') &&
  //       !file.filePath.contains('.freezed.dart')) {
  //     JsonSerializableGetter getter = JsonSerializableGetter();
  //     MainAnalyzer(
  //       getters: [
  //         getter,
  //       ],
  //       filePath: file.filePath,
  //     );
  //     if (getter.units.isNotEmpty) {
  //       map[file.filePath] = getter.units;
  //     }
  //   }
  // }
  // print(map);
  // JsonToFreeze.toFreeze();
  // BuildMinimize.instance.execute();
  // for (var file in getDartFiles()) {
  //   MainAnalyzer(
  //     getters: [
  //       ImageClassGetter(
  //         className: 'ImageNames',
  //       )
  //     ],
  //     filePath: file.filePath,
  //   );
  // }

 await ImageHandler('/Users/qingdu/Desktop/testImage').start();
}
