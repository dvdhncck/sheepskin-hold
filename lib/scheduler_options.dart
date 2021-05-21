// @dart=2.9

import 'package:flutter/material.dart';

import 'sheepskin.dart';

class SchedulingTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const SchedulingTab(this. sheepSkin);

  @override
  State<SchedulingTab> createState() {
    return _SchedulingTabState();
  }
}

class _SchedulingTabState extends State<SchedulingTab> {
  @override
  Widget build(BuildContext context) {

    var timeControls = Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Every')),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: widget.sheepSkin.getTimeValue(),
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                widget.sheepSkin.setTimeValue(newValue);
              });
            },
            items: VALID_TIME_VALUES
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
            value: widget.sheepSkin.getTimeUnit(),
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                widget.sheepSkin.setTimeUnit(newValue);
              });
            },
            items: VALID_TIME_UNITS
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
    ]);

    var lastUpdated = widget.sheepSkin.getLastChange();
    var lastUpdatedRow = Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Last Updated')),
      Padding(padding: EdgeInsets.all(8.0), child: Text(lastUpdated))]);

    var nextUpdated = widget.sheepSkin.getNextChange();
    var nextUpdatedRow = Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Next Update')),
      Padding(padding: EdgeInsets.all(8.0), child: Text(nextUpdated))]);

    var destinationControls = Row(children: [
      Padding(padding: EdgeInsets.all(8.0), child: Text('Change')),
      Padding(
          padding: EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            value: widget.sheepSkin.getDestination(),
            icon: const Icon(Icons.arrow_drop_down),
            iconSize: 24,
            elevation: 16,
            onChanged: (String newValue) {
              setState(() {
                widget.sheepSkin.setDestination(newValue);
              });
            },
            items: VALID_DESTINATIONS
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )),
    ]);

    var upper = Column(children: [destinationControls, timeControls, lastUpdatedRow, nextUpdatedRow]);

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
                    widget.sheepSkin.changeWallpaper(() => { ScaffoldMessengerState().removeCurrentSnackBar() });
                  },
                  child: Text('Change wallpaper now')))),
    ]);

    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [upper, buttonBar]);
  }
}
