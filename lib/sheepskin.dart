// @dart=2.9

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sheepskin/sheepstate.dart';

import 'model.dart';
import 'wallpaperer.dart';

class SheepSkin {
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat shortFormatter = DateFormat('yyyy-MM-dd HH:mm');

  static final String unknownTime = '--:--:--';

  SheepState sheepState;

  // volatile state:

  Function onUpdateCallback;
  bool displayLogMessageViewer = false;

  final bool uiDebug = false;

  SheepSkin(Function onUpdateCallback) {
    this.onUpdateCallback = onUpdateCallback;

    initialisePreferences(onUpdateCallback);
  }

  TimeValue getTimeValue() {
    return sheepState.getTimeValue();
  }

  TimeUnit getTimeUnit() {
    return sheepState.getTimeUnit();
  }

  Destination getDestination() {
    return sheepState.getDestination();
  }

  int getImageCount() {
    return sheepState.getImageCount();
  }

  String getLastChangeAsText() {
    return sheepState.getLastChangeTimestampAsText();
  }

  String getNextChangeAsText() {
    return sheepState.getNextChangeTimestampAsText();
  }

  void requestImmediateChange(Function onCompletion) async {
    sheepState.lastChangeText = formatter.format(DateTime.now());
    Wallpaperer.changeWallpaper(sheepState, onCompletion);
  }

  void initialisePreferences(Function onReady) async {
    await SharedPreferences.getInstance().then((sharedPreferences) {
      sheepState = SheepState(sharedPreferences);
      onReady();
    });
  }

  void notifyUi() {
    if (onUpdateCallback != null) {
      onUpdateCallback();
    }
  }

  void toggleLogMessageViewer() {
    displayLogMessageViewer = !displayLogMessageViewer;
    sheepState.log("Toggled log viewer", "Visible: $displayLogMessageViewer");
    notifyUi();
  }

  void notifyWallpaperChangeHasHappened() async {
    sheepState.setLastChangeTimestamp();
    notifyUi();
  }

  void notifyTimeOfNextWallpaperChange(DateTime value) async {
    sheepState.setNextChangeTimestamp(value);
    notifyUi();
  }
}
