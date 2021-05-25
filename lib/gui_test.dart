// @dart=2.9

import 'package:flutter/material.dart';

import 'model.dart';
import 'sheepskin.dart';

class GuiTestTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const GuiTestTab(this.sheepSkin);

  @override
  State<GuiTestTab> createState() {
    return _GuiTestTabState();
  }
}

class _GuiTestTabState extends State<GuiTestTab> {
  var nRows = 15;
  var rowHeight;
  var columnWidth;

  static const bendy = Radius.circular(12.0);

  Widget build(BuildContext context) {
    rowHeight = MediaQuery.of(context).size.height / nRows;
    columnWidth = MediaQuery.of(context).size.width * 0.9;

    var every = Column(children: [
      Padding(
          padding: EdgeInsets.all(10.0),
          child: makeHeading('Change how often?')),
      Padding(
          padding: EdgeInsets.all(4.0),
          child: makeButtockGrid(
            TimeValue.iterable(),
            widget.sheepSkin.getTimeValue(),
            4,
            100,
            widget.sheepSkin.setTimeValue,
          )),
      Padding(
          padding: EdgeInsets.all(4.0),
          child: makeButtockGrid(
            TimeUnit.iterable(),
            widget.sheepSkin.getTimeUnit(),
            4,
            100,
            widget.sheepSkin.setTimeUnit,
          ))
    ]);

    var change = Column(children: [
      Padding(
          padding: EdgeInsets.all(10.0), child: makeHeading('Change what?')),
      Padding(
          padding: EdgeInsets.all(4.0),
          child: makeButtockGrid(
              Destination.iterable(),
              widget.sheepSkin.getDestination(),
              2,
              200,
              widget.sheepSkin.setDestination)),
    ]);

    var eC = Container(
        child: every,
        constraints: BoxConstraints(
            minHeight: rowHeight * 4,
            maxHeight: rowHeight * 6,
            maxWidth: columnWidth,
            minWidth: columnWidth));

    var cC = Container(
        child: change,
        constraints: BoxConstraints(
            minHeight: rowHeight * 2,
            maxHeight: rowHeight * 3,
            maxWidth: columnWidth,
            minWidth: columnWidth));

    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [eC, cC]);
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

  Widget makeButtockGrid(Iterable<ListyEnum> options, ListyEnum selected,
      int columns, double itemWidth, Function setter) {
    List<ListyEnum> optionsList = List<ListyEnum>.from(options);
    int index = 0;
    int rows = (optionsList.length / columns).ceil();
    List<Widget> column = [];

    BoxConstraints buttonSize =
        BoxConstraints(minWidth: itemWidth);

    int maxC = columns - 1;
    int maxR = rows - 1;

    for (var r = 0; r < rows; r++) {
      List<Widget> thisRow = [];
      for (var c = 0; c < columns; c++) {
        ListyEnum item =
            index < optionsList.length ? optionsList[index++] : null;
        thisRow.add(AnimatedContainer(
            duration: Duration(milliseconds: 333),
            decoration: makeBorder(c, maxC, r, maxR, item == selected),
            constraints: buttonSize,
            padding: makePadding(c, maxC, r, maxR),
            child: TextButton(
                child: Text(item.label(),
                    textAlign: TextAlign.center,
                    style: getTextStyle(item == selected)),
                onPressed: () => {
                      setState(() {
                        setter(item);
                      })
                    })));
      }
      column.add(Flexible(fit: FlexFit.loose, child: Row(children: thisRow)));
    }

    var inner = Column(mainAxisSize: MainAxisSize.min, children: column);

    // var control =
    //     Container(, child: inner);

    var outerDecoration = BoxDecoration(
        color: Colors.blueAccent,
        border: Border.all(width: 1.0, color: Colors.blueAccent),
        borderRadius: BorderRadius.all(bendy));

    return Container(
        constraints: BoxConstraints(maxWidth: itemWidth * columns + 4),
        padding: EdgeInsets.all(1.0),
        decoration: outerDecoration,
        child: inner);
  }

  EdgeInsets makePadding(int c, int maxC, int r, int maxR) {
    // return EdgeInsets.only(
    //   bottom: 5.0
    // );
    return EdgeInsets.all(6.0);
  }

