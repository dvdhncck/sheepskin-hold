import 'package:flutter/material.dart';

import 'model.dart';
import 'sheepskin.dart';
import 'gui_parts.dart';

class SchedulingTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const SchedulingTab(this.sheepSkin);

  @override
  State<SchedulingTab> createState() {
    return _SchedulingTabState();
  }

  void toggleLogViewer() {
    sheepSkin.toggleLogMessageViewer();
  }
}

class _SchedulingTabState extends State<SchedulingTab> {
  var columnWidth;

  Widget build(BuildContext context) {
    if (widget.sheepSkin.sheepState.unready) {
      return SheepSkin.buildHoldingWidget();
    }

    columnWidth = MediaQuery.of(context).size.width;

    var lastUpdated =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: EdgeInsets.all(4), child: makeLabel('Last Update')),
      Padding(
          padding: EdgeInsets.all(4),
          child: makeValue(widget.sheepSkin.getLastChangeAsText()))
    ]);

    var nextUpdate =
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Padding(
          padding: EdgeInsets.all(4),
          child: GestureDetector(
              onLongPress: widget.sheepSkin.toggleLogMessageViewer,
              child: makeLabel('Next Update'))),
      Padding(
          padding: EdgeInsets.all(4),
          child: makeValue(widget.sheepSkin.getNextChangeAsText())),
    ]);

    var updateContainer = Padding(
        padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        child: Row(children: [lastUpdated, Spacer(), nextUpdate]));

    var everyContainer = Container(
        child: Column(children: [
          Padding(
              padding: EdgeInsets.all(10.0),
              child: makeHeading('Change how often?')),
          Padding(
              padding: EdgeInsets.all(4.0),
              child: makeButtockGrid(
                TimeValue.iterable(),
                widget.sheepSkin.getTimeValue(),
                columnWidth,
                4,
                (value) async {
                  widget.sheepSkin.sheepState.setTimeValue(value);
                  setState(() => {});
                },
              )),
          Padding(
              padding: EdgeInsets.all(4.0),
              child: makeButtockGrid(
                  TimeUnit.iterable(),
                  widget.sheepSkin.getTimeUnit(),
                  columnWidth,
                  TimeUnit.iterable().length, (unit) async {
                widget.sheepSkin.sheepState.setTimeUnit(unit);
                setState(() => {});
              }))
        ]),
        constraints:
            BoxConstraints(maxWidth: columnWidth, minWidth: columnWidth));

    var changeContainer = Container(
        child: Column(children: [
          Padding(
              padding: EdgeInsets.all(10.0),
              child: makeHeading('Change what?')),
          Padding(
              padding: EdgeInsets.all(4.0),
              child: makeButtockGrid(
                  Destination.iterable(),
                  widget.sheepSkin.getDestination(),
                  columnWidth,
                  2, (destination) async {
                widget.sheepSkin.sheepState.setDestination(destination);
                setState(() => {});
              }))
        ]),
        constraints: BoxConstraints(minWidth: columnWidth));

    var buttonBar = Row(children: [
      Expanded(
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Setting wallpaper...'),
                      duration: const Duration(seconds: 3),
                    ));
                    var width = MediaQuery
                        .of(context)
                        .size
                        .width;
                    var height = MediaQuery
                        .of(context)
                        .size
                        .height;
                    widget.sheepSkin.requestImmediateChange(width, height, () =>
                        {ScaffoldMessengerState().removeCurrentSnackBar()});
                  },
                  child: Text('Change wallpaper now'))))
    ]);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          updateContainer,
          everyContainer,
          changeContainer,
          buttonBar
        ]);
  }
}
