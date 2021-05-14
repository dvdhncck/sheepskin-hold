import 'dart:io';

/// Flutter code sample for DropdownButton

// This sample shows a `DropdownButton` with a large arrow icon,
// purple text style, and bold purple underline, whose value is one of "One",
// "Two", "Free", or "Four".
//
// ![](https://flutter.github.io/assets-for-api-docs/assets/material/dropdown_button.png)
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';

//import 'dead_file_picker.dart';

void main() {
  runApp(MaterialApp(
    title: 'SheepSkin - Wallpaper Fluctuator',
    debugShowCheckedModeBanner: false,
    home: OptionsRoute(),
  ));
}

class OptionsRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SheepSkin Settings'),
        ),
        body: Center(child: SheepSkinOptionsWidget()));
  }
}

class SheepSkinOptionsWidget extends StatefulWidget {
  const SheepSkinOptionsWidget({Key? key}) : super(key: key);

  @override
  State<SheepSkinOptionsWidget> createState() => _SheepSkinOptionsWidgetState();
}

class _SheepSkinOptionsWidgetState extends State<SheepSkinOptionsWidget> {
  List<String> validTimeValues = <String>['1', '5', '10', '100'];
  List<String> validTimeUnits = <String>['minutes', 'hours', 'days', 'weeks'];
  String timeValue = '1';
  String timeUnit = 'days';
  List<String> paths = [];
  String imageCount = 'No images selected';

  void pickFile() async {
    try {
      //String? _directoryPath = null;
      String? path = await FilePicker.platform.getDirectoryPath();

      if (path != null) {
        // avoid duplicates
        if(paths.contains(path)) {
          return;
        }
        paths.add(path);
        countImages();
      }
      setState(() {});
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
  }

  void removePath(String path) {
    paths.remove(path);
    countImages();
  }

  void countImages() async {
    var count = 0;
    for (final path in paths) {
      Directory dir = Directory(path);
      List<FileSystemEntity>? entities = await dir.list(recursive: true).toList();
      print(entities);
      for (var entity in entities) {
        if (entity is File) {
          //(entity as File).readAsStringSync();
          count++;
        }
      }
    }
    imageCount = count.toString() + " files in " + paths.length.toString() + " folders";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> rows = [];

    if (paths.length > 0) {
      rows.add(Row(children: [
        Expanded(
            child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(imageCount))),
      ]));
    }

    for (final path in paths) {
      var pathRow = Row(children: [
        Container(
            decoration:BoxDecoration(color: Colors.white54),
            child: Expanded(
                child:
                Padding(padding: EdgeInsets.all(8.0), child: Text(path)))),
        IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded),
            tooltip: 'Remove',
            onPressed: () {
              removePath(path);
            })
      ]);
      rows.add(AnimatedContainer(duration: Duration(seconds:1), child:pathRow));
    }

    rows.add(Row(children: [
      Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    pickFile();
                  },
                  child: Text('Add image folder...')))),
    ]));

    rows.add(Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Update every')),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: timeValue,
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                timeValue = newValue!;
              });
            },
            items:
            validTimeValues.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: timeUnit,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                timeUnit = newValue!;
              });
            },
            items: validTimeUnits.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ))
    ]));

    return Column(children: rows);
  }
}
