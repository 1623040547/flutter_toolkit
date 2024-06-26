import 'dart:convert';
import 'dart:io';

import 'package:analyzer_x/application/gitAnalyzer.dart';
import 'package:analyzer_x/base/analyzer.dart';
import 'package:analyzer_x/base/base.dart';
import 'package:analyzer_x/getter/eventGetter.dart';

import '../getter/paramGetter.dart';
import '../getter/unionParamGetter.dart';
import '../path/package.dart';

///将事件/参数必要信息转换为json文件
class EventToJson {
  static EventToJson? _instance;

  static EventToJson get instance => _instance ??= EventToJson();

  Map<DartFile, List<EventUnit>> eventMap = {};
  Map<DartFile, List<ParamUnit>> paramMap = {};
  Map<DartFile, List<UnionParamUnit>> unionParamMap = {};

  List<EventUnit> get events =>
      eventMap.values.expand((element) => element).toList();

  List<ParamUnit> get params =>
      paramMap.values.expand((element) => element).toList();

  List<UnionParamUnit> get unionParams =>
      unionParamMap.values.expand((element) => element).toList();

  ParamUnit? param(String p) {
    List<ParamUnit> paramList =
        params.where((element) => element.className == p).toList();
    return paramList.isEmpty ? null : paramList.first;
  }

  UnionParamUnit? unionParam(String p) {
    List<UnionParamUnit> params =
        unionParams.where((element) => element.className == p).toList();
    return params.isEmpty ? null : params.first;
  }

  toJson({String? filePath}) {
    _clean();
    if (filePath != null && !Directory(filePath).existsSync()) {
      Directory(filePath).createSync();
    }

    _analyze();

    paramToJson(filePath: filePath);

    unionParamToJson(filePath: filePath);

    eventToJson(filePath: filePath);
  }

  _analyze() {
    ///获取需求数据
    for (var file in getDartFiles()) {
      EventGetter eventGetter = EventGetter();
      ParamGetter paramGetter = ParamGetter();
      UnionParamGetter unionParamGetter = UnionParamGetter();
      MainAnalyzer(
        getters: [
          eventGetter,
          paramGetter,
          unionParamGetter,
        ],
        filePath: file.filePath,
      );
      if (eventGetter.units.isNotEmpty) {
        eventMap[file] = eventGetter.units;
      }
      if (paramGetter.units.isNotEmpty) {
        paramMap[file] = paramGetter.units;
      }
      if (unionParamGetter.units.isNotEmpty) {
        unionParamMap[file] = unionParamGetter.units;
      }
    }

    ///过滤
    Map<String, String> patterns = Map.fromIterables(
        params.map((e) => e.className), params.map((e) => e.paramName));
    for (var unit in unionParams) {
      unit.filter(patterns);
    }
  }

  eventToJson({String? filePath}) {
    Map<String, List<EventUnit>> map = _eventToVersion();
    List l = [];
    List<String> versions = map.keys.toList();
    versions.sort((a, b) => a.compareTo(b));
    for (String version in versions) {
      analyzerLog('eventToJson $version');
      l.add(_eventToJson(map[version]!, version));
    }

    ///输出
    String jsonStr = json.encode(l);

    filePath = filePath == null
        ? '${PackageConfig.projPath}/plugin/analyzer_helper/test/events.json'
        : '$filePath/events.json';
    File(filePath).writeAsString(jsonStr);
  }

  paramToJson({String? filePath}) {
    Map l = _paramToJson(params);

    ///输出
    String jsonStr = json.encode(l);
    filePath = filePath == null
        ? '${PackageConfig.projPath}/plugin/analyzer_helper/test/params.json'
        : '$filePath/params.json';
    File(filePath).writeAsString(jsonStr);
  }

  unionParamToJson({String? filePath}) {
    Map l = _unionParamToJson(unionParams);

    ///输出
    String jsonStr = json.encode(l);

    filePath = filePath == null
        ? '${PackageConfig.projPath}/plugin/analyzer_helper/test/union_params.json'
        : '$filePath/union_params.json';
    File(filePath).writeAsString(jsonStr);
  }

