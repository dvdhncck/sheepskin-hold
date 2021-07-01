import 'dart:math';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';
import 'mr_background.dart';

class SheepState {
  late SharedPreferences sharedPreferences;

  // the flags of static

  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat shortFormatter = DateFormat('yyyy-MM-dd HH:mm');

  static final String unknownTime = '--:--:--';

  static const bool SHOW_DEBUG_HELPERS = false;
  static const bool ALLOW_SECONDS = false;
  static const int PERSISTED_LOG_MESSAGES = 32;

  // the persisted state

  bool unready = true;

  late int imageCount = 0;

  late List<String> paths = [];
  late int alarmId = -1;
  late TimeValue timeValue = TimeValue.ONE;
  late TimeUnit timeUnit = TimeUnit.DAYS;
  Destination destination = Destination.BOTH_TOGETHER;
  late DateTime nextChange;
  String lastChangeText = unknownTime;
  String nextChangeText = unknownTime;

  late List<String> logBody = [];
  late List<String> logHeader = [];
  late List<String> logTimestamp = [];

  static SheepState from(SharedPreferences sharedPreferences) {
    return SheepState().loadFrom(sharedPreferences);
  }

  void setNextChangeTimestamp(DateTime nextChange) {
    this.nextChange = nextChange;
    nextChangeText = shortFormatter.format(this.nextChange);
    sharedPreferences.setString('nextChangeText', nextChangeText);
  }

  /// has only got 1 minute resolution
  bool nextChangeIsInThePast() {
    return nextChange.isBefore(DateTime.now());
  }

  void clearNextChangeTimestamp() {
    sharedPreferences.setString('lastChangeText', lastChangeText = unknownTime);
  }

  void setLastChangeTimestamp() {
    lastChangeText = shortFormatter.format(DateTime.now());
    log('Wallpaper changed', destination.label());
    sharedPreferences.setString('lastChangeText', lastChangeText);
  }

  void addPath(String path) async {
    if (paths.contains(path)) {
      return;
    }
    paths.add(path); // todo: should assume copy-on-append
    sharedPreferences.setStringList('paths', paths);
  }

  void removePath(String path) async {
    paths.remove(path); // todo: should assume copy-on-append
    sharedPreferences.setStringList('paths', paths);
  }

  void setImageCount(int imageCount) async {
    this.imageCount = imageCount;
    sharedPreferences.setInt('imageCount', imageCount);
  }

  void setTimeValue(TimeValue timeValue) async {
    this.timeValue = timeValue;
    sharedPreferences.setString('timeValue', timeValue.label());
    MrBackground.bookAlarmCall(this);
  }

  void setTimeUnit(TimeUnit timeUnit) async {
    this.timeUnit = timeUnit;
    sharedPreferences.setString('timeUnit', timeUnit.label());
    MrBackground.bookAlarmCall(this);
  }

  void setDestination(Destination value) async {
    destination = value;
    sharedPreferences.setString('destination', destination.label());
    MrBackground.bookAlarmCall(this);
  }

  SheepState loadFrom(SharedPreferences latestSharedPreferences) {
    sharedPreferences = latestSharedPreferences;

    if (!sharedPreferences.containsKey('alarmId')) {
      sharedPreferences.setInt(
          'alarmId', (1 << 11) + Random.secure().nextInt(1 << 20));
    }
    alarmId = sharedPreferences.getInt('alarmId')!;

    if (sharedPreferences.containsKey('paths')) {
      paths = sharedPreferences.getStringList('paths')!;
    }

    if (sharedPreferences.containsKey('imageCount')) {
      imageCount = sharedPreferences.getInt('imageCount')!;
    }

    if (sharedPreferences.containsKey('timeValue')) {
      timeValue = TimeValue.from(sharedPreferences.getString('timeValue'));
    }

    if (sharedPreferences.containsKey('timeUnit')) {
      timeUnit = TimeUnit.from(sharedPreferences.getString('timeUnit'));
    }

    // TODO: write _getSafely(sharedPreferences, key, defaultValue)

    if (sharedPreferences.containsKey('destination')) {
      destination =
          Destination.from(sharedPreferences.getString('destination')!);
    }

    if (sharedPreferences.containsKey('lastChangeText')) {
      lastChangeText = sharedPreferences.getString('lastChangeText')!;
      nextChange = shortFormatter.parse(lastChangeText);
    }


    if (sharedPreferences.containsKey('logDetails')) {
      logBody = sharedPreferences.getStringList("logDetails")!;
      logHeader = sharedPreferences.getStringList("logMessages")!;
      logTimestamp = sharedPreferences.getStringList("logTimestamps")!;
    }

    unready = false;
    return this;
  }

  void log(String message, String details) {
    var dateTime = DateTime.now();
    final String formatted = formatter.format(dateTime);

    print(formatted + " : " + message + '\n' + details);

    logBody.add(details.length == 0 ? 'no details' : details);
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
