import 'package:analyzer/src/dart/ast/ast.dart';

import 'package:analyzer_x/base/back_tester.dart';
import 'package:analyzer_x/base/base.dart';

import '../base/getter.dart';
import '../tester/tester.dart';

class ImageClassGetter extends Getter {
  String className;

  ///判断class中是否具有每个参数
  String? variableName;
  String? variableValue;

  bool matchClassName = false;

  bool matchVariableName = false;

  bool matchVariableValue = false;

  ///class偏移,从开始到'}'之前
  int offsetStart = 0;
  int offsetEnd = 0;

  ImageClassGetter({
    required this.className,
    this.variableName,
    this.variableValue,
  });

  @override
  List<BackTester<AstNode>> testers = [
    DeclarationBTester(),
  ];

  @override
  void reset() {
    ClassDeclaration? dec = tester<DeclarationBTester>()
        .tList<ClassDeclaration>()
        .where((e) => e.name.toString() == className)
        .firstOrNull;
    if (dec != null) {
      matchClassName = true;
      offsetStart = dec.offset;
      offsetEnd = dec.endToken.offset;
      for (var element in dec.members) {
        if (element is FieldDeclarationImpl) {
          String varName = element.fields.variables.first.name.toString();
          String varValue =
              element.fields.variables.first.initializer.toString();
          if (variableName == varName) {
            matchVariableName = true;
            if (varValue.contains(variableValue ?? '')) {
              matchVariableValue = true;
            }
            break;
          }
        }
      }
    }
  }
}
