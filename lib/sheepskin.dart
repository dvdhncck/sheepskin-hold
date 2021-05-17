// @dart=2.9

import 'dart:io';
import 'dart:isolate';
import "dart:math";
import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';

import 'main.dart';

class LogMessage {
  String timestamp;
  String message;

  LogMessage(this.timestamp, this.message);
}

class SheepSkin {
  String timeValue;
  String timeUnit;
  String destination;

  DateTime lastUpdateTimestamp;

  List<String> validTimeValues = <String>['1', '5', '10', '100'];
  List<String> validTimeUnits = <String>['minutes', 'hours', 'days', 'weeks'];
  List<String> validDestinations = <String>[
    'Home screen',
    'Lock screen',
    'Both'
  ];

  List<String> paths;

  String imageCount = 'No images selected';

  final DateFormat formatter = DateFormat('yyyy-MM-dd H:m:s');
  final List<LogMessage> logEntryList = [];

  SheepSkin() {
    overlayDefaultValues();
    loadState();

    log('Started');
  }


  // ================================================

  static SendPort uiSendPort;

  static Future<void> thingyCallback() async {
    print('Alarm fired!');

    // Get the previous cached count and increment it.
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt('demo') ?? 0;
    await prefs.setInt('demo', currentCount + 1);

    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  // ================================================


  void log(String message) {
    var dateTime = DateTime.now();
    final String formatted = formatter.format(dateTime);

    print(formatted + " : " + message);

    logEntryList.add(LogMessage(formatted, message));
  }

  void doPeriodicUpdate() {
    log('doPeriodicUpdate');
    changeWallpaper();
  }

  void displayFilePickerForFolderSelection() async {
    try {
      String path = await FilePicker.platform.getDirectoryPath();
      addPath(path);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
  }

  void addPath(String path) {
    if (path != null) {
      // avoid duplicates
      if (paths.contains(path)) {
        return;
      }
      paths.add(path);
      onPathChanged();
    }
  }

  void removePath(String path) {
    if (path != null) {
      paths.remove(path);
      onPathChanged();
    }
  }

  void onPathChanged() async {
    var count = 0;
    var unreadable = 0;
    for (final path in paths) {
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
        count.toString() + " files in " + paths.length.toString() + " folders";

    if (unreadable > 0) {
      imageCount += "(some bad)";
    }

    persistState();
  }

  void onScheduleChanged() async {
    persistState();
  }

  Future<String> pickImage() async {
    List<File> candidates = [];
    for (final path in paths) {
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
    final _random = new Random();
    var theChosenOne = candidates[_random.nextInt(candidates.length)];
    return theChosenOne.path;
  }

  int decodeDestination() {
    switch (destination) {
      case 'Home screen':
        return WallpaperManager.HOME_SCREEN;
      case 'Lock screen':
        return WallpaperManager.LOCK_SCREEN;
      default:
        return WallpaperManager.BOTH_SCREENS;
    }
  }

  void changeWallpaper() async {
    String wallpaper = await pickImage();
    if (wallpaper == null) {
      log('Unable to find any images');
      return;
    }
    int location = decodeDestination();
    try {
      log('Setting wallpaper on ' + destination);
      await WallpaperManager.setWallpaperFromFile(wallpaper, location);
      ScaffoldMessengerState().removeCurrentSnackBar();
    } on PlatformException catch (e) {
      log('Failed to get wallpaper: ' + e.toString());
    }
  }

  void overlayDefaultValues() {
    if (paths == null) {
      paths = [];
    }
    if (timeValue == null) {
      timeValue = '1';
    }
    if (timeUnit == null) {
      timeUnit = 'days';
    }
    if (destination == null) {
      destination = 'Home screen';
    }
  }

  void persistState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fluctuator.destination', destination);
    prefs.setString('fluctuator.timeValue', timeValue);
    prefs.setString('fluctuator.timeUnit', timeUnit);
    prefs.setStringList('fluctuator.paths', paths);
  }

  void loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      destination = prefs.getString('fluctuator.destination');
      timeValue = prefs.getString('fluctuator.timeValue');
      timeUnit = prefs.getString('fluctuator.timeUnit');
      paths = prefs.getStringList('fluctuator.paths');
    } finally {
      overlayDefaultValues();
    }
  }
}
