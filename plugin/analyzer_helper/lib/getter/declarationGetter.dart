import 'package:analyzer/dart/ast/ast.dart';

import '../base/base.dart';
import '../tester/tester.dart';

///获取一个dart文件中的[Class]||[Enum]||[Function] 声明
class DeclarationGetter extends Getter {
  DeclarationUnit unit = DeclarationUnit();

  @override
  void reset() {
    unit.dClass.addAll(getClasses());
    unit.dFunction.addAll(getFunctions());
    unit.dEnum.addAll(getEnums());
  }

  @override
  List<BackTester<AstNode>> testers = [
    DeclarationBTester(),
  ];

  List<String> getClasses() => tester<DeclarationBTester>()
      .tList<ClassDeclaration>()
      .map((e) => e.name.toString())
      .toList();

  List<String> getFunctions() => tester<DeclarationBTester>()
      .tList<FunctionDeclaration>()
      .map((e) => e.name.toString())
      .toList();

  List<String> getEnums() => tester<DeclarationBTester>()
      .tList<EnumDeclaration>()
      .map((e) => e.name.toString())
      .toList();
}

class DeclarationUnit {
  List<String> dClass = [];
  List<String> dFunction = [];
  List<String> dEnum = [];
}
