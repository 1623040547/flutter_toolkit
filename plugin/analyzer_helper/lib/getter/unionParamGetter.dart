import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_x/base/base.dart';

import '../tester/tester.dart';

class UnionParamGetter extends Getter {
  List<UnionParamUnit> units = [];

  @override
  void reset() {
    if (testerAccept<SuperNameBTester>()) {
      units.add(
        UnionParamUnit(
          className: className,
          paramName: paramName,
          children: methodInvocations,
          paramDesc: paramDesc,
          paramType: paramType,
          paramStart: paramStart,
          paramEnd: paramEnd,
        ),
      );
    }
  }

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

  String get className => tester<SuperNameBTester>()
      .backFirstNode<ClassDeclaration>()
      .name
      .toString();

  int get paramStart =>
      tester<SuperNameBTester>().backFirstNode<ClassDeclaration>().offset;

  int get paramEnd =>
      tester<SuperNameBTester>().backFirstNode<ClassDeclaration>().end;

  String get paramName => tester<SuperNameBTester>().firstNode.value;

  List<String> get methodInvocations => tester<MayExternRTester>()
      .tList<MethodInvocation>()
      .map((node) => node.methodName.toString())
      .toList();

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

  @override
  List<BackTester> testers = [
    SuperNameBTester(
      superClass: 'UnionParam',
      labelName: 'name',
    ),
    MayExternRTester(),
  ];

  static bool mayTarget(String fileString) {
    return fileString.contains('super') &&
        fileString.contains('UnionParam') &&
        fileString.contains('name');
  }
}

class UnionParamUnit {
  final String className;
  final String paramName;
  final String paramDesc;
  final String paramType;
  final int paramStart;
  final int paramEnd;

  ///可能是BaseParam Class的Method Invocation
  final List<String> children;

  void filter(Map<String, String> patterns) {
    for (var child in children.toList()) {
      children.remove(child);
      if (patterns.containsKey(child)) {
        children.add(patterns[child]!);
      }
    }
  }

  UnionParamUnit({
    required this.className,
    required this.paramName,
    required this.paramDesc,
    required this.children,
    required this.paramType,
    required this.paramStart,
    required this.paramEnd,
  });
}
