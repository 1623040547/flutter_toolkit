import 'package:analyzer/dart/ast/ast.dart';
import '../base/base.dart';
import '../path/package.dart';
import '../tester/tester.dart';

///获取一个Class类型的数据信息，该类需满足一下条件
///(1)继承自类[BaseEvent]
///(2)构造器中的super中应包含[name]字段
///(3)[name]字段类型为简单字符串
class EventGetter extends Getter {
  List<EventUnit> units = [];

  @override
  void reset() {
    if (testerAccept<SuperNameBTester>()) {
      units.add(EventUnit(
        className: className,
        eventName: eventName,
        eventDesc: eventDescMeta,
        eventPlate: eventPlateMeta,
        classParameters: classParameters,
        classParameterQuestions: classParameterQuestions,
        constructorParameters: constructorParameters,
        classParametersMeta: classParametersMeta,
        panels: panels,
        eventStart: eventStart,
        eventEnd: eventEnd,
      ));
    }
  }

  @override
  List<BackTester> testers = [
    SuperNameBTester(
      superClass: 'BaseEvent',
      labelName: 'name',
    ),
    ClassParametersBTester(),
    ConstructorParametersBTester(),
    MayExternRTester(),
  ];

  String get className => tester<SuperNameBTester>()
      .backFirstNode<ClassDeclaration>()
      .name
      .toString();

  int get eventStart =>
      tester<SuperNameBTester>().backFirstNode<ClassDeclaration>().offset;

  int get eventEnd =>
      tester<SuperNameBTester>().backFirstNode<ClassDeclaration>().end;

  ///获取event class上的desc注释
  String get eventDescMeta {
    for (var meta in tester<SuperNameBTester>()
        .backFirstNode<ClassDeclaration>()
        .metadata) {
      if (meta.name.name == "EventDesc") {
        String desc = meta.arguments!.arguments[0].toString();
        return desc.replaceAll('\'', '').replaceAll('"', '');
      }
    }
    return "";
  }

  ///获取event class上的plate注释
  String get eventPlateMeta {
    for (var meta in tester<SuperNameBTester>()
        .backFirstNode<ClassDeclaration>()
        .metadata) {
      if (meta.name.name == "EventDesc") {
        String desc = meta.arguments!.arguments[1].toString();
        return desc.replaceAll('\'', '').replaceAll('"', '');
      }
    }
    return "";
  }

  String get eventName => tester<SuperNameBTester>().firstNode.value;

  Map<String, String> get classParameters => Map.fromIterables(
        tester<ClassParametersBTester>()
            .firstList
            .map((e) => e.name.toString()),
        tester<ClassParametersBTester>()
            .backFirstList<VariableDeclarationList>()
            .map((e) => e.type.toString().replaceAll('?', '')),
      );

  Map<String, String> get classParametersMeta => Map.fromIterables(
        tester<ClassParametersBTester>()
            .firstList
            .map((e) => e.name.toString()),
        tester<ClassParametersBTester>()
            .backFirstList<FieldDeclaration>()
            .map((e) {
          for (var meta in e.metadata) {
            if (meta.name.name == "ParamDesc") {
              return meta.arguments!.arguments[0].toString();
            }
          }
          return "";
        }),
      );

  Map<String, bool> get classParameterQuestions => Map.fromIterables(
        tester<ClassParametersBTester>()
            .firstList
            .map((e) => e.name.toString()),
        tester<ClassParametersBTester>()
            .backFirstList<VariableDeclarationList>()
            .map((e) => e.type?.question != null),
      );

  Map<String, bool> get constructorParameters => Map.fromIterables(
        tester<ConstructorParametersBTester>()
            .firstList
            .map((e) => e.name.toString()),
        tester<ConstructorParametersBTester>()
            .firstList
            .map((e) => e.isRequiredNamed || e.isNamed),
      );

  List<String> get panels {
    List<String> p = [];
    for (var fixed in tester<MayExternRTester>().tList<PrefixedIdentifier>()) {
      if (fixed.prefix.name == "EventPanel") {
        p.add(fixed.identifier.name);
      }
    }
    return p;
  }

  static bool mayTarget(String fileString) {
    return fileString.contains('super') &&
        fileString.contains('BaseEvent') &&
        fileString.contains('name');
  }
}

class EventUnit {
  final String className;
  final String eventName;
  final String eventDesc;
  final String eventPlate;

  ///事件函数开始偏移
  final int eventStart;

  ///事件函数结束偏移
  final int eventEnd;

  ///构造器形参列表，{形参变量名：形参类型}
  final Map<String, String> classParameters;

  ///获取给各个参数进行的注解
  final Map<String, String> classParametersMeta;

  ///记录参数是否可以为空,{形参变量名: 是否可为空}
  final Map<String, bool> classParameterQuestions;

  ///构造器形参列表，{形参变量名:是否必须},
  ///bool类型代表是否[isRequiredNamed]
  final Map<String, bool> constructorParameters;

  ///上传的打点平台
  final List<String> panels;

  EventUnit({
    required this.className,
    required this.eventDesc,
    required this.eventPlate,
    required this.eventName,
    required this.classParameters,
    required this.classParameterQuestions,
    required this.constructorParameters,
    required this.classParametersMeta,
    required this.panels,
    required this.eventStart,
    required this.eventEnd,
  });
}

Map<DartFile, List<EventUnit>> parseEvent() {
  List<DartFile> inputFilePath = getDartFiles(isTarget: EventGetter.mayTarget);
  Map<DartFile, List<EventUnit>> unitsMap = {};

  for (var file in inputFilePath) {
    var getter = EventGetter();
    MainAnalyzer(getters: [getter], filePath: file.filePath);
    unitsMap[file] = getter.units;
  }
  return unitsMap;
}
