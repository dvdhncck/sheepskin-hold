
import 'dart:async';
import 'dart:io';
import "dart:math";

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:sheepskin/sheepstate.dart';
import 'package:sheepskin/model.dart';
import 'package:sheepskin/tyler.dart';

import 'package:wallpaper/wallpaper.dart';

class Wallpaperer {
  static const MethodChannel _channel = const MethodChannel('sheepskin');

  static const int HOME_SCREEN = 1;
  static const int LOCK_SCREEN = 2;
  static const int BOTH_SCREENS = 3;

  static final _random = new Random(DateTime.now().millisecondsSinceEpoch);

  // /// Function takes input file's path & location choice
  // static Future<String> setWallpaperFromFile(
  //     String filePath, int wallpaperLocation) async {
  //   // var parameterMap = {
  //   //   'filePath': filePath,
  //   //   'wallpaperLocation': wallpaperLocation
  //   // };
  //   //
  //   // final int result =
  //   //     await _channel.invokeMethod('setWallpaperFromFile', parameterMap);
  //   // return result > 0 ? "Wallpaper set" : "There was an error.";
  //
  //   return (filePath, wallpaperLocation);
  // }

  static void changeWallpaper(double width, double height, SheepState sheepState, Function onDone) async {
    bool isMultiImage = (sheepState.destination == Destination.BOTH_SEPARATE);

    int imagesRequired = isMultiImage ? 2 : 1;

    try {
      // can throw if there aren't any pictures, or aren't enough pictures
      List<File> wallpapers = await _generateImages(width, height, sheepState, imagesRequired);

      WidgetsFlutterBinding.ensureInitialized();

      // can potentially throw a platform exception for a bunch of reasons

      if(sheepState.destination == Destination.BOTH_SEPARATE || sheepState.destination == Destination.BOTH_TOGETHER || sheepState.destination == Destination.HOME) {
        await Wallpaper.homeScreen(imageName: 'background0' /*wallpapers[0].path*/,
            location: DownloadLocation.EXTERNAL_DIRECTORY);
      }
      if(sheepState.destination == Destination.BOTH_TOGETHER || sheepState.destination == Destination.LOCK) {
        await Wallpaper.lockScreen(imageName: wallpapers[0].path,
            location: DownloadLocation.EXTERNAL_DIRECTORY);
      }
      if(sheepState.destination == Destination.BOTH_SEPARATE) {
        await Wallpaper.lockScreen(imageName: wallpapers[1].path,
            location: DownloadLocation.EXTERNAL_DIRECTORY);
      }

      // Signal unbridled Joy
      sheepState.setLastChangeTimestamp();
      onDone();
    } on Exception catch (e) {
      sheepState.log('Change failed', e.toString());
      onDone();
    }
  }

  static Future<List<File>> _generateImages(
      double width, double height,
      SheepState sheepState, int count) async {
    if (sheepState.paths.length == 0) {
      throw Exception("No paths have been added");
    }

    var tyler = new Tyler(sheepState.tileCache);
    List<File> result = [];

    //var directory = await getApplicationDocumentsDirectory();
    var directory = await getExternalStorageDirectory();

    for (int i = 0; i < count; i++) {
      // note that the .jpeg is vital for package:wallpaper/wallpaper.dart to work
      var file = new File(path.join(directory!.path, "background" + i.toString() + ".jpeg"));
      tyler.render(3, width.floor(), height.floor(), file);
      result.add(file);
    }

    return result;
  }
}
