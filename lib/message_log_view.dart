import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sheepskin/sheepstate.dart';

import 'sheepskin.dart';

final _random = new Random(DateTime.now().millisecondsSinceEpoch);

class MessageLogViewTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const MessageLogViewTab(this.sheepSkin);

  @override
  State<MessageLogViewTab> createState() {
    return _MessageLogViewTabState();
  }
}

class _MessageLogViewTabState extends State<MessageLogViewTab> {
  
  @override
  Widget build(BuildContext context) {
    if(SheepState.SHOW_DEBUG_HELPERS) {
      buildDebugButtonBar();
    }
    
    List<Widget> entries = [];

    var sheepState = widget.sheepSkin.sheepState;
    int index  = sheepState.logBody.length;

    while(--index >= 0) {
      entries.add(Container(
          height: 22,
          child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: sheepState.logTimestamp[index] + '\n',
                  style:
                      TextStyle(fontSize: 18.0, color: Colors.blueGrey)))));
      entries.add(Container(
          height: 26,
          margin: EdgeInsets.only(left: 5),
          child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: sheepState.logHeader[index] + '\n',
                  style: TextStyle(fontSize: 22.0, color: Colors.black)))));
      entries.add(Container(
          margin: EdgeInsets.only(left: 10, bottom: 10),
          height: 24,
          child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                  text: sheepState.logBody[index] + '\n',
                  style: TextStyle(fontSize: 20.0, color: Colors.black38)))));
    }

    Widget messageView = Container(
        margin: EdgeInsets.only(left: 5), child: ListView(children: entries));

    List<Widget> children = SheepState.SHOW_DEBUG_HELPERS  ? [buildDebugButtonBar()] : [];
    children.add(Expanded(child: messageView));

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children);
  }

  Container buildDebugButtonBar() {
    return Container(
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
        sheepSkin.sheepState.addPath(path);
        sheepSkin.sheepState.log('adding fake folder', path);
      });
      amount -= 1;
    }
  }

  void addLogLine(SheepSkin sheepSkin, int amount) {
    while (amount > 0) {
      String text = makeGibberish(' ');
      setState(() {
        sheepSkin.sheepState.log(text, text);
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
