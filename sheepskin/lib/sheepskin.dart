import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheepskin/sheepstate.dart';

import 'model.dart';
import 'tyler.dart';
import 'wallpaperer.dart';

class SheepSkin {
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat shortFormatter = DateFormat('yyyy-MM-dd HH:mm');

  static final String unknownTime = '--:--:--';

  final SheepState sheepState = SheepState();
  final Tyler tyler = Tyler.empty();
  late Function onUpdateCallback;

  bool displayLogMessageViewer = false;

  SheepSkin(Function onUpdateCallback) {
    this.onUpdateCallback = onUpdateCallback;

    SharedPreferences.getInstance().then((sharedPreferences) {
      sheepState.loadFrom(sharedPreferences);
      onUpdateCallback();
    });
  }

  static MaterialApp buildHoldingWidget() {
    return MaterialApp(
        title: 'Wallpaper Fluctuator',
        debugShowCheckedModeBanner: false,
        home: Text('Loading...Please be still.'));
  }

  TimeValue getTimeValue() {
    return sheepState.timeValue;
  }

  TimeUnit getTimeUnit() {
    return sheepState.timeUnit;
  }

  Destination getDestination() {
    return sheepState.destination;
  }

  int getImageCount() {
    return sheepState.imageCount;
  }

  String getLastChangeAsText() {
    return sheepState.lastChangeText;
  }

  String getNextChangeAsText() {
    return sheepState.nextChangeText;
  }

  void requestImmediateChange(double width, double height, Function onCompletion) async {
    sheepState.lastChangeText = formatter.format(DateTime.now());
    Wallpaperer.changeWallpaper(width, height, sheepState, onCompletion);
  }

  void toggleLogMessageViewer() {
    displayLogMessageViewer = !displayLogMessageViewer;
    sheepState.log("Toggled log viewer", "Visible: $displayLogMessageViewer");
    onUpdateCallback();
  }

  void notifyWallpaperChangeHasHappened() async {
    sheepState.setLastChangeTimestamp();
    onUpdateCallback();
  }

  void notifyTimeOfNextWallpaperChange(DateTime value) async {
    sheepState.setNextChangeTimestamp(value);
    onUpdateCallback();
  }
}
