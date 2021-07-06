import 'dart:async';
import 'dart:io';
import "dart:math";

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheepskin/sheepstate.dart';
import 'package:mime/mime.dart';

import 'package:sheepskin/model.dart';

class Wallpaperer {
  static const MethodChannel _channel = const MethodChannel('sheepskin');

  static const int HOME_SCREEN = 1;
  static const int LOCK_SCREEN = 2;
  static const int BOTH_SCREENS = 3;

  static final _random = new Random(DateTime.now().millisecondsSinceEpoch);

  /// Function takes input file's path & location choice
  static Future<String> setWallpaperFromFile(
      String filePath, int wallpaperLocation) async {
    var parameterMap = {
      'filePath': filePath,
      'wallpaperLocation': wallpaperLocation
    };

    final int result =
        await _channel.invokeMethod('setWallpaperFromFile', parameterMap);

    /// Function returns the set String as result, use for debugging
    return result > 0 ? "Wallpaper set" : "There was an error.";
  }

  static void changeWallpaper(SheepState sheepState, Function onDone) async {
    bool isMultiImage =
        (sheepState.destination == Destination.BOTH_SEPARATE);

    int imagesRequired = isMultiImage ? 2 : 1;



    try {
      // can throw if there aren't any pictures, or aren't enough pictures
      List<File> wallpapers = await _pickImages(sheepState, imagesRequired);

      WidgetsFlutterBinding.ensureInitialized();
        // can potentially throw a platform exception for a bunch of reasons
        if (isMultiImage) {
          await setWallpaperFromFile(wallpapers[0].path, HOME_SCREEN);
          await setWallpaperFromFile(wallpapers[1].path, LOCK_SCREEN);
        } else {
          await setWallpaperFromFile(
              wallpapers[0].path, sheepState.destination.location());
        }
        // Signal unbridled Joy
        sheepState.setLastChangeTimestamp();
        onDone();
      } on Exception catch (e) {
        sheepState.log('Change failed', e.toString());
        onDone();
      }

  }

  static Future<List<File>> identifyCandidates(SheepState sheepState) async {
    List<File> candidates = [];
    int failed = 0;
    for (final path in sheepState.paths) {
      try {
        Directory dir = Directory(path);
        List<FileSystemEntity> entities =
            await dir.list(recursive: true).toList();
        for (var entity in entities) {
          if (entity is File) {
            String? mimeType = lookupMimeType(entity.path);
            if (mimeType!.startsWith('image/')) {
              candidates.add(entity);
            }
          }
        }
      } catch (e) {
        /*
        FileSystemException: Directory listing failed, path = '/storage/emulated/0/Pictures/backgrounds/' (OS Error: Permission denied,
         */

        failed++;
      }
    }
    if (failed > 0) {
      sheepState.log('Scanning error', 'Failed to read $failed paths');
    }
    return candidates;
  }

  static Future<List<File>> _pickImages(
      SheepState sheepState, int count) async {
    if (sheepState.paths.length == 0) {
      throw Exception("No paths have been added");
    }

    var candidates = await identifyCandidates(sheepState);

    if (candidates.length < count) {
      throw Exception("Not enough images to choose from");
    }
    candidates.shuffle(_random);

    return candidates.sublist(0, count);
  }
}
