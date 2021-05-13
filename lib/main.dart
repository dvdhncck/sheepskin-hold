/// Flutter code sample for DropdownButton

// This sample shows a `DropdownButton` with a large arrow icon,
// purple text style, and bold purple underline, whose value is one of "One",
// "Two", "Free", or "Four".
//
// ![](https://flutter.github.io/assets-for-api-docs/assets/material/dropdown_button.png)

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    title: 'SheepSkin - Wallpaper Fluctuator',
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

class ImagePickerRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SheepSkin Settings'),
        ),
        body: Center(child: SheepSkinImagePickerWidget()));
  }
}

/// This is the stateful widget that the main application instantiates.
class SheepSkinOptionsWidget extends StatefulWidget {
  const SheepSkinOptionsWidget({Key? key}) : super(key: key);

  @override
  State<SheepSkinOptionsWidget> createState() => _SheepSkinOptionsWidgetState();
}

class SheepSkinImagePickerWidget extends StatefulWidget {
  const SheepSkinImagePickerWidget({Key? key}) : super(key: key);

  @override
  State<SheepSkinImagePickerWidget> createState() =>
      _SheepSkinImagePickerWidgetState();
}

class _SheepSkinImagePickerWidgetState
    extends State<SheepSkinImagePickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(8.0),
        child: TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('fish')));
  }
}

class _SheepSkinOptionsWidgetState extends State<SheepSkinOptionsWidget> {
  List<String> validTimeValues = <String>['1', '5', '10', '100'];
  List<String> validTimeUnits = <String>['minutes', 'hours', 'days', 'weeks'];
  String timeValue = '1';
  String timeUnit = 'days';

  @override
  Widget build(BuildContext context) {
    var locationRow = Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Pick images from ')),
      Expanded(
          flex: 2,
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImagePickerRoute()),
                    );
                  },
                  child: Text('fish')))),
    ]);
    var timeRow = Row(children: [
      Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Change the background every')),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: timeValue,
            icon: const Icon(Icons.arrow_downward),
            iconSize: 24,
            elevation: 16,
            style: const TextStyle(color: Colors.pink),
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
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
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
    ]);

    return Column(children: [locationRow, timeRow]);
  }
}
