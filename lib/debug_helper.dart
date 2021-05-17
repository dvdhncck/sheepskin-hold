// @dart=2.9

import 'dart:math';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';

import 'sheepskin.dart';


class DebugTab extends StatefulWidget {
  final SheepSkin sheepSkin;

  const DebugTab(this.sheepSkin);

  @override
  State<DebugTab> createState() {
    return _DebugTabState(sheepSkin);
  }
}

class _DebugTabState extends State<DebugTab> {
  final SheepSkin sheepSkin;

  _DebugTabState(this.sheepSkin);

  @override
  Widget build(BuildContext context) {
    int counter = 1000; // for generating fake paths

    var buttonBar = Container(
        decoration: makeBorder(Colors.black26, Colors.orangeAccent),
        child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      addDebugLine(counter);
                    });
                  },
                  child: Text('+path')),
              TextButton(
                  onPressed: () {
                    setState(() {
                      addDebugLine(counter);
                      addDebugLine(counter);
                      addDebugLine(counter);
                      addDebugLine(counter);
                      addDebugLine(counter);
                    });
                  },
                  child: Text('+++path')),
              TextButton(
                  onPressed: () async {
                    setState(() {
                      sheepSkin.log('poking...');
                    });
                    await AndroidAlarmManager.oneShot(
                      const Duration(seconds: 5),
                      // Ensure we have a unique alarm ID.
                      Random().nextInt(pow(2, 31).toInt()),
                      SheepSkin.thingyCallback,
                      exact: true,
                      wakeup: true,
                    );
                  },
                  child: Text('poke'))
            ])));

    List<Widget> listViewItems = [];

    if (sheepSkin.logEntryList != null) {
      for (var logEntry in sheepSkin.logEntryList) {
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

  void addDebugLine(int counter) {
    counter++;
    String newPath = 'folder' + counter.toString();
    while (sheepSkin.paths.contains(newPath)) {
      counter++;
      newPath = 'folder' + counter.toString();
    }
    setState(() {
      sheepSkin.addPath(newPath);
      sheepSkin.log('adding fake folder ' + newPath);
    });
  }
}
