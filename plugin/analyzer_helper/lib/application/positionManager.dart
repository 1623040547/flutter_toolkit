import 'dart:ui';
import 'package:analyzer_x/base/base.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart';

class PositionManager {
  static PositionManager get instance => _instance ??= PositionManager._();
  static PositionManager? _instance;

  final localHost = 'http://192.168.200.113:3000';

  Map<String, GlobalKey> map1 = {};
  Map<String, bool> map2 = {};

  String appName = '';

  bool flag = false;

  PositionManager._();

  void init(String appName) {
    this.appName = appName;
    flag = true;
    map1.clear();
    map2.clear();
  }

  @protected
  GlobalKey? allocateKey(List<String> routes, List<String> positions) {
    String key = _positionKey(routes, positions);
    if (map2[key] == true) {
      analyzerLog('allocateKey contains $key');
      return null;
    }
    analyzerLog('allocateKey $key');
    map1[key] = GlobalKey();
    map2[key] = false;
    return map1[key];
  }

  Future<bool> _toImage(String key) async {
    if (map2[key] == true) {
      return true;
    }
    try {
      analyzerLog('allocateKey toImage $key');
      RenderRepaintBoundary? boundary = map1[key]
          ?.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      var image = await boundary?.toImage(pixelRatio: 1);
      ByteData? byteData = await image?.toByteData(format: ImageByteFormat.png);
      List<int>? pngBytes = byteData?.buffer.asUint8List().toList();
      Stream<List<int>> stream = Stream.value(pngBytes!);
      MultipartRequest request =
          MultipartRequest('post', Uri.parse('$localHost/images'));
      request.headers.addAll({'app': appName});
      request.files.add(
        MultipartFile(
          'file',
          stream,
          pngBytes.length,
          filename: '$key.png',
        ),
      );
      StreamedResponse response = await request.send();
      analyzerLog('allocateKey toImage Success $key ${response.statusCode}');
      PositionManager.instance.map2[key] = true;
      return true;
    } catch (e) {
      analyzerLog('allocateKey toImage Fail $key');
      analyzerLog(e);
      return false;
    }
  }

  String _positionKey(List<String> routes, List<String> positions) {
    routes.removeWhere((el) => el == 'null');
    positions.removeWhere((el) => el == 'null');
    return '${routes.join(',').replaceAll('/', '')}_${positions.join(',').replaceAll('/', '')}';
  }

  initState(List<String> routes, List<String> positions) {
    if (!PositionManager.instance.flag) {
      return;
    }
    String position = _positionKey(routes, positions);
    if (PositionManager.instance.map2[position] != true) {
      WidgetsFlutterBinding.ensureInitialized()
          .addPostFrameCallback((timeStamp) {
        Future.delayed(const Duration(seconds: 3), () {
          PositionManager.instance._toImage(position);
        });
      });
    } else {
      analyzerLog('allocateKey toImage exist');
    }
  }

  Future<void> allToImage() async {
    if (!PositionManager.instance.flag) {
      return;
    }
    for (var e in map2.entries.toList()) {
      if (!e.value) {
        map2[e.key] = await _toImage(e.key);
      }
    }
  }
}

extension PositionRepaint on Widget {
  repaint(List<String> routes, List<String> positions) {
    if (!PositionManager.instance.flag) {
      return this;
    }
    GlobalKey? g = PositionManager.instance.allocateKey(routes, positions);
    if (g != null) {
      return RepaintBoundary(
        key: g,
        child: this,
      );
    }
    return this;
  }
}
