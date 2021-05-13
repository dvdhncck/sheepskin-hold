import 'package:flutter/material.dart';

void main() {
  runApp(SheepSkin());
}

/// This is the main application widget.
class SheepSkin extends StatelessWidget {
  const SheepSkin({Key? key}) : super(key: key);

  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const Center(
          child: SheepskinSettingsWidget(),
        ),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class SheepskinSettingsWidget extends StatefulWidget {
  const SheepskinSettingsWidget({Key? key}) : super(key: key);

  @override
  State<SheepskinSettingsWidget> createState() =>
      _SheepskinSettingsWidgetState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _SheepskinSettingsWidgetState extends State<SheepskinSettingsWidget> {
  List<String> validTimeValues = <String>['1', '5', '10', '100'];
  List<String> validTimeUnits = <String>['Minutes', 'Hours', 'Days', 'Weeks'];
  String timeUnit = '5';
  String timeValue = '?';

  @override
  Widget build(BuildContext context) {
    timeValue = validTimeValues.first;
    timeUnit = validTimeUnits.first;

    var timeValueDropdown = DropdownButton<String>(
      value: timeValue,
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
          timeValue = newValue!;
        });
      },
      items: validTimeValues.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );

    var timeUnitDropdown = DropdownButton<String>(
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
    );

    var frequencyLine = Row(children: <Widget>[
      Text('Changes images every'),
      timeValueDropdown,
      timeUnitDropdown
    ]);

    var spaceCheckbox = Checkbox(
      onChanged: (bool? newValue) {
        setState(() {
          //timeUnit = newValue!;
        });
      },
      value: true,
    );

    var sourceLine = Row(children: <Widget>[
      Text('Get images from'),
      spaceCheckbox,
      IconButton(
        icon: const Icon(Icons.volume_up),
        tooltip: 'Pick locations',
        onPressed: () {
          setState(() {
            // Do a  thing
          });
        },
      ),
    ]);

    var lines = Column(children: <Widget>[frequencyLine, sourceLine]);
    return lines;
  }
}
