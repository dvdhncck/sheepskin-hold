// @dart=2.9

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheepskin/sheepskin.dart';
import 'package:sheepskin/sheepstate.dart';

import "folder_picker.dart";
import 'model.dart';
import "scheduler_options.dart";
import "message_log_view.dart";

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

void _sanityCheck() async {
  final DateTime now = DateTime.now();

  // final int isolateId = Isolate.current.hashCode;
  // print("[$now] Hello, world! isolate=${isolateId} function='$_sanityCheck'");

  await SharedPreferences.getInstance().then((prefs) async {
    await prefs.reload().then((_) {
      if (prefs.containsKey('timeValue') && prefs.containsKey('timeUnit')) {
        var timeValue = TimeValue.from(prefs.getString('timeValue'));
        var timeUnit = TimeUnit.from(prefs.getString('timeUnit'));
        print('debug: $now ${timeValue.label()} ${timeUnit.label()}');
        SheepState(prefs).log("Debug Heartbeat", "The world is still here");
      }
    });
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize().then((value) async {
    // TODO: this is for debug only, not used for real alarm
    // await AndroidAlarmManager.periodic(
    //         const Duration(seconds: 15), 1234, _sanityCheck,
    //         exact: true)
    //     .then((value) => print('alarm status: $value'));

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

    // periodically reload the shared preferences.
    //
    // this is required because they might have been updated by the
    // background isolate (which updates the last- and next- change
    // values,and potentially appends a log messages)
    Timer.periodic(Duration(seconds: 15), (timer) async {
      await SharedPreferences.getInstance().then((prefs) async {
        await prefs.reload().then((_) {
          setState(() => sheepSkin.sheepState = SheepState(prefs));
        });
      });
    });
  }

  // callback to be invoked when the state has been
  // changed by something other than the UI
  void onStateUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (sheepSkin == null || sheepSkin.sheepState == null) {
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
