import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

void main() {
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

  @override
  void initState() {
    super.initState();
    dragTips = 'Drag image to here!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          alignment: Alignment.center,
          decoration:
              const BoxDecoration(color: Color.fromRGBO(215, 215, 235, 0.6)),
          child: DropTarget(
            onDragEntered: (details) {
              print('onMove');
              setState(() {
                dragTips = 'I`ll eat it!';
              });
            },
            onDragExited: (details) {
              print('onWillAcceptWithDetails');
              setState(() {
                dragTips = 'Drag image to here!';
              });
            },
            onDragDone: (details) {
              print('onLeave');
              setState(() {
                dragTips = 'I accept it!!';
              });
            },
            child: Container(
              width: 800,
              height: 500,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Text(
                dragTips,
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromRGBO(215, 215, 235, 1),
                ),
              ),
            ),
          )),
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
}
