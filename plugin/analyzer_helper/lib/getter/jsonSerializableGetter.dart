import 'package:analyzer/src/dart/ast/ast.dart';

import 'package:analyzer_x/base/back_tester.dart';
import 'package:analyzer_x/base/base.dart';

import '../base/getter.dart';
import '../tester/tester.dart';

class JsonSerializableGetter extends Getter {
  List<JsonSerializableUnit> units = [];
  int importEnd = 0;

  @override
  List<BackTester<AstNode>> testers = [
    ClassParametersBTester(),
    ConstructorParametersBTester(),
    ClassMetaBTester(
      classMetaNames: ['JsonSerializable'],
    ),
    DirectiveBTester(),
    MethodDeclarationBTester(),
  ];

  @override
  void reset() {
    if (testerAccept<ClassMetaBTester>()) {
      analyzerLog(className);
      units.add(
        JsonSerializableUnit(
          className: className,
          conParams: conParams,
          claParams: claParams,
          metaStart: metaStart,
          metaEnd: metaEnd,
          conStart: conStart,
          conEnd: conEnd,
          claStart: claStart,
          claEnd: claEnd,
          toJsonStart: toJsonStart,
          toJsonEnd: toJsonEnd,
        ),
      );
    }
    importEnd = _partEnd ?? importEnd;
  }

  String get className =>
      tester<ClassMetaBTester>().tNode<ClassDeclaration>()!.name.toString();

  int get toJsonStart =>
      tester<MethodDeclarationBTester>()
          .tList<MethodDeclaration>()
          .where((element) => element.name.toString() == 'toJson')
          .firstOrNull
          ?.offset ??
      0;

  int get toJsonEnd =>
      tester<MethodDeclarationBTester>()
          .tList<MethodDeclaration>()
          .where((element) => element.name.toString() == 'toJson')
          .firstOrNull
          ?.end ??
      0;

  int get claStart =>
      tester<ClassMetaBTester>().tNode<ClassDeclaration>()!.name.offset;

  int get claEnd =>
      tester<ClassMetaBTester>().tNode<ClassDeclaration>()!.name.end;

  int get metaStart => tester<ClassMetaBTester>()
      .tNode<ClassDeclaration>()!
      .metadata
      .beginToken!
      .offset;

  int get metaEnd => tester<ClassMetaBTester>()
      .tNode<ClassDeclaration>()!
      .metadata
      .endToken!
      .offset;

  int get conStart => tester<ConstructorParametersBTester>()
      .backNode<ConstructorDeclaration>(
          tester<ConstructorParametersBTester>().firstNode)
      .offset;

  int get conEnd => tester<ConstructorParametersBTester>()
      .backNode<ConstructorDeclaration>(
          tester<ConstructorParametersBTester>().firstNode)
      .end;

  int? get _partEnd =>
      tester<DirectiveBTester>().tList<ImportDirective>().lastOrNull?.end;

  List<_ConstructorParam> get conParams {
    if (className == 'IapItem') {
      tester<ConstructorParametersBTester>().firstNode;
      print('');
    }
    return tester<ConstructorParametersBTester>()
        .firstList
        .map(
          (element) => _ConstructorParam(
            paramName: element.name.toString(),
            start: element.offset,
            end: element.end,
            isOptional: element.isOptional,
            value: (element is DefaultFormalParameter)
                ? element.defaultValue?.toString()
                : null,
            isNamed: element.isNamed,
          ),
        )
        .toList();
  }

  List<_ClassParam> get claParams {
    if (className == 'UserInfoModel') {
      print('');
    }
    List<_ClassParam> params = [];
    for (var node in tester<ClassParametersBTester>().firstList) {
      FieldDeclaration dec =
          tester<ClassParametersBTester>().backNode<FieldDeclaration>(node);
      VariableDeclarationList variable = tester<ClassParametersBTester>()
          .backNode<VariableDeclarationList>(node);
      NamedExpression? expression;
      String? defaultValue;
      String? fromJson;
      String? name;
      List<Expression> mayExpressions = dec.metadata
              .where((element) => element.name.name == 'JsonKey')
              .firstOrNull
              ?.arguments
              ?.arguments
              .toList() ??
          [];
      for (var mayExpression in mayExpressions) {
        if (mayExpression is NamedExpressionImpl) {
          expression = mayExpression;
          if (expression.name.label.name == 'defaultValue') {
            defaultValue = expression.expression.toString();
          } else if (expression.name.label.name == 'fromJson') {
            fromJson = expression.expression.toString();
          } else if (expression.name.label.name == 'name') {
            name = expression.expression.toString();
          } else {
            analyzerLog(
                'Unhandled JsonKey Param: ${expression.expression.toString()}');
            assert(false);
          }
        }
      }

      params.add(
        _ClassParam(
            paramName: node.name.toString(),
            start: dec.offset,
            end: dec.end,
            isOptional: variable.type.toString().contains('?'),
            paramType: variable.type.toString(),
            jsonKeyName: name,
            defaultValue: defaultValue,
            fromJson: fromJson,
            isStatic: dec.isStatic,
            isConst: variable.isConst,
            preEnd: dec.beginToken.previous?.end ?? 0,
            ducComment: dec.documentationComment?.beginToken.toString()),
      );
    }
    return params;
  }
}

class JsonSerializableUnit {
  String className;
  List<_ConstructorParam> conParams;
  List<_ClassParam> claParams;

  ///注解偏移
  int metaStart;
  int metaEnd;

  ///构造器偏移
  int conStart;
  int conEnd;

  ///类名偏移
  int claStart;
  int claEnd;

  ///[toJson]函数偏移
  int toJsonStart;
  int toJsonEnd;

  JsonSerializableUnit({
    required this.className,
    required this.conParams,
    required this.claParams,
    required this.metaStart,
    required this.metaEnd,
    required this.conStart,
    required this.conEnd,
    required this.claStart,
    required this.claEnd,
    required this.toJsonStart,
    required this.toJsonEnd,
  });
}

class _ConstructorParam {
  String paramName;
  String? value;
  bool isOptional;
  bool isNamed;
  int start;
  int end;

  _ConstructorParam(
      {required this.paramName,
      required this.start,
      required this.end,
      required this.isOptional,
      required this.isNamed,
      this.value});
}

class _ClassParam {
  String? defaultValue;
  String? fromJson;
  String? jsonKeyName;
  String paramName;
  String paramType;
  bool isOptional;
  bool isStatic;
  bool isConst;
  int start;
  int end;
  int preEnd;
  String? ducComment;

  _ClassParam({
    required this.paramName,
    required this.start,
    required this.end,
    required this.isOptional,
    required this.paramType,
    required this.isStatic,
    required this.isConst,
    required this.preEnd,
    this.defaultValue,
    this.fromJson,
    this.jsonKeyName,
    this.ducComment,
  });
}
