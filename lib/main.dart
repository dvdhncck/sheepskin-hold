// @dart=2.9

import 'dart:io';

import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import "dart:math";

var outerLimits = OuterLimits();

SheepSkin sheepSkin = SheepSkin(outerLimits);

void main() {

  runApp(outerLimits);
}

//var sheepSkinOptionsWidget = SheepSkinOptionsWidget();

void periodicTaskCallback() {
  print('hello sailor');
//  if (schedulingWidgetState != null) {
  // look like we were called before the rest of the application had initialized
  //sheepSkinSchedulingWidgetState.doPeriodicUpdate();
  //}
}

class SheepSkin {
  _FolderPickingTabState folderPickingWidgetState;
  _SchedulingTabState schedulingWidgetState;
  _DebugTabState debugWidgetState;

  String timeValue;
  String timeUnit;
  String destination;

  DateTime lastUpdateTimestamp;

  List<String> validTimeValues = <String>['1', '5', '10', '100'];
  List<String> validTimeUnits = <String>['minutes', 'hours', 'days', 'weeks'];
  List<String> validDestinations = <String>[
    'Home screen',
    'Lock screen',
    'Both'
  ];

  List<String> paths;

  String imageCount = 'No images selected';

  var workManager = Workmanager();

  OuterLimits outerLimits;

  SheepSkin(this.outerLimits) {
    overlayDefaultValues();
    loadState();

    workManager.initialize(periodicTaskCallback, isInDebugMode: false);

    workManager.registerPeriodicTask(
      "update",
      "kindly do an update",
      frequency: Duration(minutes: 15),
    );

    addMessage('Started');
  }

  List<String> messageList = [];

  void addMessage(String message) {
    messageList.add(message);
    debugWidgetState.rebuild();
  }

  void doPeriodicUpdate() {
    changeWallpaper();

    // setState(() {
    //   //lastUpdateTimestamp = DateTime.now();
    // });

    // workManager.executeTask((taskName, inputData) {
    //   switch (taskName) {
    //     case "":
    //       changeWallpaper();
    //       setState(() {
    //         lastUpdateTimestamp = DateTime.now();
    //       });
    //       break;
    //   }
    //   return Future.value(true);
    // });
  }

  void displayFilePickerForFolderSelection() async {
    try {
      String path = await FilePicker.platform.getDirectoryPath();
      addPath(path);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
  }

  void addPath(String path) {
    if (path != null) {
      // avoid duplicates
      if (paths.contains(path)) {
        return;
      }
      paths.add(path);
      onPathChanged();
    }
  }

  void removePath(String path) {
    if (path != null) {
      paths.remove(path);
      onPathChanged();
    }
  }

  void onPathChanged() async {
    var count = 0;
    var unreadable = 0;
    for (final path in paths) {
      Directory dir = Directory(path);
      try {
        List<FileSystemEntity> entities =
        await dir.list(recursive: true).toList();
        // print(entities);
        for (var entity in entities) {
          if (entity is File) {
            print(lookupMimeType(entity.path));
            //(entity as File).readAsStringSync();
            count++;
          }
        }
      } catch (e) {
        print(e);
        unreadable++;
      }
    }

    imageCount =
        count.toString() + " files in " + paths.length.toString() + " folders";

    if (unreadable > 0) {
      imageCount += "(some bad)";
    }

    folderPickingWidgetState.rebuild();

    print("onPathChanged() completed, saving state.");

    persistState();

    folderPickingWidgetState.rebuild();
  }

  void onScheduleChanged() async {
    persistState();
  }

  Future<String> pickImage() async {
    List<File> candidates = [];
    for (final path in paths) {
      Directory dir = Directory(path);
      List<FileSystemEntity> entities =
      await dir.list(recursive: true).toList();
      // print(entities);
      for (var entity in entities) {
        if (entity is File) {
          String mimeType = lookupMimeType(entity.path);
          if (mimeType.startsWith('image/')) {
            candidates.add(entity);
          }
        }
      }
    }
    final _random = new Random();
    var theChosenOne = candidates[_random.nextInt(candidates.length)];
    return theChosenOne.path;
  }

  int decodeDestination() {
    switch (destination) {
      case 'Home screen':
        return WallpaperManager.HOME_SCREEN;
      case 'Lock screen':
        return WallpaperManager.LOCK_SCREEN;
      default:
        return WallpaperManager.BOTH_SCREENS;
    }
  }

  void changeWallpaper() async {
    outerLimits.showSnackBar();
    String wallpaper = await pickImage();
    int location = decodeDestination();
    try {
      await WallpaperManager.setWallpaperFromFile(wallpaper, location);
    } on PlatformException catch (e) {
      print('Failed to get wallpaper: ' + e.toString());
    }
    ScaffoldMessengerState().removeCurrentSnackBar();
  }

  void overlayDefaultValues() {
    if (paths == null) {
      paths = [];
    }
    if (timeValue == null) {
      timeValue = '1';
    }
    if (timeUnit == null) {
      timeUnit = 'days';
    }
    if (destination == null) {
      destination = 'Home screen';
    }
  }

  void persistState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fluctuator.destination', destination);
    prefs.setString('fluctuator.timeValue', timeValue);
    prefs.setString('fluctuator.timeUnit', timeUnit);
    prefs.setStringList('fluctuator.paths', paths);
  }

