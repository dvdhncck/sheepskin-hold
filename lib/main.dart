// @dart=2.9

import 'dart:io';

import 'package:mime/mime.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import "dart:math";

final SheepSkin sheepSkin = SheepSkin();

void main() {
  runApp(sheepSkin.outerLimits);
}

void periodicTaskCallback() {
  print('hello sailor');
  sheepSkin.doPeriodicUpdate();
}

class LogMessage {
  String timestamp;
  String message;

  LogMessage(this.timestamp, this.message);
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

  final DateFormat formatter = DateFormat('yyyy-MM-dd H:m:s');
  final List<LogMessage> logEntryList = [];

  SheepSkin() {
    outerLimits = new OuterLimits(this);
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

  void addMessage(String message) {
    var dateTime = DateTime.now();
    final String formatted = formatter.format(dateTime);

    print(formatted + " : " + message);

    logEntryList.add(LogMessage(formatted, message));
  }

  void doPeriodicUpdate() {
    addMessage('doPeriodicUpdate');
    changeWallpaper();
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

    // print("onPathChanged() completed, saving state.");

    persistState();
  }

  void onScheduleChanged() async {
    persistState();
  }

  Future<String> pickImage() async {
    List<File> candidates = [];
    for (final path in paths) {
      try {
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
      } catch (e) {
        print(e);
      }
    }
    if (candidates.isEmpty) {
      return null;
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
    String wallpaper = await pickImage();
    if (wallpaper == null) {
      addMessage('Unable to find any images');
      return;
    }
    int location = decodeDestination();
    try {
      addMessage('Setting wallpaper on ' + destination);
      await WallpaperManager.setWallpaperFromFile(wallpaper, location);
      ScaffoldMessengerState().removeCurrentSnackBar();
    } on PlatformException catch (e) {
      addMessage('Failed to get wallpaper: ' + e.toString());
    }
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
  final SheepSkin sheepSkin;

  OuterLimits(this.sheepSkin);

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

class FolderPickingTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const FolderPickingTab(this.sheepSkin);

  @override
  State<FolderPickingTab> createState() {
    sheepSkin.folderPickingWidgetState = _FolderPickingTabState(sheepSkin);
    return sheepSkin.folderPickingWidgetState;
  }
}

class SchedulingTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const SchedulingTab(this.sheepSkin);

  @override
  State<SchedulingTab> createState() {
    sheepSkin.schedulingWidgetState = _SchedulingTabState(sheepSkin);
    return sheepSkin.schedulingWidgetState;
  }
}

class DebugTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const DebugTab(this.sheepSkin);

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
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Setting wallpaper...'),
                      duration: const Duration(seconds: 2),
                    ));
                    sheepSkin.changeWallpaper();
                  },
                  child: Text('Change wallpaper now')))),
    ]));

    return Column(children: rows);
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
                counter++;
                String newPath = 'folder' + counter.toString();
                while (sheepSkin.paths.contains(newPath)) {
                  counter++;
                  newPath = 'folder' + counter.toString();
                }
                setState(() {
                  sheepSkin.addMessage('adding fake folder ' + newPath);
                });
                sheepSkin.addPath(newPath);
              },
              child: Text('+path'))),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: TextButton(
              onPressed: () {
                setState(() {
                  sheepSkin.addMessage('poking...');
                });
                periodicTaskCallback();
              },
              child: Text('poke')))
    ]));

    if (sheepSkin.logEntryList != null) {
      for (var logEntry in sheepSkin.logEntryList) {
        rows.add(Align(
            alignment: Alignment.topLeft,
            child: Column(children: [
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: logEntry.timestamp,
                        style:
                            TextStyle(fontSize: 14.0, color: Colors.blueGrey))
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: logEntry.message,
                        style: TextStyle(fontSize: 18.0, color: Colors.black)),
                  ],
                ),
              )
            ])));
      }
    }

    return Column(children: rows);
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
      //rows.add(getLabel(path, (p) => sheepSkin.removePath(p)));
      rows.add(Flex(direction: Axis.horizontal, children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Container(
                    decoration: BoxDecoration(color: Colors.grey),
                    padding: EdgeInsets.all(8.0),
                    child: Text(path)))),
        IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded),
            tooltip: 'Remove',
            onPressed: () {
              setState(() {
                sheepSkin.removePath(path);
              });
            })
      ]));
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

    return Column(children: rows);
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
