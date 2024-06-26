import 'package:analyzer_x/base/base.dart';
import 'package:analyzer_x/tester/tester.dart';
import 'package:analyzer/dart/ast/ast.dart';

class MethodGetter extends Getter {
  List<MethodUnit> units = [];
  @override
  List<BackTester<AstNode>> testers = [
    MethodBTester(),
  ];

  @override
  void reset() {
    for (int i = 0; i < methods.length; i++) {
      units.add(MethodUnit(
        methods[i],
        className: classNames[i],
        offset: methodsOffset[i],
        end: methodsEnd[i],
        blockStart: methodsBlockStart[i],
      ));
    }
    for (int i = 0; i < funs.length; i++) {
      units.add(
        MethodUnit(
          funs[i],
          className: null,
          offset: funsOffset[i],
          end: funsEnd[i],
          blockStart: funsBlockStart[i],
        ),
      );
    }
  }

  List<String> get classNames {
    List<String> names = [];
    for (MethodDeclaration node
        in tester<MethodBTester>().tList<MethodDeclaration>()) {
      try {
        ClassDeclaration classDeclaration =
            tester<MethodBTester>().backNode<ClassDeclaration>(node);
        names.add(classDeclaration.name.toString());
        continue;
      } catch (e) {}

      try {
        ExtensionDeclaration extensionDeclaration =
            tester<MethodBTester>().backNode<ExtensionDeclaration>(node);
        names.add(extensionDeclaration.name.toString());
        continue;
      } catch (e) {}

      try {
        EnumDeclaration extensionDeclaration =
            tester<MethodBTester>().backNode<EnumDeclaration>(node);
        names.add(extensionDeclaration.name.toString());
        continue;
      } catch (e) {}

      try {
        MixinDeclaration mixinDeclaration =
            tester<MethodBTester>().backNode<MixinDeclaration>(node);
        names.add(mixinDeclaration.name.toString());
        continue;
      } catch (e) {}
    }
    return names;
  }

  List<String> get methods => tester<MethodBTester>()
      .tList<MethodDeclaration>()
      .map((node) => node.name.toString())
      .toList();

  List<int> get methodsOffset => tester<MethodBTester>()
      .tList<MethodDeclaration>()
      .map((node) => node.offset)
      .toList();

  List<int> get methodsBlockStart => tester<MethodBTester>()
      .tList<MethodDeclaration>()
      .map((node) => node.body.offset)
      .toList();

  List<int> get methodsEnd => tester<MethodBTester>()
      .tList<MethodDeclaration>()
      .map((node) => node.end)
      .toList();

  List<String> get funs => tester<MethodBTester>()
      .tList<FunctionDeclaration>()
      .map((node) => node.name.toString())
      .toList();

  List<int> get funsOffset => tester<MethodBTester>()
      .tList<FunctionDeclaration>()
      .map((node) => node.offset)
      .toList();

  List<int> get funsEnd => tester<MethodBTester>()
      .tList<FunctionDeclaration>()
      .map((node) => node.end)
      .toList();

  List<int> get funsBlockStart => tester<MethodBTester>()
      .tList<FunctionDeclaration>()
      .map((node) => node.functionExpression.body.offset)
      .toList();
}

class MethodUnit {
  String? className;
  String method;
  int blockStart;
  int offset;
  int end;
  int id;

  MethodUnit(
    this.method, {
    required this.className,
    this.blockStart = -1,
    this.offset = -1,
    this.end = -1,
    this.id = -1,
  });
}
