// @dart=2.9

import 'dart:isolate';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:flutter/material.dart';

import "sheepskin.dart";
import "folder_picker.dart";
import "scheduler_options.dart";
import "debug_helper.dart";

import 'package:android_alarm_manager/android_alarm_manager.dart';

const String isolateName = 'sheepskin';
final ReceivePort port = ReceivePort(); // for talking to the isolate
SharedPreferences prefs;
//const String countKey = 'count';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );

  prefs = await SharedPreferences.getInstance();

  if (!prefs.containsKey('demo')) {
    await prefs.setInt('demo', 0);
  }

  runApp(OuterLimitsState());
}

void printHello() {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=$isolateId function='$printHello'");
}


class OuterLimitsState extends StatefulWidget {
  final SheepSkin sheepSkin = SheepSkin();

  OuterLimitsState();

  @override
  State<StatefulWidget> createState() {
    return _OuterLimitsState(sheepSkin);
  }
}

class _OuterLimitsState extends State<OuterLimitsState> {
  final SheepSkin sheepSkin;

  _OuterLimitsState(this.sheepSkin);

  int _counter = 0;

  @override
  void initState() {
    super.initState();

    AndroidAlarmManager.initialize();

    port.listen((_) async => await _incrementCounter());

    // final int helloAlarmID = 0;
    // await AndroidAlarmManager.periodic(const Duration(minutes: 1), helloAlarmID, printHello);

    //setup();
  }

  Future<void> _incrementCounter() async {
    print('Increment counter!');

    // Ensure we've loaded the updated count from the background isolate.
    await prefs.reload();

    setState(() {
      _counter++;
    });
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Wallpaper Fluctuator',
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 3,
            child: Scaffold(
                appBar: AppBar(
                  title: Center(child: Text('Wallpaper Fluctuator')),
                  bottom: TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.add_photo_alternate_outlined)),
                      Tab(icon: Icon(Icons.access_alarms)),
                      Tab(icon: Icon(Icons.message_outlined)),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    Center(child: FolderPickingTab(this.sheepSkin)),
                    Center(child: SchedulingTab(this.sheepSkin)),
                    Center(child: DebugTab(this.sheepSkin)),
                  ],
                ))));
  }
}

/*
class PathLabel extends StatefulWidget {
  final String path;
  final _FolderPickingTabState optionsWidgetState;

  PathLabel(this.optionsWidgetState, this.path) {
    print('make PathLabel for ' + path);
  }

  void removePath() {
    sheepSkin.removePath(path);
  }

  @override
  State<StatefulWidget> createState() => _PathLabelState();
}

class _PathLabelState extends State<PathLabel> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    print('build() for ' + widget.path + ' vis=' + _visible.toString());

    return AnimatedOpacity(
        opacity: _visible ? 1.0 : 0.5,
        duration: Duration(seconds: 1),
        onEnd: () {
          print('fade ended for ' + widget.path);
          widget.removePath();
        },
        child: Flex(direction: Axis.horizontal, children: [
          Expanded(
              child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Container(
                      decoration: BoxDecoration(color: Colors.grey),
                      padding: EdgeInsets.all(8.0),
                      child: Text(widget.path)))),
          IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded),
              tooltip: 'Remove',
              onPressed: () {
                setState(() {
                  _visible = false;
                });
              })
        ]));
  }
}
*/
