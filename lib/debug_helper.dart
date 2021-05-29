// @dart=2.9

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'sheepskin.dart';

final _random = new Random(DateTime
    .now()
    .millisecondsSinceEpoch);

class DebugTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const DebugTab(this.sheepSkin);

  @override
  State<DebugTab> createState() {
    return _DebugTabState();
  }
}

class _DebugTabState extends State<DebugTab> {
  @override
  Widget build(BuildContext context) {
    print("_DebugTabState.build()");

    int counter = 1000; // for generating fake paths


    var buttonBar = Container(
        decoration: makeBorder(Colors.black26, Colors.orangeAccent),
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      addDebugLine(widget.sheepSkin, counter, 1);
                    });
                  },
                  child: Text('+path')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      addDebugLine(widget.sheepSkin, counter, 5);
                    });
                  },
                  child: Text('+++path')),
            ])));

    List<Widget> listViewItems = [];

    if (widget.sheepSkin.logEntryList != null) {
      for (var logEntry in widget.sheepSkin.logEntryList) {
        listViewItems.add(Align(
            alignment: Alignment.centerLeft,
            child: Padding(
                padding: EdgeInsets.all(6.0),
                child: Container(
                    margin: EdgeInsets.all(4.0),
                    decoration: makeBorder(Colors.teal, Colors.tealAccent),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                              child: RichText(
                                textAlign: TextAlign.start,
                                text: TextSpan(
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: logEntry.timestamp,
                                        style: TextStyle(
                                            backgroundColor: Colors.deepOrange,
                                            fontSize: 14.0,
                                            color: Colors.white))
                                  ],
                                ),
                              )),
                          RichText(
                            textAlign: TextAlign.start,
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                    text: logEntry.message,
                                    style: TextStyle(
                                        backgroundColor: Colors.lime,
                                        fontSize: 18.0,
                                        color: Colors.white)),
                              ],
                            ),
                          )
                        ])))));
      }
    }

    //ListView messageView = ListView(children: listViewItems);
    Widget messageView = Container(
        decoration: makeBorder(Colors.pink, Colors.pinkAccent),
        child: Column(
          children: listViewItems,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
        ));

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [buttonBar, messageView]);
  }

  BoxDecoration makeBorder(Color fill, Color edges) {
    return BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      // border: Border(
      //   top: BorderSide(width: 1.0, color: edges),
      //   left: BorderSide(width: 1.0, color: edges),
      //   right: BorderSide(width: 1.0, color: edges),
      //   bottom: BorderSide(width: 1.0, color: edges),
      //),
    );
  }

  List<String> words = [
    'tree',
    'hamster',
    'gooseberry',
    'shed',
    'pencil',
    'wolf',
    'handbag',
    'bongo',
    'doorknob',
    'wooden',
    'meta'
  ];

  void addDebugLine(SheepSkin sheepSkin, int counter, int amount) {
    while (amount > 0) {
      counter++;
      var pathParts = [];
      var bits = _random.nextInt(15);
      while (bits > 0) {
        pathParts.add(words[_random.nextInt(words.length)]);
        bits--;
      }
      var path = pathParts.join('/');
      setState(() {
        sheepSkin.addPath(path);
        sheepSkin.log('adding fake folder', path);
      });
      amount -= 1;
    }
  }
}
