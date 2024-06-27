import 'dart:convert';
import 'dart:io';

part 'path.dart';

///解析flutter项目中[_projPath]/.dart_tool/package_config.json路径下的配置文件，获取所有包信息
///此类的路径分析均以上述配置文件为基础进行
class PackageConfig {
  final List<Package> packages;

  PackageConfig({
    required this.packages,
  });

  static String _projPath = "";

  ///指定主项目路径
  static void to(String projPath) {
    if (_projPath != projPath) {
      _projPath = projPath;
      _files.clear();
    }
  }

  static void clear() {
    _files.clear();
  }

  ///获取主项目路径，
  ///通过调用[Platform.script]获取程序执行入口的路径，
  ///从根路径开始逐步访问，找到第一个包含[package_config.json]文件的文件夹，将此作为主进程路径
  static String get projPath {
    if (_projPath.isNotEmpty) {
      return _projPath;
    }
    List<String> seg = Platform.script.pathSegments;
    for (int i = 1; i <= seg.length; i++) {
      String path = seg.sublist(0, i).join(Platform.pathSeparator);
      path = Platform.script.toFilePath().split(path).first + path;
      if (File(_configFilePath(path)).existsSync()) {
        _projPath = path;
        break;
      }
    }
    assert(_projPath.isNotEmpty);
    return _projPath;
  }

  static String _configFilePath(String path) {
    return '$path${Platform.pathSeparator}.dart_tool${Platform.pathSeparator}package_config.json';
  }

  static PackageConfig fromProj() {
    String file = File(_configFilePath(projPath)).readAsStringSync();
    assert(file.isNotEmpty);
    return PackageConfig.fromJson(file);
  }

  static PackageConfig fromJson(String json) {
    return PackageConfig(
      packages: (jsonDecode(json)['packages'] as List)
          .map(
            (e) => Package.fromJson(
              jsonEncode(e),
            ),
          )
          .toList(),
    );
  }
}

///定义包信息
class Package {
  final String name;
  final String rootUri;
  final String packageUri;

  Package({
    required this.name,
    required this.rootUri,
    required this.packageUri,
  });

  ///将根Uri转化为文件路径
  String get rootFilePath => Uri.parse(rootUri).toFilePath();

  ///将包Uri转化为文件路径
  String get packageFilePath => Uri.parse(packageUri).toFilePath();

  ///当前包是否为主工程
  bool get isMainProj => rootFilePath == '..${Platform.pathSeparator}';

  ///当前包是否为绝对路径
  bool get isAbsolutePath => Uri.parse(rootUri).isAbsolute;

  ///获取到一个包的绝对路径
  String get absolutePackagePath {
    if (isMainProj) {
      return PackageConfig.projPath + Platform.pathSeparator + packageFilePath;
    } else if (!isAbsolutePath) {
      return rootFilePath.replaceAll('..', PackageConfig.projPath) +
          Platform.pathSeparator +
          packageFilePath;
    } else {
      return rootFilePath + Platform.pathSeparator + packageFilePath;
    }
  }

  static Package fromJson(String json) {
    return Package(
      name: jsonDecode(json)['name'],
      rootUri: jsonDecode(json)['rootUri'],
      packageUri: jsonDecode(json)['packageUri'],
    );
  }
}
