import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/src/dart/ast/ast.dart';

///[Getter]从各种语法结点中获取数据,且数据类型均为[String]或[int],
///因此在此处定义其单元基类
class Unit {
  String name;
  String data;
  int? offset;
  int? end;
  Unit? next;
  Unit? front;

  List<Unit> children;

  Unit(
    this.data, {
    this.name = '',
    this.children = const [],
    this.offset,
    this.end,
    this.next,
    this.front,
  });
}

extension UnitToolToken on Token {
  Unit get unit {
    return Unit(
      toString(),
      offset: offset,
      end: end,
      next: next?.unit,
      front: previous?.unit,
    );
  }
}

extension UnitToolAstNode on AstNode {
  Unit unit(String data) {
    return Unit(
      data,
      offset: offset,
      end: end,
    );
  }
}

extension NullProcess on dynamic {
  ifNonNull(Function() func) {
    if (this != null) {
      func.call();
    }
  }

  block<T>(Function(T) func) {
    if (this is T) {
      func.call(this);
    }
  }
}