  void loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      destination = prefs.getString('fluctuator.destination');
      timeValue = prefs.getString('fluctuator.timeValue');
      timeUnit = prefs.getString('fluctuator.timeUnit');
      paths = prefs.getStringList('fluctuator.paths');
    } finally {
      overlayDefaultValues();
    }
  }
}

//final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

class OuterLimits extends StatelessWidget {

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
                    Center(child: FolderPickingTab(sheepSkin)),
                    Center(child: SchedulingTab(sheepSkin)),
                    Center(child: DebugTab(sheepSkin)),
                  ],
                ))));
  }

  void showSnackBar() {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: const Text('Setting wallpaper...'),
    //   duration: const Duration(seconds: 2),
    // ));
  }
}

class FolderPickingTab extends StatefulWidget {
  const FolderPickingTab(SheepSkin sheepSkin, {Key key}) : super(key: key);

  @override
  State<FolderPickingTab> createState() {
    sheepSkin.folderPickingWidgetState = _FolderPickingTabState(sheepSkin);
    return sheepSkin.folderPickingWidgetState;
  }
}

class SchedulingTab extends StatefulWidget {
  const SchedulingTab(SheepSkin sheepSkin, {Key key}) : super(key: key);

  @override
  State<SchedulingTab> createState() {
    sheepSkin.schedulingWidgetState = _SchedulingTabState(sheepSkin);
    return sheepSkin.schedulingWidgetState;
  }
}

class DebugTab extends StatefulWidget {
  const DebugTab(SheepSkin sheepSkin, {Key key}) : super(key: key);

  @override
  State<DebugTab> createState() {
    sheepSkin.debugWidgetState = _DebugTabState(sheepSkin);
    return sheepSkin.debugWidgetState;
  }
}

class _SchedulingTabState extends State<SchedulingTab> {
  final SheepSkin sheepSkin;

  _SchedulingTabState(this.sheepSkin);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];

    print("_SchedulingTabState.build() starts.");

    rows.add(Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Every')),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: sheepSkin.timeValue,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                sheepSkin.timeValue = newValue;
                //onScheduleChanged();
              });
            },
            items: sheepSkin.validTimeValues
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: sheepSkin.timeUnit,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                sheepSkin.timeUnit = newValue;
                //onScheduleChanged();
              });
            },
            items: sheepSkin.validTimeUnits
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
    ]));

    rows.add(Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Change')),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: sheepSkin.destination,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                sheepSkin.destination = newValue;
                //onScheduleChanged();
              });
            },
            items: sheepSkin.validDestinations
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
    ]));

    var updateInfo = "last update: " +
        (sheepSkin.lastUpdateTimestamp == null
            ? '[never]'
            : sheepSkin.lastUpdateTimestamp.toString());

    rows.add(Row(children: [
      Expanded(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(8.0), child: Text(updateInfo)))),
    ]));

    rows.add(Row(children: [
      Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    sheepSkin.changeWallpaper();
                  },
                  child: Text('Change wallpaper now')))),
    ]));

    return Column(children: rows);
  }

  void rebuild() {
    setState(() => {});
  }
}