  BoxDecoration makeBorder(int c, int maxC, int r, int maxR, bool selected) {
    const l1Rad = BorderRadius.only(topLeft: bendy, bottomLeft: bendy);
    const r1Rad = BorderRadius.only(topRight: bendy, bottomRight: bendy);

    const tlRad = BorderRadius.only(topLeft: bendy);
    //const tmRad = null;
    const trRad = BorderRadius.only(topRight: bendy);

    const blRad = BorderRadius.only(bottomLeft: bendy);
    //const bmRad = null;
    const brRad = BorderRadius.only(bottomRight: bendy);

    /*const tlBdr = Border(
      bottom: BorderSide(width: 1.0, color: Colors.blueAccent),
      //left: BorderSide(width: 1.0, color: Colors.blueAccent),
    );
    const tmBdr = Border(
      bottom: BorderSide(width: 1.0, color: Colors.blueAccent),
      left: BorderSide(width: 1.0, color: Colors.blueAccent),
    );
    const trBdr = Border(
      bottom: BorderSide(width: 1.0, color: Colors.blueAccent),
      left: BorderSide(width: 1.0, color: Colors.blueAccent),
    );
    const blBdr = Border(
        //bottom: BorderSide(width: 1.0, color: Colors.blueAccent),
        //left: BorderSide(width: 1.0, color: Colors.blueAccent),
        );
    const bmBdr = Border(
      //bottom: BorderSide(width: 1.0, color: Colors.blueAccent),
      left: BorderSide(width: 1.0, color: Colors.blueAccent),
    );
    const brBdr = Border(
      //bottom: BorderSide(width: 1.0, color: Colors.blueAccent),
      left: BorderSide(width: 1.0, color: Colors.blueAccent),
    );
    */

    var rad;// = r == 0 ? tmRad : bmRad;
    // var bdr = r == 0 ? tmBdr : bmBdr;

    if (c == 0 && r == 0) {
      rad = tlRad;
      //bdr = tlBdr;
    }
    if (c == maxC && r == 0) {
      rad = trRad;
      //bdr = trBdr;
    }
    if (c == 0 && r == maxR) {
      rad = blRad;
      //bdr = blBdr;
    }
    if (c == maxC && r == maxR) {
      rad = brRad;
      //bdr = brBdr;
    }
    if (maxR == 0 && c == 0) {
      rad = l1Rad;
    }
    if (maxR == 0 && c == maxC) {
      rad = r1Rad;
    }

    // const yes = BorderSide(width: 1.0, color: Colors.blueAccent);
    // const no = BorderSide(width: 1.0, color: Colors.white);
    //
    // var bdr = Border(
    //     left: c > 0 ? yes : no,
    //     bottom: maxR > 0 && r < maxR ? yes : no
    // );

    // var border = Border.all(color: Colors.blueAccent);

    return BoxDecoration(
        color: selected ? Colors.blueAccent : Colors.white,
        borderRadius: rad);
  }

  //   return Container(

  // Widget makeButton(ListyEnum item, bool selected, Function setter) {
  //       constraints: BoxConstraints.expand(height: rowHeight),
  //       decoration: makeBorder(selected),
  //       child: TextButton(
  //         child: Text(item.label(),
  //             textAlign: TextAlign.center, style: getTextStyle(selected)),
  //         onPressed: () => {
  //           setState(() {
  //             setter(item);
  //           })
  //         },
  //       ));
  // }

  TextStyle getTextStyle(bool selected) {
    const selectedStyle = TextStyle(color: Colors.white);
    const unselectedStyle = TextStyle(color: Colors.blueAccent);
    return selected ? selectedStyle : unselectedStyle;
  }

// BoxDecoration makeBorder(bool selected) {
//   const selectedDecoration = BoxDecoration(
//     color: Colors.blueAccent,
//     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//   );
//
//   const unselectedDecoration = BoxDecoration(
//     color: Colors.white54,
//     borderRadius: BorderRadius.all(Radius.circular(10.0)),
//     border: Border(
//       top: BorderSide(width: 1.0, color: Colors.blueAccent),
//       left: BorderSide(width: 1.0, color: Colors.blueAccent),
//       right: BorderSide(width: 1.0, color: Colors.blueAccent),
//       bottom: BorderSide(width: 1.0, color: Colors.blueAccent),
//     ),
//   );
//
//   return selected ? selectedDecoration : unselectedDecoration;
// }
}
