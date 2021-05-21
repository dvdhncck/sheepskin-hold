// @dart=2.9

import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:stream_channel/isolate_channel.dart';
import "dart:math";
import "dart:async";

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';

import 'dart:convert';

import 'message_log.dart';
import 'mr_background.dart';

const List<String> VALID_TIME_VALUES = <String>['1', '5', '10', '100'];
const List<String> VALID_TIME_UNITS = <String>[
  'seconds',
  'minutes',
  'hours',
  'days',
  'weeks'
];
const List<String> VALID_DESTINATIONS = <String>[
  'Home screen',
  'Lock screen',
  'Both'
];

class SheepSkin {

  // things the need to be shared with MrBackend
  List<String> paths = [];
  String timeValue;
  String timeUnit;
  String destination;

  // remaining state is for the front end only
  SharedPreferences sharedPreferences;

  String nextChange;
  String lastChange;

  DateTime lastUpdateTimestamp;
  List<LogMessage> logEntryList = [];

  String imageCount = 'No images selected';

  final _random = new Random(DateTime.now().millisecondsSinceEpoch);

  final DateFormat formatter = DateFormat('yyyy-MM-dd H:m:s');

  var onUpdateCallback;

  SheepSkin(Function onUpdateCallback) {
    this.onUpdateCallback = onUpdateCallback;

    initialisePreferences((sheepSkin) => _retrieveState());

    connectToMrBackground();
  }

  void initialisePreferences(Function onReady) async {
    try {
      this.sharedPreferences = await SharedPreferences.getInstance();
      onReady(this);
    } catch (e) {
      print(e);
    } finally {}
  }

  var _mrBackground;
  var sendPort; // for sending to MrB

  static IsolateChannel channel;

  void notifyUi() {
    if(onUpdateCallback != null) {
      onUpdateCallback();
    }
  }

  void connectToMrBackground() async {

    if (_mrBackground != null) {
      // the UI thinks that the background is up. verify that somehow
    } else {
      // most likely the UI has been restarted after a kill,
      // (or this is the first time the app has run)
      // so we assume the background isolate is dead too
      print('paging MrBackground...');

      ReceivePort rPort = new ReceivePort();
      channel = new IsolateChannel.connectReceive(rPort);
      channel.stream.listen((data) {
        processEvent(data);
      });

      await Isolate.spawn(MrBackground.beginBackgroundCheck, rPort.sendPort);

      sendStateToMrBackground();
    }
  }

  void sendMessage(String message) async {
    channel.sink.add(message);
  }

  void processEvent(String eventRaw) {
    //print(eventRaw);
    var event =  Map<String, dynamic>.from(jsonDecode(eventRaw));
    for(String key in event.keys) {
        switch(key) {
          case "heartbeat":
            //print(event[key]);
            break;
          case "changing":
            lastChange=event[key];
            print(key + ' ' + lastChange);
            notifyUi();
            break;
          case "next_update":
            nextChange=event[key];
            print(key + ' ' + nextChange);
            notifyUi();
            break;
        }
    }
  }

  void log(String message) {
    var dateTime = DateTime.now();
    final String formatted = formatter.format(dateTime);

    print(formatted + " : " + message);

    logEntryList.add(LogMessage(formatted, message));

    if (logEntryList.length > 5) {
      logEntryList = logEntryList.sublist(logEntryList.length - 5);
    }
  }

  String getLastChange() {
    return lastChange == null ? '--:--:--' : lastChange;
  }

  String getNextChange() {
    return nextChange == null ? '--:--:--' : nextChange;
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

    sendStateToMrBackground();

    var count = 0;
    var unreadable = 0;
    for (final path in getPaths()) {
      Directory dir = Directory(path);
      try {
        List<FileSystemEntity> entities =
            await dir.list(recursive: true).toList();
        // print(entities);
        for (var entity in entities) {
          if (entity is File) {
            print(lookupMimeType(entity.path));
            //(entity as File).readAsStringSync();
            count++;
          }
        }
      } catch (e) {
        print(e);
        unreadable++;
      }
    }

    imageCount =
        count.toString() + " files in " + getPaths().length.toString() + " folders";

    if (unreadable > 0) {
      imageCount += "(some bad)";
    }

  }

  String getTimeValue() {
    return timeValue;
  }
  String getTimeUnit() {
    return timeUnit;
  }
  String getDestination() {
    return destination;
  }
  List<String> getPaths() {
    return paths;
  }

