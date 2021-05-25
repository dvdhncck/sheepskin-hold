// @dart=2.9

import 'package:flutter/material.dart';

import 'model.dart';
import 'sheepskin.dart';

class SchedulingTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const SchedulingTab(this.sheepSkin);

  @override
  State<SchedulingTab> createState() {
    return _SchedulingTabState();
  }
}

class _SchedulingTabState extends State<SchedulingTab> {
  var nRows = 15;
  var rowHeight;

  Widget build(BuildContext context) {
    rowHeight = MediaQuery.of(context).size.height / nRows;

    var lastUpdated = Row(children: [
      Padding(padding: EdgeInsets.all(4.0), child: makeLabel('Last Update')),
      Padding(
          padding: EdgeInsets.all(4.0),
          child: makeValue(widget.sheepSkin.getLastChangeAsText()))
    ]);

    var nextUpdate = Row(children: [
      Padding(padding: EdgeInsets.all(4.0), child: makeLabel('Next Update')),
      Padding(
          padding: EdgeInsets.all(4.0),
          child: makeValue(widget.sheepSkin.getNextChangeAsText()))
    ]);

    var every = Column(children: [
      Padding(padding: EdgeInsets.all(4.0), child: makeHeading('Every')),
      Padding(
          padding: EdgeInsets.all(4.0),
          child: makeGridPick(
            TimeValue.iterable(),
            widget.sheepSkin.getTimeValue(),
            4,
            widget.sheepSkin.setTimeValue,
          )),
      Padding(
          padding: EdgeInsets.all(4.0),
          child: makeGridPick(
            TimeUnit.iterable(),
            widget.sheepSkin.getTimeUnit(),
            4,
            widget.sheepSkin.setTimeUnit,
          ))
    ]);

    var change = Column(children: [
      Padding(padding: EdgeInsets.all(4.0), child: makeHeading('Change')),
      Padding(
          padding: EdgeInsets.all(4.0),
          child: makeGridPick(
            Destination.iterable(),
            widget.sheepSkin.getDestination(),
            4,
            widget.sheepSkin.setDestination,
          ))
    ]);

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
                    widget.sheepSkin.requestImmediateChange(() =>
                        {ScaffoldMessengerState().removeCurrentSnackBar()});
                  },
                  child: Text('Change wallpaper now'))))
    ]);

    var upper = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              constraints: BoxConstraints(minHeight: rowHeight),
              child: lastUpdated),
          Container(
              constraints: BoxConstraints(minHeight: rowHeight),
              child: nextUpdate),
          Container(child: every),
          Container(child: change),
        ]);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [upper, buttonBar]);
  }

  Text makeHeading(String text) {
    const labelStyle =
        TextStyle(color: Colors.black54, fontWeight: FontWeight.bold);
    return Text(text, style: labelStyle, textScaleFactor: 1.4);
  }

  Text makeLabel(String text) {
    const labelStyle =
        TextStyle(color: Colors.black54, fontStyle: FontStyle.italic);
    return Text(text, style: labelStyle, textScaleFactor: 1.2);
  }

  Text makeValue(String text) {
    return Text(text, textScaleFactor: 1.2);
  }

  Widget makeGridPick(Iterable<ListyEnum> options, ListyEnum selected,
      int columns, Function setter) {
    var children = options
        .map((listyEnum) => Container(
            padding: const EdgeInsets.all(6),
            child: Center(
                child: makeButton(listyEnum, listyEnum == selected, setter))))
        .toList();

    var nRows = 1 + children.length / columns;

    return Container(
        //constraints: BoxConstraints(maxHeight: buttonHeight * nRows),
        constraints:
            BoxConstraints(minHeight: 20, maxHeight: rowHeight * nRows),
        child: GridView.count(
            crossAxisCount: columns,
            //padding: const EdgeInsets.all(5),
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            children: children));
  }

  Widget makeButton(ListyEnum item, bool selected, Function setter) {
    return Container(
        constraints: BoxConstraints.expand(height: rowHeight),
        decoration: makeBorder(selected),
        child: TextButton(
          child: Text(item.label(),
              textAlign: TextAlign.center, style: getTextStyle(selected)),
          onPressed: () => {
            setState(() {
              setter(item);
            })
          },
        ));
  }

  TextStyle getTextStyle(bool selected) {
    const selectedStyle = TextStyle(color: Colors.white);
    const unselectedStyle = TextStyle(color: Colors.blueAccent);
    return selected ? selectedStyle : unselectedStyle;
  }

  BoxDecoration makeBorder(bool selected) {
    const selectedDecoration = BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
    );

    const unselectedDecoration = BoxDecoration(
      color: Colors.white54,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      border: Border(
        top: BorderSide(width: 1.0, color: Colors.blueAccent),
        left: BorderSide(width: 1.0, color: Colors.blueAccent),
        right: BorderSide(width: 1.0, color: Colors.blueAccent),
        bottom: BorderSide(width: 1.0, color: Colors.blueAccent),
      ),
    );

    return selected ? selectedDecoration : unselectedDecoration;
  }
}
