import 'dart:io';
import 'package:analyzer_x/base/base.dart';

import '../base/analyzer.dart';
import '../getter/methodGetter.dart';
import '../path/package.dart';

///定义一个用于数据收集的注解，收集可转换为json类型的类集合，
///自动生成：判断每一个函数的入参类型是否包含在类集合中，如果包含，
///则有权将其数据选择性记录
class DataCollection {
  final String name;

  const DataCollection(this.name);
}

const jsonCollection = DataCollection("toJson");

class ProgramTracer {
  ///假设有过多的patterns（比如超过10000，目前my_healer主项目为2027个pattern），就需要考虑如何快速地匹配pattern，
  ///通过函数名映射id，在实际构建程序流时，以函数名为准，函数名相较id不容易变化
  ///但如果还认为函数名是容易变化的，则可以尝试加入注解，注解保留原函数名参数，这样就可以随意更换原函数名
  ///同时，因为有注解的存在，当原函数名更新时，以注解名去寻找id，将新函数名与id映射，注解名再更改为新函数名
  static Set<int> patterns = {
    291, //开始购买
    622, //showTipsToast,购买失败为291，622
    501, //refreshData，购买成功为291，501
  };
  static List<int> paths = [];
  static List<int> time = [];

  static int initialTime = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  ).millisecondsSinceEpoch;

  static int get timeDiff {
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    return nowTime - initialTime;
  }

  static String importName =
      "import 'package:analyzer_x/application/programTracer.dart';\n";

  static String dictPath = "";

  static String logPath = "";

  static String stepPath = "";

  static String fileName = "programTracer.dart";

  ///可以采用类似关键帧的思想，指定一运行便需要保存的打点
  static trace(int id) {
    if (patterns.contains(id)) {
      paths.add(id);
      paths.add(timeDiff);
      try {
        if (paths.length >= 20000) {
          var f = File(logPath);
          if (!f.existsSync()) {
            f.create();
          }
          File(logPath).writeAsString('${paths.sublist(0, 20001).join('\n')}\n',
              mode: FileMode.writeOnlyAppend);
          paths.removeRange(0, 20001);
        }
      } catch (e) {
        analyzerLog('trace conflict');
      }
    }
  }

  static inject() {
    Map<DartFile, MethodGetter> getters = _genDict();
    for (DartFile file in getters.keys) {
      if (getters[file]!.units.isNotEmpty) {
        String newText = _traceInject(
            File(file.filePath).readAsStringSync(), getters[file]!.units);
        newText = _importInject(newText);
        var f = File(file.filePath);
        f.writeAsString(newText);
      }
    }
  }

  static _importInject(String text) {
    return importName + text;
  }

  static _traceInject(String text, List<MethodUnit> units) {
    for (MethodUnit unit in units.reversed) {
      text = text.substring(0, unit.blockStart) +
          text
              .substring(unit.blockStart, unit.end)
              .replaceFirst('{', "{ ProgramTracer.trace(${unit.id});") +
          text.substring(unit.end);
    }
    return text;
  }

  static reject() {
    Map<DartFile, MethodGetter> getters = _genDict();
    for (DartFile file in getters.keys) {
      if (getters[file]!.units.isNotEmpty) {
        String newText = _traceReject(
            File(file.filePath).readAsStringSync(), getters[file]!.units);
        newText = _importReject(newText);
        var f = File(file.filePath);
        f.writeAsString(newText);
      }
    }
  }

  static _traceReject(String text, List<MethodUnit> units) {
    var reg = RegExp(r'ProgramTracer.trace\([^)]*\);');
    return text.replaceAll(reg, '');
  }

  static _importReject(String text) {
    return text.replaceAll(importName, '');
  }

  static _genDict() {
    Map<DartFile, MethodGetter> getters = {};
    int count = 0;
    String text = "";
    File dict = File(
      dictPath,
    );
    for (DartFile file in getDartFiles()) {
      ///过滤
      if (file.importName.contains('.g.dart') ||
          file.importName.contains('.freezed.dart') ||
          file.importName.contains(fileName) ||
          !file.package.isMainProj) {
        continue;
      }
      var getter = MethodGetter();
      MainAnalyzer(
        getters: [getter],
        filePath: file.filePath,
      );
      getters[file] = getter;
      for (var unit in getter.units) {
        if (unit.className == "null") {
          unit.className = ":${file.importName}";
        }
        text += "$count,${unit.className},${unit.method}\n";
        unit.id = count;
        count += 1;
      }
    }
    dict.create();
    dict.writeAsString(text);
    return getters;
  }

  static createProgramStream() {
    List<String> lines = File(dictPath).readAsLinesSync();
    Map<int, String> dict = {};
    for (String line in lines) {
      var elements = line.split(',');
      dict[int.parse(elements[0])] = "${elements[1]}.${elements[2]}";
    }
    List<String> steps = File(logPath).readAsLinesSync();
    String userSteps = "";

    var f = File(stepPath);
    f.create();
    f.openWrite(mode: FileMode.writeOnlyAppend);

    int turn = 0;
    while (steps.isNotEmpty) {
      List<String> batchSize = [];
      try {
        batchSize = steps.sublist(0, 20000);
        steps.removeRange(0, 20000);
      } catch (e) {
        batchSize = steps.sublist(0);
        steps.clear();
      }
      for (var data in batchSize) {
        int userStep = int.parse(data);
        userSteps += '${dict[userStep]}\n';
      }
      f.writeAsStringSync(userSteps, mode: FileMode.writeOnlyAppend);
      userSteps = "";
      analyzerLog(turn);
      turn++;
    }
  }
}
