import 'package:flutter/cupertino.dart';

class GlobalObserver extends NavigatorObserver {
  final List<Route> _routes = [];

  static GlobalObserver? _instance;

  static GlobalObserver get instance => _instance ??= GlobalObserver();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.removeLast();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.removeWhere((e) => e.settings.name == route.settings.name);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    int index =
        _routes.indexWhere((e) => e.settings.name == oldRoute?.settings.name);
    if (index != -1) {
      _routes[index] = newRoute ?? _routes[index];
    }
  }
}
