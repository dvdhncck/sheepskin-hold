// @dart=2.9

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'sheepskin.dart';

final _random = new Random(DateTime.now().millisecondsSinceEpoch);

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

    var buttonBar = Container(
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      addLogLine(widget.sheepSkin, 1);
                    });
                  },
                  child: Text('+log')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      addDebugLine(widget.sheepSkin, 1);
                    });
                  },
                  child: Text('+path')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      addDebugLine(widget.sheepSkin, 5);
                    });
                  },
                  child: Text('+++path')),
            ])));

    List<Widget> entries = [];

    if (widget.sheepSkin.logEntryList != null) {
      for (var logEntry in widget.sheepSkin.logEntryList.reversed) {
        entries.add(Container(
            height:18,
            child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                    text: logEntry.timestamp + '\n',
                    style:
                        TextStyle(fontSize: 12.0, color: Colors.blueGrey)))));
        entries.add(Container(
            margin: EdgeInsets.only(bottom:10),
            height:22,
            child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                    text: logEntry.message + '\n',
                    style: TextStyle(fontSize: 18.0, color: Colors.black)))));
      }
    }

    Widget messageView = ListView(children: entries);

    return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [/*buttonBar,*/ Expanded(child:messageView)]);
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

  void addDebugLine(SheepSkin sheepSkin, int amount) {
    while (amount > 0) {
      String path = makeGibberish('/');
      setState(() {
        sheepSkin.addPath(path);
        sheepSkin.log('adding fake folder', path);
      });
      amount -= 1;
    }
  }

  void addLogLine(SheepSkin sheepSkin, int amount) {
    while (amount > 0) {
      String text = makeGibberish(' ');
      setState(() {
        sheepSkin.log(text, text);
      });
      amount -= 1;
    }
  }

  String makeGibberish(String delimiter) {
    var pathParts = [];
    var bits = _random.nextInt(15);
    while (bits > 0) {
      pathParts.add(words[_random.nextInt(words.length)]);
      bits--;
    }
    var path = pathParts.join(delimiter);
    return path;
  }
}
