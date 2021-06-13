// @dart=2.9

import 'dart:async';
import 'dart:io';
import "dart:math";

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';
import 'package:mime/mime.dart';

import 'package:sheepskin/model.dart';
import 'package:sheepskin/sheepskin.dart';

class Wallpaperer {
  SheepSkin _sheepSkin;

  Wallpaperer(this._sheepSkin);

  final _random = new Random(DateTime.now().millisecondsSinceEpoch);

  void changeWallpaper(Function onDone) async {
    bool isMultiImage = (_sheepSkin.getDestination() == Destination.BOTH_SEPARATE);

    int imagesRequired = isMultiImage ? 2 : 1;

    List<File> wallpapers =
        await _pickImages(imagesRequired, _sheepSkin.getPaths());

    if (wallpapers == null) {
      _sheepSkin.log('Change failed','Insufficient images');
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
              wallpapers[0].path, _sheepSkin.getDestination().location());
        }
        // Signal unbridled Joy
        _sheepSkin.log('Wallpaper changed', _sheepSkin.getDestination().label());
        _sheepSkin.notifyWallpaperChangeHasHappened();
        onDone();
      } on PlatformException catch (e) {
        // Unexpected fail
        _sheepSkin.log('Change failed', e.toString());
        onDone();
      }
    }
  }

  Future<List<File>> identifyCandidates(List<String> paths) async {
    List<File> candidates = [];
    int failed = 0;
    for (final path in paths) {
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
      _sheepSkin.log('Scanning error', 'Failed to read $failed paths');
    }
    return candidates;
  }

  Future<List<File>> _pickImages(int count, List<String> paths) async {
    if (paths == null || paths.length == 0) {
      return null;
    }

    var candidates = await identifyCandidates(paths);

    if (candidates.length < count) {
      return null;
    }

    candidates.shuffle(_random);

    return candidates.sublist(0, count);
  }

  
}
