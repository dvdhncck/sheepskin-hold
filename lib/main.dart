// @dart=2.9

import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheepskin/sheepskin.dart';

import "folder_picker.dart";
import 'gui_test.dart';
import 'model.dart';
import "scheduler_options.dart";
import "message_log_view.dart";

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void printHello() async {
  final DateTime now = DateTime.now();
  final int isolateId = Isolate.current.hashCode;
  print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");

  await SharedPreferences.getInstance().then((prefs) async {
    await prefs.reload().then((_) {
      if (prefs.containsKey('timeValue')
          && prefs.containsKey('timeUnit')) {
        var timeValue = TimeValue.from(prefs.getString('timeValue'));
        var timeUnit = TimeUnit.from(prefs.getString('timeUnit'));
        print('woofz: ${timeValue.label()} ${timeUnit.label()}');
      }
    });
  });

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize()
      .then((value) async {

        await AndroidAlarmManager.periodic(const Duration(seconds: 15), 1234, printHello, exact:true).then((value) => print('alarm status: $value'));

        runApp(OuterLimitsState());
      });
}

class OuterLimitsState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    var outerLimitsState = _OuterLimitsState();
    return outerLimitsState;
  }
}

class _OuterLimitsState extends State<OuterLimitsState> {
  SheepSkin sheepSkin;

  @override
  void initState() {
    super.initState();

    sheepSkin = SheepSkin(onStateUpdate);
  }

  // callback when the state has been changed by something other than the UI
  void onStateUpdate() {
    setState(() {
      //print('state update');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sheepSkin == null) {
      // we are still loading the sheepSkin state... display a holding thing
      return MaterialApp(
          title: 'Wallpaper Fluctuator',
          debugShowCheckedModeBanner: false,
          home: Text('Loading...'));
    }

    var tabs = [
      Tab(icon: Icon(Icons.add_photo_alternate_outlined)),
      Tab(icon: Icon(Icons.access_alarms)),
    ];
    var tabContents = [
      Center(child: FolderPickingTab(sheepSkin)),
      Center(child: SchedulingTab(sheepSkin)),
    ];

    if (sheepSkin.displayLogMessageViewer) {
      tabs.add(Tab(icon: Icon(Icons.message_outlined)));
      tabContents.add(Center(child: MessageLogViewTab(sheepSkin)));
    }
    if (sheepSkin.uiDebug) {
      tabs.add(Tab(icon: Icon(Icons.wb_sunny)));
      tabContents.add(Center(child: GuiTestTab(sheepSkin)));
    }

    return MaterialApp(
        title: 'Wallpaper Fluctuator',
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: tabs.length,
            child: Scaffold(
                appBar: AppBar(
                  title: TabBar(
                    tabs: tabs,
                  ),
                ),
                body: TabBarView(children: tabContents))));
  }
}
