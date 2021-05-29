// @dart=2.9

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';
import 'message_log.dart';
import 'mr_background.dart';

import 'wallpaperer.dart';

class SheepSkin {
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat shortFormatter = DateFormat('yyyy-MM-dd HH:mm');

  static final String unknownTime = '--:--:--';

  // persisted state:

  List<String> paths = [];
  int imageCount;
  TimeValue timeValue;
  TimeUnit timeUnit;
  Destination destination;
  String lastChangeText;
  List<LogMessage> logEntryList = [];

  // volatile state:

  SharedPreferences sharedPreferences;
  MrBackground _mrBackground;
  Wallpaperer _wallpaperer;
  Function onUpdateCallback;
  String nextChangeText;

  SheepSkin(Function onUpdateCallback) {
    this.onUpdateCallback = onUpdateCallback;

    initialisePreferences((sheepSkin) => _retrieveState());

    _wallpaperer = Wallpaperer(this);

    _mrBackground = MrBackground(this, _wallpaperer, 5);
    _mrBackground.beginBackgroundCheck();
    _onScheduleChanged();
  }

  void requestImmediateChange(Function onCompletion) async {
    lastChangeText = formatter.format(DateTime.now());
    _wallpaperer.changeWallpaper(onCompletion);
  }

  void initialisePreferences(Function onReady) async {
    try {
      this.sharedPreferences = await SharedPreferences.getInstance();
      onReady(this);
    } catch (e) {
      print(e);
    } finally {}
  }

  void notifyUi() {
    if (onUpdateCallback != null) {
      onUpdateCallback();
    }
  }

  void log(String message, String details) {
    var dateTime = DateTime.now();
    final String formatted = formatter.format(dateTime);

    print(formatted + " : " + message + '\n' + details);

    logEntryList.add(LogMessage(formatted, message));

    if (logEntryList.length > 5) {
      logEntryList = logEntryList.sublist(logEntryList.length - 5);
    }
  }

  void setPaths(List<String> paths) {
    this.paths = paths;
  }

  void addPath(String path) async {
    if (path != null) {
      // avoid duplicates
      if (getPaths().contains(path)) {
        return;
      }
      getPaths().add(path);
      sharedPreferences.setStringList('paths', getPaths());
      _onPathChanged();
    }
  }

  void removePath(String path) async {
    if (path != null) {
      getPaths().remove(path);
      sharedPreferences.setStringList('paths', getPaths());
      _onPathChanged();
    }
  }

  void _onPathChanged() async {
    List<File> candidates = await _wallpaperer.identifyCandidates(getPaths());
    imageCount = candidates.length;
    notifyUi();
  }

  TimeValue getTimeValue() {
    return timeValue == null ? TimeValue.ONE : timeValue;
  }

  TimeUnit getTimeUnit() {
    return timeUnit == null ? TimeUnit.HOURS : timeUnit;
  }

  Destination getDestination() {
    return destination;
  }

  List<String> getPaths() {
    return paths;
  }

  int getImageCount() {
    return imageCount;
  }

  void setImageCount(int imageCount) async {
    this.imageCount = imageCount;
    notifyUi();
  }

  void setTimeValue(TimeValue value) async {
    timeValue = value;
    sharedPreferences.setString('timeValue', timeValue.label());
    _onScheduleChanged();
  }

  void setTimeUnit(TimeUnit value) async {
    timeUnit = value;
    sharedPreferences.setString('timeUnit', timeUnit.label());
    _onScheduleChanged();
  }

  void setDestination(Destination value) async {
    destination = value;
    sharedPreferences.setString('destination', destination.label());
    _onScheduleChanged();
  }

  String getLastChangeAsText() {
    return lastChangeText == null ? unknownTime : lastChangeText;
  }

  String getNextChangeAsText() {
    return nextChangeText == null ? unknownTime : nextChangeText;
  }

  void notifyWallpaperChangeHasHappened() async {
    lastChangeText = shortFormatter.format(DateTime.now());
    sharedPreferences.setString('lastChangeText', lastChangeText);
    notifyUi();
  }

  void notifyTimeOfNextWallpaperChange(DateTime value) async {
    nextChangeText = shortFormatter.format(value);
    notifyUi();
  }

  void _onScheduleChanged() async {
    _mrBackground.chooseTheTimeForNextUpdate();
  }

  void _retrieveState() {
    if (sharedPreferences == null) {
      print('_retrieveState: SharedPreferences unexpectedly null');
      return;
    }

    if (sharedPreferences.containsKey('paths')) {
      paths = sharedPreferences.getStringList('paths');
    } else {
      paths = [];
    }

    if (sharedPreferences.containsKey('imageCount')) {
      imageCount = sharedPreferences.getInt('imageCount');
    } else {
      imageCount = 0;
    }

    if (sharedPreferences.containsKey('timeValue')) {
      timeValue =
          TimeValue.from(sharedPreferences.getString('timeValue'));
    } else {
      timeValue = TimeValue.ONE;
    }

    if (sharedPreferences.containsKey('timeUnit')) {
      timeUnit =
          TimeUnit.from(sharedPreferences.getString('timeUnit'));
    } else {
      timeUnit = TimeUnit.DAYS;
    }

    if (sharedPreferences.containsKey('destination')) {
      destination =
          Destination.from(sharedPreferences.getString('destination'));
    } else {
      destination = Destination.HOME;
    }

    if (sharedPreferences.containsKey('lastChangeText')) {
      lastChangeText = sharedPreferences.getString('lastChangeText');
    } else {
      lastChangeText = unknownTime;
    }

    logEntryList = LogMessage.retrieveFrom(sharedPreferences);

    _onPathChanged();
    _onScheduleChanged();
  }
}
