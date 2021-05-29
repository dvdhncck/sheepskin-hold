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
  var columnWidth;

  static const bendy = Radius.circular(12.0);

  Widget build(BuildContext context) {
    columnWidth = MediaQuery.of(context).size.width ;
    print("col is $columnWidth");

    var lastUpdated =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(padding: EdgeInsets.all(4), child: makeLabel('Last Update')),
      Padding(
          padding: EdgeInsets.all(4),
          child: makeValue(widget.sheepSkin.getLastChangeAsText()))
    ]);

    var nextUpdate =
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Padding(padding: EdgeInsets.all(4), child: makeLabel('Next Update')),
      Padding(
          padding: EdgeInsets.all(4),
          child: makeValue(widget.sheepSkin.getNextChangeAsText())),
    ]);

    var updateContainer =
        Padding(padding: EdgeInsets.fromLTRB(20,15,20,15), child: Row(
            children: [lastUpdated, Spacer(), nextUpdate]));

    // ---------


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
                4,
                widget.sheepSkin.setTimeValue,
              )),
          Padding(
              padding: EdgeInsets.all(4.0),
              child: makeButtockGrid(
                TimeUnit.iterable(),
                widget.sheepSkin.getTimeUnit(),
                4,
                widget.sheepSkin.setTimeUnit,
              ))
        ]),
        constraints: BoxConstraints(
            maxWidth: columnWidth,
            minWidth: columnWidth));

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
                  2,
                  widget.sheepSkin.setDestination)),
        ]),
        constraints: BoxConstraints(
            minWidth: columnWidth));

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

    var upper = Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          updateContainer,
          everyContainer,
          changeContainer,
        ]));

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

  EdgeInsets makePadding(int c, int maxC, int r, int maxR) {
    return EdgeInsets.all(6.0);
  }

  TextStyle getTextStyle(bool selected) {
    const selectedStyle = TextStyle(color: Colors.white);
    const unselectedStyle = TextStyle(color: Colors.blueAccent);
    return selected ? selectedStyle : unselectedStyle;
  }

  BoxDecoration makeBorder(int c, int maxC, int r, int maxR, bool selected) {
    var rad;

    if (c == 0 && r == 0) {
      rad = BorderRadius.only(topLeft: bendy);
    }
    if (c == maxC && r == 0) {
      rad = BorderRadius.only(topRight: bendy);
    }
    if (c == 0 && r == maxR) {
      rad = BorderRadius.only(bottomLeft: bendy);
    }
    if (c == maxC && r == maxR) {
      rad = BorderRadius.only(bottomRight: bendy);
    }
    if (maxR == 0 && c == 0) {
      rad = BorderRadius.only(topLeft: bendy, bottomLeft: bendy);
    }
    if (maxR == 0 && c == maxC) {
      rad = BorderRadius.only(topRight: bendy, bottomRight: bendy);
    }

    return BoxDecoration(
        color: selected ? Colors.blueAccent : Colors.white, borderRadius: rad);
  }

  Widget makeButtockGrid(Iterable<ListyEnum> options, ListyEnum selected,
      int columns, Function setter) {

    var itemWidth = (columnWidth - 40) / columns;

    List<ListyEnum> optionsList = List<ListyEnum>.from(options);
    int index = 0;
    int rows = (optionsList.length / columns).ceil();
    List<Widget> column = [];

    BoxConstraints buttonSize = BoxConstraints(minWidth: itemWidth);

    int maxC = columns - 1;
    int maxR = rows - 1;

    for (var r = 0; r < rows; r++) {
      if (r > 0 && r <= rows) {
        Widget filler = Container(
            color: Colors.blueAccent,
            constraints: BoxConstraints(
                minHeight: 2, maxHeight: 2, maxWidth: itemWidth * columns + 4));

        column.add(filler);
      }

      List<Widget> thisRow = [];
      for (var c = 0; c < columns; c++) {
        ListyEnum item =
            index < optionsList.length ? optionsList[index++] : null;

        var textButton = TextButton(
            child: Text(item.label(),
                textAlign: TextAlign.center,
                style: getTextStyle(item == selected)),
            onPressed: () => {
                  setState(() {
                    setter(item);
                  })
                });

        var buttonBox = Container(
          child: textButton,
          //color: Colors.blueAccent,
          padding: EdgeInsets.all(1.0),
        );

        thisRow.add(AnimatedContainer(
            duration: Duration(milliseconds: 333),
            decoration: makeBorder(c, maxC, r, maxR, item == selected),
            constraints: buttonSize,
            padding: EdgeInsets.all(6.0),
            child: buttonBox));

        if (c < maxC) {
          Widget filler = Container(
              constraints:
                  BoxConstraints(minHeight: 2, minWidth: 2, maxWidth: 2));

          thisRow.add(filler);
        }
      }
      column.add(Flexible(fit: FlexFit.loose, child: Row(children: thisRow)));
    }

    var inner = Column(mainAxisSize: MainAxisSize.min, children: column);

    var outerDecoration = BoxDecoration(
        color: Colors.blueAccent,
        border: Border.all(width: 1.0, color: Colors.blueAccent),
        borderRadius: BorderRadius.all(bendy));

    return Container(
        constraints:
            BoxConstraints(maxWidth: (2 * maxC) + (itemWidth * columns) + 4),
        padding: EdgeInsets.all(1.0),
        decoration: outerDecoration,
        child: inner);
  }
}
