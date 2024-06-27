import 'dart:io';

class ProjectConfig {
  static List<FileSystemEntity> getAllProjects(String path) {
    List<FileSystemEntity> dd = Directory(path).listSync();
    List<FileSystemEntity> projects = [];
    for (FileSystemEntity d in dd) {
      try {
        var i = Directory(d.path).listSync().where((e) {
          return e.uri.pathSegments.last == 'pubspec.yaml' ||
              e.path.contains('.dart_tool');
        }).toList();
        if (i.length == 2) {
          projects.add(d);
          print(d.path);
        }
      } catch (e) {
        continue;
      }
    }
    return projects;
  }
}
