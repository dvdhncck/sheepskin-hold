// @dart=2.9

import 'package:flutter/material.dart';

import 'sheepskin.dart';

class SchedulingTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const SchedulingTab(this.sheepSkin);

  @override
  State<SchedulingTab> createState() {
    return _SchedulingTabState(sheepSkin);
  }
}

class _SchedulingTabState extends State<SchedulingTab> {
  final SheepSkin sheepSkin;

  _SchedulingTabState(this.sheepSkin);

  @override
  Widget build(BuildContext context) {
    var updateInfo = "last update: " +
        (sheepSkin.lastUpdateTimestamp == null
            ? '[never]'
            : sheepSkin.lastUpdateTimestamp.toString());

    var timeControls = Row(children: [
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
              });
              sheepSkin.onScheduleChanged();
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
              });
              sheepSkin.onScheduleChanged();
            },
            items: sheepSkin.validTimeUnits
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
    ]);

    var destinationControls = Row(children: [
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
              });
              sheepSkin.onScheduleChanged();
            },
            items: sheepSkin.validDestinations
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
    ]);

    var updateLabel = Row(children: [
      Expanded(
          child: Center(
              child: Padding(
                  padding: EdgeInsets.all(8.0), child: Text(updateInfo)))),
    ]);

    var upper =
    Column(children: [updateLabel, destinationControls, timeControls]);

    var buttonBar = Row(children: [
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
    ]);

    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [upper, buttonBar]);
  }
}
