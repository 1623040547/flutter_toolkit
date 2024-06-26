import 'dart:io';

import 'package:analyzer_x/base/base.dart';

import '../base/analyzer.dart';
import 'package:dart_style/dart_style.dart';
import '../getter/jsonSerializableGetter.dart';
import '../path/package.dart';

///将原本通过@[JsonSerializable]进行序列化的class转为通过@[freezed]进行序列化
///完整替换可表示为：
///
///1、引入
///[import 'package:flutter/foundation.dart';]
///[import 'package:freezed_annotation/freezed_annotation.dart';]
///
///2、增加{part 'fileName.freezed.dart';};
///
///3、替换
///@[JsonSerializable] => @[freezed]
///[ClassName] => [ClassName with _$ClassName]
///
/// 4、删除原构造器与参数及其[JsonKey]
///
/// 5、添加freezed的构造器
/// [factory ClassName() = _ClassName]
class JsonToFreeze {
  static Map<DartFile, JsonSerializableGetter> map = {};

  static String importName = """
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
  """;

  static toFreeze() {
    map.clear();
    _getUnits();

    for (DartFile file in map.keys) {
      if (map[file]!.units.isNotEmpty) {
        String text = File(file.filePath).readAsStringSync();

        ///由下至上替换，依次为参数、构造器、类名、类注解
        for (var unit in map[file]!.units.reversed) {
          String constMsg = '';

          ///新构造器
          String newConstructor = """
          ${unit.className}._();
          factory ${unit.className}(
          """;

          ///可选参数构造
          String named = '{';

          ///非可选参数构造
          String nonNamed = '';

          ///参数替换
          for (var claParam in unit.claParams) {
            String ifNamed = '';
            if (claParam.isConst) {
              constMsg += text
                  .substring(claParam.start, claParam.end)
                  .replaceAll('static ', '');
              text = text.substring(0, claParam.start) +
                  ' ' * text.substring(claParam.start, claParam.end).length +
                  text.substring(claParam.end);
              continue;
            }
            bool isNamed = unit.conParams
                    .where((element) => element.paramName == claParam.paramName)
                    .firstOrNull
                    ?.isNamed ==
                true;
            if (isNamed) {
              String? defaultValue = unit.conParams
                  .where((element) => element.paramName == claParam.paramName)
                  .firstOrNull
                  ?.value;
              if (defaultValue?.isNotEmpty == true) {
                claParam.defaultValue = defaultValue;
              }
            }

            text = text.substring(0, claParam.start) +
                ' ' * text.substring(claParam.start, claParam.end).length +
                text.substring(claParam.end);

            ///获取参数定义前注解
            if (claParam.preEnd != 0) {
              String desc = text.substring(claParam.preEnd, claParam.start);
              text = text.substring(0, claParam.preEnd) +
                  ' ' * text.substring(claParam.preEnd, claParam.start).length +
                  text.substring(claParam.start);
              ifNamed += desc;
            }
            if (claParam.ducComment != null) {
              ifNamed += '\n${claParam.ducComment!}\n';
            }

            if (claParam.jsonKeyName != null) {
              analyzerLog(
                  'JsonKey Map ${unit.className} ${claParam.paramName} ${claParam.jsonKeyName}');
            }

            if (claParam.defaultValue != null) {
              if (isNamed) {
                ifNamed += '@Default(${claParam.defaultValue}) ';
              } else {
                ifNamed += '@JsonKey(defaultValue: ${claParam.defaultValue}) ';
              }
            }
            if (claParam.fromJson != null) {
              if (isNamed) {
                ifNamed += '@JsonKey(fromJson:${claParam.fromJson}) required ';
              } else {
                ifNamed += '@JsonKey(fromJson:${claParam.fromJson})';
              }
            }
            if (claParam.jsonKeyName != null) {
              ifNamed += '@JsonKey(name: ${claParam.jsonKeyName})';
            } else if (isNamed) {
              switch (claParam.paramType) {
                case 'String':
                  ifNamed += '@Default(\'\') ';
                  break;
                case 'int':
                case 'num':
                  ifNamed += '@Default(0) ';
                  break;
                case 'double':
                  ifNamed += '@Default(0.0) ';
                  break;
                case 'bool':
                  ifNamed += '@Default(false) ';
                  break;
                default:
                  if (claParam.paramType.startsWith('List')) {
                    ifNamed += '@Default([]) ';
                  } else if (claParam.paramType.startsWith('Map') ||
                      claParam.paramType.startsWith('Set')) {
                    ifNamed += '@Default({}) ';
                  } else {
                    ifNamed += '@Default(null) ';
                  }
                  break;
              }
            }

            ifNamed += '${claParam.paramType} ${claParam.paramName},';

            if (isNamed) {
              named += ifNamed;
            } else {
              nonNamed += ifNamed;
            }
          }

          ///toJson替换
          text = text.substring(0, unit.toJsonStart) +
              ' ' * text.substring(unit.toJsonStart, unit.toJsonEnd).length +
              text.substring(unit.toJsonEnd);

          if (named != '{') {
            named += '}';
          } else {
            named = '';
          }

          newConstructor += '$nonNamed$named) = _${unit.className};';

          ///构造器替换
          text = text.substring(0, unit.conStart) +
              newConstructor +
              text.substring(unit.conEnd);

          ///类名替换
          text = '${text.substring(0, unit.claStart)}'
              '${unit.className} with _\$${unit.className}'
              '${text.substring(unit.claEnd)}';

          ///注解替换
          text = '${text.substring(0, unit.metaStart)}'
              '$constMsg\n'
              '@unfreezed'
              '${text.substring(unit.metaEnd + 1)}';
        }
        int importEnd = map[file]!.importEnd;
        text = '${text.substring(0, importEnd)}\n'
            '$importName\n'
            'part \'${file.fileName}.freezed.dart\';'
            '${text.substring(importEnd)}';
        DartFormatter formatter = DartFormatter(indent: 0);
        String code = formatter.format(text);
        var f = File(file.filePath);
        f.writeAsString(code);
      }
    }
  }

  static _getUnits() {
    var files = getDartFiles();
    for (var file in files) {
      if (file.package.isMainProj &&
          !file.filePath.contains('.g.dart') &&
          !file.filePath.contains('.freezed.dart')) {
        JsonSerializableGetter getter = JsonSerializableGetter();
        MainAnalyzer(
          getters: [
            getter,
          ],
          filePath: file.filePath,
        );
        if (getter.units.isNotEmpty) {
          map[file] = getter;
        }
      }
    }
  }
}
