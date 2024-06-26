import 'dart:io';
import 'package:dart_style/dart_style.dart';

import '../../base/log.dart';
import '../../getter/paramGetter.dart';
import '../../path/package.dart';
import 'importGen.dart';

class ParamFactoryGen {
  final List<String> importFiles = [];
  final String onCheckFailMethod = 'onParamCheckFail';

  ParamFactoryGen();

  void execute() {
    _clean();
    analyzerLog(DateTime.now());
    analyzerLog('parse param');
    Map<DartFile, List<ParamUnit>> units = parseParam();

    assert(units.values.expand((e) => e).toList().isNotEmpty);

    ///生成代码
    String fileString = _classBlock(
      methods: [
        _fromMethod(
          units.values.expand((element) => element).toList(),
        ),
        _onEventCheckFailMethod(),
      ],
    );

    ///自动引入
    analyzerLog(DateTime.now());
    analyzerLog('auto import');
    importFiles.addAll(ImportGen.instance.analyse(fileString));
    fileString = _dartFile(header: _header(), classBlock: [fileString]);

    ///代码格式化
    DartFormatter formatter = DartFormatter(indent: 0);
    String code = formatter.format(fileString);

    ///设置生成[ParamUnit]最多的文件为输出文件
    DartFile? outFile;
    int count = 0;
    units.forEach((key, value) {
      if (value.length > count) {
        outFile = key;
        count = value.length;
      }
    });
    File(outFile!.filePath.replaceAll('.dart', '.g.dart')).writeAsString(code);
    analyzerLog(DateTime.now());
    analyzerLog(
        'ParamFactoryGen: ${outFile!.importName.replaceAll('.dart', '.g.dart')}');
  }

  String _dartFile({required header, required List<String> classBlock}) {
    return """
    $header
    ${classBlock.join()}
    """;
  }

  String _header() {
    return """
    // GENERATED CODE - DO NOT MODIFY BY HAND

    // **************************************************************************
    // $ParamFactoryGen
    // **************************************************************************

    ${importFiles.join()}

    """;
  }

  String _classBlock({required List<String> methods}) {
    return """
    abstract class ProtoParamFactory {
      ${methods.join()}
    }
    """;
  }

  String _onEventCheckFailMethod() {
    return """
    void $onCheckFailMethod(String name, dynamic value, Object error);
    """;
  }

  String _fromMethod(List<ParamUnit> units) {
    return """
    BaseParam from(String name, dynamic value) {
      try {
        switch (name) {
        ${_caseParts(units).join()}
          default:
              break;
        }
      }
      catch(error){
        $onCheckFailMethod(name,value,error);
      }
      return GeneralParam(name: name, value: value);
    }
    """;
  }

  List<String> _caseParts(List<ParamUnit> units) {
    String casePart(ParamUnit unit) {
      return """
          case '${unit.paramName}':
          return ${unit.className}(value);
        """;
    }

    return units.map((e) => casePart(e)).toList();
  }

  void _clean() {
    importFiles.clear();
  }
}
