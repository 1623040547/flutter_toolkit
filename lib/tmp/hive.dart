import 'package:hive_flutter/adapters.dart';

class HiveHelper {
  static Box? _pathSaver;

  static Box get box => _pathSaver!;

  static String? _path;

  static String? _projPath;

  static Future<void> init() async {
    await Hive.initFlutter();
    _pathSaver = await Hive.openBox('HiveHelper');
  }

  static Future<void> setPath(String path) async {
    _path = path;
    await box.put('path', path);
  }

  static Future<void> setProj(String projPath) async {
    _projPath = projPath;
    await box.put('projPath', projPath);
  }

  static String? getPath() {
    return _path ??= box.get('path', defaultValue: null);
  }

  static String? getProjPath() {
    return _projPath ??= box.get('projPath', defaultValue: null);
  }
}
