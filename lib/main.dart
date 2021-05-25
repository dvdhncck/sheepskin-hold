// @dart=2.9

import 'package:flutter/material.dart';
import 'package:sheepskin/sheepskin.dart';

import "folder_picker.dart";
import 'gui_test.dart';
import "scheduler_options.dart";
import "debug_helper.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          home: Text('hai'));
    }

    return MaterialApp(
        title: 'Wallpaper Fluctuator',
        debugShowCheckedModeBanner: false,
        home: DefaultTabController(
            length: 4,
            child: Scaffold(
                appBar: AppBar(
                  title: Center(child: Text('Wallpaper Fluctuator')),
                  bottom: TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.add_photo_alternate_outlined)),
                      Tab(icon: Icon(Icons.access_alarms)),
                      Tab(icon: Icon(Icons.message_outlined)),
                      Tab(icon: Icon(Icons.wb_sunny)),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    Center(child: FolderPickingTab(sheepSkin)),
                    Center(child: SchedulingTab(sheepSkin)),
                    Center(child: DebugTab(sheepSkin)),
                    Center(child: GuiTestTab(sheepSkin)),
                  ],
                ))));
  }
}
