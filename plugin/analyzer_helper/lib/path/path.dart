part of 'package.dart';

///过滤掉从外部引入的包
bool filterExternPackage = true;

List<DartFile> _files = [];

void _getDartFile(Package package, String path, List<DartFile> dartFiles) {
  Directory dir = Directory(path);
  if (!dir.existsSync()) {
    return;
  }
  List<FileSystemEntity> lists = dir.listSync();
  for (FileSystemEntity entity in lists) {
    if (entity is File) {
      File file = entity;
      if (file.uri.pathSegments.last.split('.').last == 'dart') {
        dartFiles.add(DartFile(package, file.path));
      }
    } else if (entity is Directory) {
      Directory subDir = entity;
      _getDartFile(package, subDir.path, dartFiles);
    }
  }
}

///获取主进程中的所有dart文件
List<DartFile> getDartFiles({bool Function(String fileString)? isTarget}) {
  if (_files.isEmpty) {
    PackageConfig config = PackageConfig.fromProj();
    for (var package in config.packages) {
      if (!filterExternPackage || !package.isAbsolutePath) {
        _getDartFile(package, package.absolutePackagePath, _files);
      }
    }
  }
  return _files
      .where((e) => isTarget?.call(File(e.filePath).readAsStringSync()) ?? true)
      .toList();
}

///定义一个dart文件
class DartFile {
  final Package package;
  final String filePath;

  String get importName {
    return 'package:${filePath.replaceAll(package.absolutePackagePath, package.name + Platform.pathSeparator).replaceAll(Platform.pathSeparator, '/')}';
  }

  String get libName {
    return filePath
        .replaceAll(package.absolutePackagePath, 'lib/')
        .replaceAll(Platform.pathSeparator, '/');
  }

  String get fileName => Uri.parse(filePath).pathSegments.last.split('.')[0];

  String get fileNameWithFix => Uri.parse(filePath).pathSegments.last;

  DartFile(this.package, this.filePath);
}
