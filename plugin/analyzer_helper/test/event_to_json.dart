import 'dart:async';
import 'package:analyzer_x/application/eventToJson.dart';

///在脚本中通过以下命令调用该函数：
///flutter test
///--dart-define="FILE_PATH=$EVENT_HELPER_PATH/data/$APP_NAME"
///"${PROJECT_PATH}"/plugin/analyzer_helper/test/event_to_json.dart
Future<void> main() async {
  EventToJson.instance
      .toJson(filePath: const String.fromEnvironment('FILE_PATH'));
}
