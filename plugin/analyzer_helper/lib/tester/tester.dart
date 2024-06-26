import 'package:analyzer/dart/ast/ast.dart';

import '../base/base.dart';

///获取一个继承[superClass]的构造器超集中[labelName]的[SimpleStringLiteral]取值
class SuperNameBTester extends BackTester<SimpleStringLiteral> {
  final String superClass;

  final String labelName;

  SuperNameBTester({
    required this.superClass,
    required this.labelName,
  });

  @override
  bool accept(node) {
    ClassDeclaration classDeclaration = backNode<ClassDeclaration>(node);
    ExtendsClause? extendsClause = classDeclaration.extendsClause;
    NamedExpression namedExpression = backNode<NamedExpression>(node);
    Label label = namedExpression.name;
    if (extendsClause == null ||
        extendsClause.superclass.name2.toString() != superClass) {
      return false;
    }
    if (label.label.name != labelName) {
      return false;
    }
    return true;
  }

  ///状态机为：
  ///[ClassDeclaration]，[ExtendsClause]=>
  ///[ConstructorDeclaration]=>
  ///[SuperConstructorInvocation]=>
  ///[ArgumentList]=>
  ///[NamedExpression]，[Label]=>
  ///[SimpleStringLiteral]
  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.simpleStringLiteral,
        AnalyzerStep.namedExpression,
        AnalyzerStep.argumentList,
        AnalyzerStep.superConstructorInvocation,
        AnalyzerStep.constructorDeclaration,
        AnalyzerStep.classDeclaration,
      ];
}

///获取构造器中的参数列表
class ConstructorParametersBTester extends BackTester<FormalParameter> {
  @override
  bool accept(node) {
    return true;
  }

  ///以[labelStringValue]为主流程，获取[constructorParameters]的状态机为：
  ///[ConstructorDeclaration]=>
  ///[FormalParameterList]=>
  ///[FieldFormalParameter]
  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.formalParameter,
        AnalyzerStep.formalParameterList,
        AnalyzerStep.constructorDeclaration,
      ];
}

///获取类中的属性列表
class ClassParametersBTester extends BackTester<VariableDeclaration> {
  @override
  bool accept(VariableDeclaration node) {
    return true;
  }

  ///以[labelStringValue]为主流程，获取[classParameters]的状态机为：
  ///[FieldDeclaration]=>
  ///[VariableDeclarationList]=>
  ///[FieldFormal]=>
  ///[VariableDeclaration]
  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.variableDeclaration,
        AnalyzerStep.variableDeclarationList,
        AnalyzerStep.fieldDeclaration,
        AnalyzerStep.classDeclaration,
      ];
}

class MayExternRTester extends SimpleBackTester {
  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.namedType,
        AnalyzerStep.methodInvocation,
        AnalyzerStep.prefixedIdentifier,
      ];
}

///获取声明：类、函数、枚举
class DeclarationBTester extends SimpleBackTester {
  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.classDeclaration,
        AnalyzerStep.functionDeclaration,
        AnalyzerStep.enumDeclaration,
      ];
}

///获取库/文件引用信息
class DirectiveBTester extends SimpleBackTester {
  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.importDirective,
        AnalyzerStep.libraryDirective,
        AnalyzerStep.partDirective,
        AnalyzerStep.partOfDirective,
        AnalyzerStep.exportDirective,
      ];
}

///获取所有含有[BlockFunctionBody]的[MethodDeclaration]与[FunctionDeclaration]
class MethodBTester extends SimpleBackTester {
  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.methodDeclaration,
        AnalyzerStep.functionDeclaration,
      ];

  @override
  bool inPath(node) {
    if (isValid(node)) {
      return super.inPath(node);
    }
    return false;
  }

  bool isValid(AstNode node) {
    if (AnalyzerStep.methodDeclaration.typeChecker(node)) {
      ///不记录在方法定义里再定义方法的写法
      try {
        backNode<MethodDeclaration>(node.parent);
        return false;
      } catch (e) {}

      try {
        backNode<FunctionDeclaration>(node.parent);
        return false;
      } catch (e) {}

      return (node as MethodDeclaration).body is BlockFunctionBody;
    }
    if (AnalyzerStep.functionDeclaration.typeChecker(node)) {
      ///不记录在方法定义里再定义方法的写法
      try {
        backNode<MethodDeclaration>(node.parent);
        return false;
      } catch (e) {}

      try {
        backNode<FunctionDeclaration>(node.parent);
        return false;
      } catch (e) {}
      return (node as FunctionDeclaration).functionExpression.body
          is BlockFunctionBody;
    }
    return true;
  }
}

///获取[class]上的注解信息
class ClassMetaBTester extends SimpleBackTester {
  final List<String> classMetaNames;

  ClassMetaBTester({
    required this.classMetaNames,
  });

  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.classDeclaration,
      ];

  @override
  bool accept(node) {
    ClassDeclaration classDeclaration = backNode<ClassDeclaration>(node);
    NodeList<Annotation> metas = classDeclaration.metadata;
    for (Annotation meta in metas) {
      if (classMetaNames.contains(meta.name.name)) {
        return true;
      }
    }
    return false;
  }
}

///获取[MethodDeclaration]信息
class MethodDeclarationBTester extends SimpleBackTester {
  @override
  List<AnalyzerStep> get path => [
        AnalyzerStep.methodDeclaration,
      ];

  @override
  bool inPath(node) {
    if (isValid(node)) {
      return super.inPath(node);
    }
    return false;
  }

  bool isValid(AstNode node) {
    if (AnalyzerStep.methodDeclaration.typeChecker(node)) {
      ///不记录在方法定义里再定义方法的写法
      try {
        backNode<MethodDeclaration>(node.parent);
        return false;
      } catch (e) {}

      try {
        backNode<FunctionDeclaration>(node.parent);
        return false;
      } catch (e) {}

      return true;
    }
    return true;
  }
}
