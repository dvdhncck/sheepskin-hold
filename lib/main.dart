// @dart=2.9

import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:sheepskin/sheepskin.dart';

import "folder_picker.dart";
import "scheduler_options.dart";
import "debug_helper.dart";

final ReceivePort port = ReceivePort(); // for talking to the isolate
const String isolateName = 'sheepskin';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // IsolateNameServer.registerPortWithName(
  //   port.sendPort,
  //   isolateName,
  // );

  runApp(OuterLimitsState());
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

  var schedulingTab; // this is the only bit of the UI that needs repainting

  @override
  void initState() {
    super.initState();

    sheepSkin = SheepSkin(onStateUpdate);
  }

  // callback when the state has been changed by something other than the UI
  void onStateUpdate() {
    if(schedulingTab != null) {
      schedulingTab.setState(() {
        print('state update');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (sheepSkin == null) {
      // we are still loading the sheepSkin state... display a holding thing
      return MaterialApp(
          title: 'Wallpaper Fluctuator',
          debugShowCheckedModeBanner: false,
          home: Text('hai'));
    }

    schedulingTab = SchedulingTab(sheepSkin);

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
                    Center(child: FolderPickingTab(sheepSkin)),
                    Center(child: schedulingTab),
                    Center(child: DebugTab(sheepSkin)),
                  ],
                ))));
  }
}
