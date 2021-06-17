// @dart=2.9

import 'dart:io';
import 'dart:math';

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

  static const bool ALLOW_SECONDS = true;

  // persisted state:

  List<String> paths = [];
  int imageCount;
  TimeValue timeValue;
  TimeUnit timeUnit;
  Destination destination;
  String lastChangeText;
  String nextChangeText;
  List<LogMessage> logEntryList = [];

  // volatile state:

  SharedPreferences sharedPreferences;
  MrBackground _mrBackground;
  Wallpaperer _wallpaperer;
  Function onUpdateCallback;
  bool displayLogMessageViewer = false;

  final bool uiDebug = false;

  SheepSkin(Function onUpdateCallback) {
    this.onUpdateCallback = onUpdateCallback;

    initialisePreferences((sheepSkin) {
      _wallpaperer = Wallpaperer(this);
      _mrBackground = MrBackground(this, _wallpaperer);
      _retrieveState();
    });
  }

  void requestImmediateChange(Function onCompletion) async {
    lastChangeText = formatter.format(DateTime.now());
    _wallpaperer.changeWallpaper(onCompletion);
  }

  void initialisePreferences(Function onReady) async {
    await SharedPreferences.getInstance().then((s) {
      this.sharedPreferences = s;
      onReady(this);
    });
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

    logEntryList.add(LogMessage(formatted, message, details));

    if (logEntryList.length > 50) {
      logEntryList = logEntryList.sublist(logEntryList.length - 5);
    }

    if (sharedPreferences != null) {
      LogMessage.persistTo(logEntryList, sharedPreferences);
    }

    notifyUi();
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

  void toggleLogMessageViewer() {
    displayLogMessageViewer = !displayLogMessageViewer;
    log("Toggled log viewer", "Visible: $displayLogMessageViewer");
    notifyUi();
  }

  int getImageCount() {
    return imageCount;
  }

  void setImageCount(int imageCount) async {
    this.imageCount = imageCount;
    sharedPreferences.setInt('imageCount', imageCount);
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
    if (value == null) {
      nextChangeText = unknownTime;
    } else {
      nextChangeText = shortFormatter.format(value);
    }
    sharedPreferences.setString('nextChangeText', nextChangeText);
    notifyUi();
  }

  void _onScheduleChanged() async {
    _mrBackground.bookAlarmCall(() => {});
  }

  int getAlarmId() {
    if (!sharedPreferences.containsKey('alarmId')) {
      sharedPreferences.setInt(
          'alarmId', (1 << 11) + Random.secure().nextInt(1 << 20));
    }
    return sharedPreferences.getInt('alarmId');
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
      timeValue = TimeValue.from(sharedPreferences.getString('timeValue'));
    }
    if (timeValue == null) {
      timeValue = TimeValue.ONE;
    }

    if (sharedPreferences.containsKey('timeUnit')) {
      timeUnit = TimeUnit.from(sharedPreferences.getString('timeUnit'));
    }
    if (timeUnit == null) {
      timeUnit = TimeUnit.DAYS;
    }

    if (sharedPreferences.containsKey('destination')) {
      destination =
          Destination.from(sharedPreferences.getString('destination'));
    }
    if (destination == null) {
      destination = Destination.HOME;
    }

    if (sharedPreferences.containsKey('lastChangeText')) {
      lastChangeText = sharedPreferences.getString('lastChangeText');
    } else {
      lastChangeText = unknownTime;
    }

    if (sharedPreferences.containsKey('nextChangeText')) {
      nextChangeText = sharedPreferences.getString('nextChangeText');
    } else {
      nextChangeText = unknownTime;
    }

    logEntryList = LogMessage.retrieveFrom(sharedPreferences);

    _onPathChanged();
    _onScheduleChanged();
  }
}
