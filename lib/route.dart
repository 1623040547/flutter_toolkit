import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

BuildContext get context => navigatorKey.currentContext!;

enum Route {
  root(page: Test());

  const Route({
    required this.page,
  });

  final StatelessWidget page;

  String get routeName => '/$name';

  static back() {
    Navigator.of(context).pop();
  }
}

MaterialApp get namedApp => MaterialApp(
      initialRoute: Route.root.routeName,
      navigatorKey: navigatorKey,
      routes: Route.values.asNameMap().map(
            (key, value) => MapEntry(
              '/$key',
              (_) => value.page,
            ),
          ),
    );

class Test extends StatelessWidget {
  const Test({super.key});

  @override
  Widget build(BuildContext context) => Container();
}

extension on Route {
  void to() {
    Navigator.of(context).pushNamed(routeName);
  }

  void until() {
    Navigator.of(context).popUntil((route) => route.settings.name == routeName);
  }

  void offNamed(){
    Navigator.of(context).popAndPushNamed(routeName);
  }

  // void delete(){
  //   Navigator.of(context).removeRoute(route)
  // }
}
