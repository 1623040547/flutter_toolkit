import 'back_tester.dart';
import 'step.dart';

///用于从[MainAnalyzer]中获取数据信息
///数据存储在每一个[Unit]中
abstract class Getter implements Testers {
  ///用于记录每一个[BackTester]的接收情况
  final Map<BackTester, bool> _accepts = {};

  ///获取存储在[testers]中类型为[T]的[BackTester]
  T tester<T>() {
    assert(testers.whereType<T>().length == 1);
    return testers.whereType<T>().first;
  }

  ///获取某一个[BackTester]的接收情况，当该tester未在路径上而未被记录时，返回false
  bool testerAccept<T>() => _accepts[testers.whereType<T>().first] ?? false;

  ///记录特征节点，为所有[BackTester.path]的并集
  List<AnalyzerStep> get patterns {
    Set<AnalyzerStep> steps = {};
    for (var tester in testers) {
      steps.addAll(tester.path);
    }
    steps.add(AnalyzerStep.classDeclaration);
    return steps.toList();
  }

  ///触发器，当遍历到特征节点时的调用方法
  ///该函数首先通过[resetFlag]判断当前节点是否标志着getter需要重置
  ///需要重置：执行重置方法
  ///不需要重置：执行每一个tester的[inPath]与[accept]方法
  void trigger(node, AnalyzerStep step) {
    if (resetFlag(node, step)) {
      _reset();
    }
    for (var tester in testers) {
      if (tester.inPath(node)) {
        _accepts[tester] = tester.accept(node);
      }
    }
  }

  ///指定重置条件，默认为类声明节点[ClassDeclaration]
  bool resetFlag(node, AnalyzerStep step) {
    return step == AnalyzerStep.classDeclaration;
  }

  ///重置函数，会重置[Getter]当前的接受状态与每个[tester]的接受状态
  void _reset() {
    reset();
    _accepts.clear();
    for (var tester in testers) {
      tester.reset();
    }
  }

  ///提供给继承[Getter]的子类的[reset]接口,
  ///允许子类在此处从[tester]中获取想要的数据
  void reset();
}

abstract class Testers {
  List<BackTester> testers = [];
}
