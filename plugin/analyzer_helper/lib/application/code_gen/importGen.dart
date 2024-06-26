import 'dart:io';

import '../../base/analyzer.dart';
import '../../getter/declarationGetter.dart';
import '../../getter/directiveGetter.dart';
import '../../getter/likeableExternObjGetter.dart';
import '../../path/package.dart';

class ImportGen {
  static ImportGen? _instance;

  static get instance {
    return _instance ??= ImportGen();
  }

  ///获取所有dart文件及其中的对象声明
  final Map<DartFile, DeclarationGetter> declarationGetters = {};

  ///获取所有dart文件及其中的资源定位声明
  final Map<DartFile, DirectiveGetter> directiveGetter = {};

  ///拥有library声明的dart文件
  final List<DartFile> libraryFiles = [];

  ///拥有part声明的dart文件
  final List<DartFile> partFiles = [];

  ///拥有export声明的dart文件
  final List<DartFile> exportFiles = [];

  ///初次确定需要自动引用的文件
  Set<DartFile> initialImportFile = {};

  ///移除ImportFile中有"part of"的文件
  Set<DartFile> noPartOfImport = {};

  ImportGen() {
    final List<DartFile> dartFiles = getDartFiles();

    for (var dartFile in dartFiles) {
      declarationGetters[dartFile] = DeclarationGetter();
      directiveGetter[dartFile] = DirectiveGetter();
      MainAnalyzer(
        filePath: dartFile.filePath,
        getters: [
          declarationGetters[dartFile]!,
          directiveGetter[dartFile]!,
        ],
      );
      DirectiveUnit unit = directiveGetter[dartFile]!.unit;
      if (unit.dExport.isNotEmpty) {
        exportFiles.add(dartFile);
      } else if (unit.dPart.isNotEmpty) {
        partFiles.add(dartFile);
      } else if (unit.dLibrary.isNotEmpty) {
        libraryFiles.add(dartFile);
      }
    }
  }

  List<String> analyse(String targetText) {
    _clean();
    LikeableExternObjGetter likeableExternIdGetter = LikeableExternObjGetter();
    MainAnalyzer(fileText: targetText, getters: [likeableExternIdGetter]);
    initialImportFile.clear();
    noPartOfImport.clear();
    _match(likeableExternIdGetter.unit.ids);
    return noPartOfImport
        .map((e) => 'import \'${e.importName}\';'
            .replaceAll(Platform.pathSeparator, '/'))
        .toSet()
        .toList();
  }

  ///获取到引用类所在原文件路径
  void _match(List<String> obj) {
    declarationGetters.forEach((key, getter) {
      DeclarationUnit unit = getter.unit;
      for (var dClass in unit.dClass) {
        if (obj.contains(dClass)) {
          initialImportFile.add(key);
        }
      }
      for (var dFunction in unit.dFunction) {
        if (obj.contains(dFunction)) {
          initialImportFile.add(key);
        }
      }
    });
    for (var element in initialImportFile) {
      DirectiveUnit unit = directiveGetter[element]!.unit;
      if (unit.dPartOfUri.isEmpty && unit.dPartOfLibrary.isEmpty) {
        noPartOfImport.add(element);
      } else {
        if (unit.dPartOfUri.isNotEmpty) {
          ///todo:uri处理
        } else {
          ///库处理
          for (var file in libraryFiles) {
            if (directiveGetter[file]!
                .unit
                .dLibrary
                .contains(unit.dPartOfLibrary.first)) {
              noPartOfImport.add(file);
            }
          }
        }
      }
    }
  }

  void _clean(){
    declarationGetters.clear();
    directiveGetter.clear();
    libraryFiles.clear();
    partFiles.clear();
    exportFiles.clear();
    initialImportFile.clear();
    noPartOfImport.clear();
  }
}
