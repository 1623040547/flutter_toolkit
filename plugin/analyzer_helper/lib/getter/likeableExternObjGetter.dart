import 'package:analyzer/dart/ast/ast.dart';

import '../base/base.dart';
import '../tester/tester.dart';

///获取一个dart文件中疑似是外部引入对象的名字，
///具体为[PrefixedIdentifier]||[NamedType]||[MethodInvocation]
class LikeableExternObjGetter extends Getter {
  LikeableExternUnit unit = LikeableExternUnit();

  @override
  void reset() {
    unit.ids.addAll(getNamedTypes());
    unit.ids.addAll(getMethodInvocations());
    unit.ids.addAll(getPrefixedIdentifiers());
  }

  @override
  List<BackTester<AstNode>> testers = [
    MayExternRTester(),
  ];

  List<String> getNamedTypes() => tester<MayExternRTester>()
      .tList<NamedType>()
      .map((node) => node.name2.toString())
      .toList();

  List<String> getMethodInvocations() => tester<MayExternRTester>()
      .tList<MethodInvocation>()
      .map((node) => node.methodName.toString())
      .toList();

  List<String> getPrefixedIdentifiers() => tester<MayExternRTester>()
      .tList<PrefixedIdentifier>()
      .map((node) => node.prefix.name.toString())
      .toList();
}

class LikeableExternUnit {
  List<String> ids = [];
}
