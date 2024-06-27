import 'dart:io';

import 'package:analyzer_x/application/image_handler/imageHandler.dart';
import 'package:analyzer_x/path/package.dart';
import 'package:analyzer_x/path/project.dart';
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_toolkit/tmp/hive.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  await HiveHelper.init();
  WidgetsFlutterBinding.ensureInitialized();
  // 必须加上这一行。
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(600, 400),
    // 设置默认窗口大小
    minimumSize: Size(600, 400),
    // 设置最小窗口大小
    maximumSize: Size(600, 400),
    center: true,
    // 设置窗口居中
    title: "", // 设置窗口标题
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dragTips = '';
  TextEditingController controller = TextEditingController();
  int index = 0;
  List<FileSystemEntity> projects = [];
  String selProjectPath = '';

  @override
  void initState() {
    super.initState();
    dragTips = 'Drag image to here!';
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      setState(() {
        controller.text = HiveHelper.getPath() ?? '';
        if (controller.text.isNotEmpty) {
          projects = ProjectConfig.getAllProjects(controller.text);
          index = 1;
        }
        selProjectPath = HiveHelper.getProjPath() ?? '';
        if (selProjectPath.isNotEmpty) {
          index = 2;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: index,
        children: [
          pathPage(),
          projectPage(),
          addImagePage(),
        ],
      ),
    );
  }

  Widget card(Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(color: color),
        alignment: Alignment.center,
      ),
    );
  }

  Widget pathPage() {
    return DropTarget(
      onDragDone: (details) {
        if (index == 0) {
          XFile f = details.files.first;
          setState(() {
            controller.text = f.path;
          });
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 100),
                      child: Text(
                        '输入/拖入StudioProjects项目路径',
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 100),
                      child: TextField(
                        onChanged: (_) {
                          setState(() {});
                        },
                        controller: controller,
                        maxLines: 1,
                        decoration: InputDecoration(
                          fillColor: Colors.green.withOpacity(0.1),
                          filled: true,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        onTap: () {
                          HiveHelper.setPath(controller.text);
                          projects =
                              ProjectConfig.getAllProjects(controller.text);
                          setState(() {
                            index = 1;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          width: 150,
                          height: 50,
                          decoration: BoxDecoration(
                              color: controller.text.isEmpty
                                  ? Colors.grey
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15)),
                          alignment: Alignment.center,
                          child: Text(
                            '确认',
                            style: TextStyle(
                              color: Colors.black.withOpacity(
                                0.8,
                              ),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget projectPage() {
    return Column(
      children: [
        header('选择你需要的项目', () {
          setState(() {
            index = 0;
          });
        }),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                  child: Wrap(
                    runSpacing: 5,
                    spacing: 20,
                    children: projects
                        .map(
                          (e) => projectCard(e),
                        )
                        .toList(),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget projectCard(FileSystemEntity file) {
    return InkWell(
      onTap: () {
        setState(() {
          selProjectPath = file.path;
          HiveHelper.setProj(selProjectPath);
          index = 2;
          print('projectCard');
        });
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.green.withOpacity(0.2)),
        height: 75,
        padding: const EdgeInsets.all(8),
        child: Text(
          file.path.split(Platform.pathSeparator).last,
        ),
      ),
    );
  }

  String notify = '请拖入含有照片的文件夹';

  Widget addImagePage() {
    return DropTarget(
        onDragDone: (details) async {
          if (index == 2) {
            setState(() {
              notify = '正在处理';
            });
            Future.delayed(const Duration(seconds: 1), () async {
              XFile f = details.files.first;
              PackageConfig.to(selProjectPath);
              try {
                await ImageHandler(f.path).start();
                setState(() {
                  notify = '处理完成!';
                });
              } catch (e) {
                print(e);
                setState(() {
                  notify = '含有不符合命名规范的照片';
                });
              }

              Future.delayed(const Duration(seconds: 2), () {
                setState(() {
                  notify = '请拖入含有照片的文件夹';
                });
              });
            });
          }
        },
        child: Column(
          children: [
            header(Uri.tryParse(selProjectPath)?.pathSegments.lastOrNull ?? '',
                () {
              setState(() {
                index = 1;
              });
            }),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              child: Text(
                notify,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ))
          ],
        ));
  }

  Widget header(String text, Function()? onTap) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.yellowAccent.withOpacity(0.1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            width: 40,
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.black.withOpacity(
                0.8,
              ),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(
            width: 40,
            child: InkWell(
              onTap: onTap,
              enableFeedback: false,
              child: const Icon(
                Icons.settings,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