  void setTimeValue(String value) async {
    timeValue = value;
    sharedPreferences.setString('timeValue', timeValue);
    _onScheduleChanged();
  }

  void setTimeUnit(String value) async {
    timeUnit = value;
    sharedPreferences.setString('timeUnit', timeUnit);
    _onScheduleChanged();
  }

  void setDestination(String value) async {
    destination = value;
    sharedPreferences.setString('destination', destination);
    _onScheduleChanged();
  }

  void setLastUpdateTimestamp(DateTime value) async {
    lastUpdateTimestamp = value;
    sharedPreferences.setInt(
        'lastUpdateTimestamp', lastUpdateTimestamp.millisecondsSinceEpoch);
    _onScheduleChanged();
  }

  void _onScheduleChanged() async {
    sendStateToMrBackground();
  }

  Future<String> _pickImage() async {
    if (getPaths() == null || getPaths().length == 0) {
      return null;
    }

    List<File> candidates = [];
    for (final path in getPaths()) {
      try {
        Directory dir = Directory(path);
        List<FileSystemEntity> entities =
            await dir.list(recursive: true).toList();
        // print(entities);
        for (var entity in entities) {
          if (entity is File) {
            String mimeType = lookupMimeType(entity.path);
            if (mimeType.startsWith('image/')) {
              candidates.add(entity);
            }
          }
        }
      } catch (e) {
        print(e);
      }
    }
    if (candidates.isEmpty) {
      return null;
    }

    var theChosenOne = candidates[_random.nextInt(candidates.length)];
    return theChosenOne.path;
  }

  int _decodeDestination() {
    switch (destination) {
      case 'Home screen':
        return WallpaperManager.HOME_SCREEN;
      case 'Lock screen':
        return WallpaperManager.LOCK_SCREEN;
      default:
        return WallpaperManager.BOTH_SCREENS;
    }
  }

  void changeWallpaper(Function onDone) async {
    String wallpaper = await _pickImage();
    setLastUpdateTimestamp(DateTime.now());
    if (wallpaper == null) {
      log('Unable to find any images');
      return;
    }
    int location = _decodeDestination();
    try {
      log('Setting wallpaper on ' + destination);
      await WallpaperManager.setWallpaperFromFile(wallpaper, location);
      onDone();
    } on PlatformException catch (e) {
      log('Failed to get wallpaper: ' + e.toString());
    }
  }

  void _retrieveState() {
    if (sharedPreferences == null) {
      print('_retrieveState: SharedPreferences unexpectedly null');
      return;
    }

    if (sharedPreferences.containsKey('paths')) {
      setPaths(sharedPreferences.getStringList('paths'));
    } else {
      setPaths([]);
    }

    if (sharedPreferences.containsKey('lastUpdateTimestamp')) {
      int millisecondsSinceEpoch =
          sharedPreferences.getInt('lastUpdateTimestamp');
      lastUpdateTimestamp =
          DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    } else {
      lastUpdateTimestamp = null; // we've never done an update
    }

    if (sharedPreferences.containsKey('timeValue')) {
      timeValue = sharedPreferences.getString('timeValue');
    } else {
      timeValue = '1';
    }

    if (sharedPreferences.containsKey('timeUnit')) {
      timeUnit = sharedPreferences.getString('timeUnit');
    } else {
      timeUnit = 'days';
    }

    if (sharedPreferences.containsKey('destination')) {
      destination = sharedPreferences.getString('destination');
    } else {
      destination = 'Home screen';
    }

    logEntryList = LogMessage.retrieveFrom(sharedPreferences);

    onUpdateCallback();
  }

  // String toJsonArray(List<String> list) {
  //   return paths.fold('["', (soFar, path) => soFar + path + '","' + ) + ']';
  // }
  //

  String toJsonArray(List<String> list) {
    String json = '[';
    String delimiter = '';
    for (var path in paths) {
      json += delimiter + '"' + path + '"';
      delimiter = ',';
    }
    return json + ']';
  }

  void sendStateToMrBackground() {
    var json = '''{
    "timeValue":"${timeValue}", 
    "timeUnit":"${timeUnit}", 
    "destination":"${destination}", 
    "paths":${toJsonArray(paths)}
    }''';
    sendMessage(json);
  }
}
