// @dart=2.9

import 'dart:math';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';
import 'mr_background.dart';

class SheepState {
  SharedPreferences sharedPreferences;

  // the flags of static

  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat shortFormatter = DateFormat('yyyy-MM-dd HH:mm');

  static final String unknownTime = '--:--:--';

  static const bool SHOW_DEBUG_HELPERS = false;
  static const bool ALLOW_SECONDS = false;
  static const int PERSISTED_LOG_MESSAGES = 32;

  // the persisted state

  List<String> paths = [];
  int alarmId;
  int imageCount;
  TimeValue timeValue;
  TimeUnit timeUnit;
  Destination destination;
  String lastChangeText;
  String nextChangeText;

  List<String> logBody = [];
  List<String> logHeader = [];
  List<String> logTimestamp = [];

  SheepState(SharedPreferences latestSharedPreferences) {
    _initialiseFrom(latestSharedPreferences);
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

  int getImageCount() {
    return imageCount;
  }

  void setNextChangeTimestamp(DateTime expected) {
    if (expected == null) {
      nextChangeText = unknownTime;
    } else {
      nextChangeText = shortFormatter.format(expected);
    }
    sharedPreferences.setString('nextChangeText', nextChangeText);
  }

  void setLastChangeTimestamp() {
    lastChangeText = shortFormatter.format(DateTime.now());
    log('Wallpaper changed', destination.label());
    sharedPreferences.setString('lastChangeText', lastChangeText);
  }

  String getLastChangeTimestampAsText() {
    return lastChangeText == null ? unknownTime : lastChangeText;
  }

  String getNextChangeTimestampAsText() {
    return nextChangeText == null ? unknownTime : nextChangeText;
  }

  void addPath(String path) async {
    if (path != null) {
      // avoid duplicates
      if (paths.contains(path)) {
        return;
      }
      paths.add(path); // todo: should assume copy-on-append
      sharedPreferences.setStringList('paths', paths);
    }
  }

  void removePath(String path) async {
    if (path != null) {
      paths.remove(path); // todo: should assume copy-on-append
      sharedPreferences.setStringList('paths', paths);
    }
  }

  void setImageCount(int imageCount) async {
    imageCount = imageCount;
    sharedPreferences.setInt('imageCount', imageCount);
  }

  void setTimeValue(TimeValue value) async {
    timeValue = value;
    sharedPreferences.setString('timeValue', timeValue.label());
    MrBackground.bookAlarmCall(this);
  }

  void setTimeUnit(TimeUnit value) async {
    timeUnit = value;
    sharedPreferences.setString('timeUnit', timeUnit.label());
    MrBackground.bookAlarmCall(this);
  }

  void setDestination(Destination value) async {
    destination = value;
    sharedPreferences.setString('destination', destination.label());
    MrBackground.bookAlarmCall(this);
  }

  void _initialiseFrom(SharedPreferences latestSharedPreferences) {
    sharedPreferences = latestSharedPreferences;

    if (sharedPreferences == null) {
      print('_retrieveState: SharedPreferences unexpectedly null');
      return;
    }

    if (!sharedPreferences.containsKey('alarmId')) {
      sharedPreferences.setInt(
          'alarmId', (1 << 11) + Random.secure().nextInt(1 << 20));
    }
    alarmId = sharedPreferences.getInt('alarmId');

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

    if (sharedPreferences.containsKey('logDetails')) {
      logBody = sharedPreferences.getStringList("logDetails");
      logHeader = sharedPreferences.getStringList("logMessages");
      logTimestamp = sharedPreferences.getStringList("logTimestamps");
    } else {
      logBody = [];
      logHeader = [];
      logTimestamp = [];
    }
  }

  void log(String message, String details) {
    var dateTime = DateTime.now();
    final String formatted = formatter.format(dateTime);

    print(formatted + " : " + message + '\n' + details);

    logBody.add(details == null || details.length == 0 ? 'no details' : details);
    logHeader.add(message);
    logTimestamp.add(formatted);

    while (logBody.length > PERSISTED_LOG_MESSAGES) {
      logBody = logBody.sublist(1);
      logHeader = logHeader.sublist(1);
      logTimestamp = logTimestamp.sublist(1);
    }

    sharedPreferences.setStringList("logDetails", logBody);
    sharedPreferences.setStringList("logMessages", logHeader);
    sharedPreferences.setStringList("logTimestamps", logTimestamp);
  }
}