  Map<String, dynamic> _eventToJson(List<EventUnit> events, String version) {
    ///构建json文件
    List eventJsonList = [];
    Set<String> names = {};
    for (EventUnit unit in events) {
      Map<String, dynamic> map = {};
      if (names.contains(unit.eventName)) {
        continue;
      }
      names.add(unit.eventName);
      map["event_name"] = unit.eventName;
      map["event_desc"] = unit.eventDesc.isEmpty ? "" : unit.eventDesc;
      map["event_plate"] = unit.eventDesc.isEmpty ? "" : unit.eventPlate;
      map["panels"] = unit.panels.isEmpty
          ? [
              'xlog',
              'appEvent',
              'grpc',
              'firebase',
              'mixpanel',
            ]
          : unit.panels;

      ///todo:确定事件在代码中的位置
      map["locations"] = [];

      List paramList = [];
      for (var key in unit.classParameters.keys) {
        ParamUnit? u1 = param(unit.classParameters[key]!);
        UnionParamUnit? u2 = unionParam(unit.classParameters[key]!);
        Map<String, dynamic> paramMap = {};
        if (u1 != null) {
          paramMap["param_name"] = u1.paramName;
          paramMap["param_type"] = u1.paramType;
          paramMap["param_desc"] =
              unit.classParametersMeta[key] ?? u1.paramDesc;
          paramMap["param_check"] = u1.paramCheck;
          paramList.add(paramMap);
        } else if (u2 != null) {
          paramMap["param_name"] = u2.paramName;
          paramMap["param_type"] = u2.className;
          paramMap["param_desc"] =
              unit.classParametersMeta[key] ?? u2.paramDesc;
          paramMap["param_check"] = "";
          paramList.add(paramMap);
        } else {
          paramMap["param_name"] = key;
          paramMap["param_type"] = unit.classParameters[key];
          paramMap["param_desc"] = "Not a specific param";
          paramMap["param_check"] = "";
          paramList.add(paramMap);
        }
      }
      map["param_list"] = paramList;
      eventJsonList.add(map);
    }
    return {"version": version, "data": eventJsonList};
  }

  Map<String, dynamic> _paramToJson(List<ParamUnit> params) {
    ///构建json文件
    List paramJsonList = [];
    for (ParamUnit unit in params) {
      Map<String, dynamic> paramMap = {};
      paramMap["param_name"] = unit.paramName;
      paramMap["param_desc"] = unit.paramDesc;
      paramMap["param_type"] = unit.paramType;
      paramMap["param_check"] = unit.paramCheck;
      paramJsonList.add(paramMap);
    }

    return {"data": paramJsonList};
  }

  Map<String, dynamic> _unionParamToJson(List<UnionParamUnit> unionParams) {
    ///构建json文件
    List paramJsonList = [];
    for (UnionParamUnit unit in unionParams) {
      Map<String, dynamic> paramMap = {};
      paramMap["param_name"] = unit.paramName;
      paramMap["param_desc"] = unit.paramDesc;
      paramMap["param_type"] = unit.className;
      List<Map<String, dynamic>> params = [];
      for (String param in unit.children) {
        params.add({'param': param});
      }
      paramMap["params"] = params;
      paramJsonList.add(paramMap);
    }

    return {"data": paramJsonList};
  }

  Map<String, List<EventUnit>> _eventToVersion() {
    Map<String, List<EventUnit>> map = {};
    for (DartFile file in eventMap.keys) {
      List<String> lines = File(file.filePath).readAsLinesSync();
      List<int> offsets = [0];
      for (var line in lines) {
        offsets.add(offsets.last + line.length + 1);
      }
      for (EventUnit unit in eventMap[file] ?? []) {
        int startLine =
            offsets.indexWhere((element) => element > unit.eventStart);
        int endLine = offsets.indexWhere((element) => element > unit.eventEnd);
        String version = GitAnalyzer.instance
            .analyzeVersion(file.filePath, startLine, endLine);
        map[version] = [...map[version] ?? [], unit];
      }
    }
    return map;
  }

  void _clean() {
    eventMap.clear();
    paramMap.clear();
    unionParamMap.clear();
  }
}
