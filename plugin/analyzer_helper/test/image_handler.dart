import 'package:analyzer_x/application/image_handler/imageHandler.dart';

///在脚本中通过以下命令调用该函数：
///flutter test
///--dart-define="FILE_PATH=$EVENT_HELPER_PATH/data/$APP_NAME"
///"${PROJECT_PATH}"/plugin/analyzer_helper/test/image_handler.dart
Future<void> main() async {
  await ImageHandler(const String.fromEnvironment('FILE_PATH')).start();
}
