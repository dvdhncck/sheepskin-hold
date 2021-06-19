// @dart=2.9

import 'dart:async';
import 'dart:io';
import "dart:math";

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sheepskin/sheepstate.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:mime/mime.dart';

import 'package:sheepskin/model.dart';

class Wallpaperer {

  static final _random = new Random(DateTime.now().millisecondsSinceEpoch);

  static void changeWallpaper(SheepState sheepState, Function onDone) async {
    bool isMultiImage = (sheepState.getDestination() == Destination.BOTH_SEPARATE);

    int imagesRequired = isMultiImage ? 2 : 1;

    List<File> wallpapers =
        await _pickImages(sheepState, imagesRequired);

    if (wallpapers == null) {
      sheepState.log('Change failed','Insufficient images');
      onDone();
    } else {
      try {
        WidgetsFlutterBinding.ensureInitialized();
        if (isMultiImage) {
          await WallpaperManager.setWallpaperFromFile(
              wallpapers[0].path, WallpaperManager.HOME_SCREEN);
          await WallpaperManager.setWallpaperFromFile(
              wallpapers[1].path, WallpaperManager.LOCK_SCREEN);
        } else {
          await WallpaperManager.setWallpaperFromFile(
              wallpapers[0].path, sheepState.getDestination().location());
        }
        // Signal unbridled Joy
        sheepState.setLastChangeTimestamp();
        onDone();
      } on PlatformException catch (e) {
        // Unexpected fail
        sheepState.log('Change failed', e.toString());
        onDone();
      }
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
            String mimeType = lookupMimeType(entity.path);
            if (mimeType.startsWith('image/')) {
              candidates.add(entity);
            }
          }
        }
      } catch (e) {
        failed++;
      }
    }
    if (failed > 0) {
      sheepState.log('Scanning error', 'Failed to read $failed paths');
    }
    return candidates;
  }

  static Future<List<File>> _pickImages(SheepState sheepState, int count) async {
    if (sheepState.paths == null || sheepState.paths.length == 0) {
      return null;
    }

    var candidates = await identifyCandidates(sheepState);

    if (candidates.length < count) {
      return null;
    }

    candidates.shuffle(_random);

    return candidates.sublist(0, count);
  }
}
