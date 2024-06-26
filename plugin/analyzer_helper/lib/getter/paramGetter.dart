import 'package:analyzer/dart/ast/ast.dart';

import '../base/base.dart';
import '../path/package.dart';
import '../tester/tester.dart';

///获取一个Class类型的数据信息，该类需满足一下条件
///(1)继承自类[BaseParam]
///(2)构造器中的super中应包含[name]字段
///(3)[name]字段类型为简单字符串
class ParamGetter extends Getter {
  List<ParamUnit> units = [];

  @override
  void reset() {
    if (testerAccept<SuperNameBTester>()) {
      units.add(
        ParamUnit(
          className: className,
          paramName: paramName,
          paramDesc: paramDesc,
          paramType: paramType,
          paramStart: paramStart,
          paramEnd: paramEnd,

          ///todo:获取参数检查类型，但因为现在类型检查尚未标准化，暂时跳过
          paramCheck: '',
        ),
      );
    }
  }

  String get className => tester<SuperNameBTester>()
      .backFirstNode<ClassDeclaration>()
      .name
      .toString();

  int get paramStart =>
      tester<SuperNameBTester>().backFirstNode<ClassDeclaration>().offset;

  int get paramEnd =>
      tester<SuperNameBTester>().backFirstNode<ClassDeclaration>().end;

  String get paramDesc {
    for (var meta in tester<SuperNameBTester>()
        .backFirstNode<ClassDeclaration>()
        .metadata) {
      if (meta.name.name == "ParamDesc") {
        String desc = meta.arguments!.arguments[0].toString();
        return desc.replaceAll('\'', '').replaceAll('"', '');
      }
    }
    return "";
  }

  String get paramType {
    for (var param in tester<SuperNameBTester>()
        .backFirstNode<ConstructorDeclaration>()
        .parameters
        .parameters) {
      if (param is SimpleFormalParameter) {
        return param.type?.toString() ?? '';
      }
    }
    return "";
  }

  String get paramName => tester<SuperNameBTester>().firstNode.value;

  @override
  List<BackTester> testers = [
    SuperNameBTester(
      superClass: 'BaseParam',
      labelName: 'name',
    ),
  ];

  static bool mayTarget(String fileString) {
    return fileString.contains('super') &&
        fileString.contains('BaseParam') &&
        fileString.contains('name');
  }
}

class ParamUnit {
  final String className;
  final String paramName;
  final String paramDesc;
  final String paramType;
  final String paramCheck;
  final int paramStart;
  final int paramEnd;

  ParamUnit({
    required this.className,
    required this.paramName,
    required this.paramDesc,
    required this.paramType,
    required this.paramCheck,
    required this.paramStart,
    required this.paramEnd,
  });
}

Map<DartFile, List<ParamUnit>> parseParam() {
  List<DartFile> inputFilePath = getDartFiles(isTarget: ParamGetter.mayTarget);
  Map<DartFile, List<ParamUnit>> unitsMap = {};

  for (var file in inputFilePath) {
    var getter = ParamGetter();
    MainAnalyzer(getters: [getter], filePath: file.filePath);
    unitsMap[file] = getter.units;
  }
  return unitsMap;
}
