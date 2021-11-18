import 'dart:math';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';
import 'mr_background.dart';
import 'layabout.dart';
import 'tyler.dart';

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
  late Map<String, Tile> tileCache = new Map();

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

  Future<void> addPath(Tyler tyler, String path) async {
    if (paths.contains(path)) {
      return;
    }
    paths.add(path); // todo: should assume copy-on-append
    sharedPreferences.setStringList('paths', paths);

    await tyler
        .notifyPathsUpdated(paths)
        .then((tileCache) => _updateTileCache(tileCache));
  }

  Future<void> removePath(Tyler tyler, String path) async {
    paths.remove(path); // todo: should assume copy-on-append
    sharedPreferences.setStringList('paths', paths);

    await tyler
        .notifyPathsUpdated(paths)
        .then((tileCache) => _updateTileCache(tileCache));
  }

  void _updateTileCache(Map<String, Tile> tileCache) async {
    List<Tile> tiles = tileCache.values.toList(growable: false);
    sharedPreferences.setStringList(
        "tileCachePaths", tiles.map((t) => t.path).toList());
    sharedPreferences.setStringList(
        "tileCacheWidths", tiles.map((t) => t.w.toString()).toList());
    sharedPreferences.setStringList(
        "tileCacheHeights", tiles.map((t) => t.h.toString()).toList());
    imageCount = tiles.length;
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

    if (sharedPreferences.containsKey('tileCachePaths')) {
      tileCache = new Map<String, Tile>();
      var tileCachePaths = sharedPreferences.getStringList("tileCachePaths")!;
      if (sharedPreferences.containsKey('tileCacheWidths')) {
        var tileCacheWidths =
            sharedPreferences.getStringList("tileCacheWidths")!;
        if (sharedPreferences.containsKey('tileCacheHeights')) {
          var tileCacheHeights =
              sharedPreferences.getStringList("tileCacheHeights")!;
          for (var i = 0; i < tileCachePaths.length; i++) {
            var tile = new Tile(tileCachePaths[i],
                int.parse(tileCacheWidths[i]), int.parse(tileCacheHeights[i]));
            tileCache[tile.path] = tile;
          }
        }
      }
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
