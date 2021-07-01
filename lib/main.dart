import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheepskin/sheepskin.dart';

import "folder_picker.dart";
import "scheduler_options.dart";
import "message_log_view.dart";

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

/*
void _sanityCheck() async {
  final DateTime now = DateTime.now();

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
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize().then((value) async {

    /*
    // NOTE: this is for debug only, it is not required for functionality
    //
    // await AndroidAlarmManager.periodic(
    //         const Duration(seconds: 15), 1234, _sanityCheck,
    //         exact: true)
    //     .then((value) => print('alarm status: $value'));
    */

    runApp(OuterLimitsState());
  });
}

class OuterLimitsState extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _OuterLimitsState();
  }
}

class _OuterLimitsState extends State<OuterLimitsState> {

  late SheepSkin sheepSkin;

  _OuterLimitsState(){
    this.sheepSkin = SheepSkin(onStateUpdate);
  }

  @override
  void initState() {
    super.initState();

    // periodically reload the shared preferences.
    //
    // this is required because they can be updated by the background isolate
    // (which updates the last-change and next-change values, and can
    // add to the message log)
    Timer.periodic(Duration(seconds: 15), (timer) async {
      await SharedPreferences.getInstance().then((sharedPreferences) async {
        await sharedPreferences.reload().then((_) {
          setState(() => sheepSkin.sheepState.loadFrom(sharedPreferences));
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
    if (sheepSkin.sheepState.unready) {
      return SheepSkin.buildHoldingWidget();
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