class _DebugTabState extends State<DebugTab> {
  final SheepSkin sheepSkin;

  _DebugTabState(this.sheepSkin);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];

    int counter = 1000; // for generating fake paths

    rows.add(Row(children: [
      Padding(
          padding: EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                sheepSkin.folderPickingWidgetState.rebuild();
                sheepSkin.schedulingWidgetState.rebuild();
              },
              child: Text('refresh'))),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                counter++;
                String newPath = 'folder' + counter.toString();
                while (sheepSkin.paths.contains(newPath)) {
                  counter++;
                  newPath = 'folder' + counter.toString();
                }
                sheepSkin.addPath(newPath);
              },
              child: Text('+path'))),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                periodicTaskCallback();
              },
              child: Text('poke')))
    ]));

    if(sheepSkin.messageList != null) {
      for (var message in sheepSkin.messageList) {
        rows.add(Expanded(
            child: Center(
                child: Padding(
                    padding: EdgeInsets.all(8.0), child: Text(message)))));
      }
    }

    return Column(children: rows);
  }

  void rebuild() {
    setState(() => {});
  }
}

class _FolderPickingTabState extends State<FolderPickingTab> {
  final SheepSkin sheepSkin;

  _FolderPickingTabState(this.sheepSkin);

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];

    print("build() starts.");

    if (sheepSkin.paths.length > 0) {
      rows.add(Row(children: [
        Expanded(
            child: Center(
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(sheepSkin.imageCount)))),
      ]));
    }

    print("build() there are " + sheepSkin.paths.length.toString() + " paths.");

    for (final String path in sheepSkin.paths) {
      rows.add(getLabel(path));
    }

    rows.add(Row(children: [
      Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    sheepSkin.displayFilePickerForFolderSelection();
                  },
                  child: Text('Add image folder')))),
    ]));

    /*
    rows.add(Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Every')),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: sheepSkin.timeValue,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                sheepSkin.timeValue = newValue;
                sheepSkin.onScheduleChanged();
              });
            },
            items:
              sheepSkin.validTimeValues.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: sheepSkin.timeUnit,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                sheepSkin.timeUnit = newValue;
                sheepSkin.onScheduleChanged();
              });
            },
            items: sheepSkin.validTimeUnits.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
    ]));

    rows.add(Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Change')),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: sheepSkin.destination,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                sheepSkin.destination = newValue;
                sheepSkin.onScheduleChanged();
              });
            },
            items:
            sheepSkin.validDestinations.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
    ]));

    if (sheepSkin.paths.length > 0) {
      var updateInfo = "last update: " +
          (sheepSkin.lastUpdateTimestamp == null
              ? '[never]'
              : sheepSkin.lastUpdateTimestamp.toString());
      rows.add(Row(children: [
        Expanded(
            child: Center(
                child: Padding(
                    padding: EdgeInsets.all(8.0), child: Text(updateInfo)))),
      ]));
    }
    */

    return Column(children: rows);
  }

  void rebuild() {
    setState(() => {});
  }
}

Widget getLabel(String thePath) {
  return Flex(direction: Axis.horizontal, children: [
    Expanded(
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(color: Colors.grey),
                padding: EdgeInsets.all(8.0),
                child: Text(thePath)))),
    IconButton(
        icon: const Icon(Icons.remove_circle_outline_rounded),
        tooltip: 'Remove',
        onPressed: () {
          sheepSkin.removePath(thePath);
        })
  ]);
}

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
