// @dart=2.9

import 'package:flutter/material.dart';

import 'model.dart';

const bendy = Radius.circular(12.0);

const uiColour = Color(0xff2196f3);

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

TextStyle getTextStyle(bool selected) {
  const selectedStyle = TextStyle(color: Colors.white);
  const unselectedStyle = TextStyle(color: uiColour);
  return selected ? selectedStyle : unselectedStyle;
}

BoxDecoration makeBorder(int c, int maxC, int r, int maxR, bool selected) {
  var rad;

  if (c == maxC && r == 0) {
    rad = BorderRadius.only(topRight: bendy);
  }
  if (c == 0 && r == 0) {
    if (maxC == 0) {
      rad = BorderRadius.only(topLeft: bendy, topRight: bendy);
    } else {
      rad = BorderRadius.only(topLeft: bendy);
    }
  }
  if (c == maxC && r == maxR) {
    rad = BorderRadius.only(bottomRight: bendy);
  }
  if (c == 0 && r == maxR) {
    if (maxC == 0) {
      rad = BorderRadius.only(bottomLeft: bendy, bottomRight: bendy);
    } else {
      rad = BorderRadius.only(bottomLeft: bendy);
    }
  }
  if (maxR == 0 && c == 0) {
    rad = BorderRadius.only(topLeft: bendy, bottomLeft: bendy);
  }
  if (maxR == 0 && c == maxC) {
    rad = BorderRadius.only(topRight: bendy, bottomRight: bendy);
  }
  if (maxR == 0 && maxC == 0 && c == 0 && r == 0) {
    rad = BorderRadius.all(bendy);
  }

  return BoxDecoration(
      color: selected ? uiColour : Colors.white, borderRadius: rad);
}

Widget makeListGrid(
    List<String> options, double columnWidth, Function(String) onRemove) {
  var itemWidth = columnWidth - 20;

  int rows = options.length;
  int maxR = rows - 1;

  List<Widget> columnChildren = [];

  BoxConstraints rowWidth = BoxConstraints(minWidth: itemWidth);

  for (var r = 0; r < rows; r++) {
    if (r > 0 && r <= rows) {
      Widget filler = Container(
          color: uiColour,
          constraints: BoxConstraints(
              minHeight: 2, maxHeight: 2, maxWidth: itemWidth + 4));

      columnChildren.add(filler);
    }

    var labelBox = Flexible(
        child: Container(
      constraints: BoxConstraints(maxWidth: itemWidth + 4),
      child: Text(options[r],
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: getTextStyle(false)),
      padding: EdgeInsets.all(4.0),
    ));

    var deleteButton = IconButton(
        icon: const Icon(Icons.remove_circle_outline_rounded),
        tooltip: 'Remove',
        onPressed: () => {onRemove(options[r])});

    columnChildren.add(AnimatedContainer(
        duration: Duration(milliseconds: 333),
        decoration: makeBorder(0, 0, r, maxR, false),
        constraints: rowWidth,
        child: Flex(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            direction: Axis.horizontal,
            children: [labelBox, deleteButton])));
  }

  var inner = Column(mainAxisSize: MainAxisSize.min, children: columnChildren);

  var outerDecoration = BoxDecoration(
      color: uiColour,
      border: Border.all(width: 1.0, color: uiColour),
      borderRadius: BorderRadius.all(bendy));

  return Container(
      constraints: BoxConstraints(maxWidth: itemWidth + 4),
      padding: EdgeInsets.all(1.0),
      decoration: outerDecoration,
      child: inner);
}

Widget makeButtockGrid(Iterable<ListyEnum> options, ListyEnum selected,
    double columnWidth, int columns, Function setter) {
  var itemWidth = (columnWidth - 20) / columns;

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
          color: uiColour,
          constraints: BoxConstraints(
              minHeight: 2, maxHeight: 2, maxWidth: itemWidth * columns + 4));

      column.add(filler);
    }

    List<Widget> thisRow = [];
    for (var c = 0; c < columns; c++) {
      ListyEnum item = index < optionsList.length ? optionsList[index++] : null;

      var buttonBox = Container(
        child: TextButton(
          child: Text(item.label(),
              textAlign: TextAlign.center,
              textScaleFactor: 0.9,
              style: getTextStyle(item == selected)),
          onPressed: () => {setter(item)}),
      );

      thisRow.add(AnimatedContainer(
          duration: Duration(milliseconds: 333),
          decoration: makeBorder(c, maxC, r, maxR, item == selected),
          constraints: buttonSize,
          padding: EdgeInsets.only(top:4.0, bottom:4.0),
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
      color: uiColour,
      border: Border.all(width: 1.0, color: uiColour),
      borderRadius: BorderRadius.all(bendy));

  return Container(
      constraints:
          BoxConstraints(maxWidth: (2 * maxC) + (itemWidth * columns) + 4),
      padding: EdgeInsets.all(1.0),
      decoration: outerDecoration,
      child: inner);
}
