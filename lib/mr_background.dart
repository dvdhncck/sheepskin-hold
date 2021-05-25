// @dart=2.9

import 'package:sheepskin/model.dart';
import 'package:sheepskin/sheepskin.dart';
import 'package:sheepskin/wallpaperer.dart';

class MrBackground {
  DateTime timeForNextUpdate;
  int frequencyInSeconds;

  Wallpaperer wallpaperer;
  SheepSkin sheepSkin;

  MrBackground(this.sheepSkin, this.wallpaperer, this.frequencyInSeconds);

  void beginBackgroundCheck() async {
    doBackgroundCheck();
  }

  void doBackgroundCheck() {
    sheepSkin.log('heartbeat','expected every $frequencyInSeconds');

    if (timeForNextUpdate != null) {
      if (DateTime.now().isAfter(timeForNextUpdate)) {
        sheepSkin.log('time for a change','');
        wallpaperer.changeWallpaper(sheepSkin.notifyUi);
        chooseTheTimeForNextUpdate();
        sheepSkin.notifyUi();
      }
    }

    Future.delayed(Duration(seconds: frequencyInSeconds), doBackgroundCheck);
  }

  void chooseTheTimeForNextUpdate() {
    int count = sheepSkin.getTimeValue().value;
    Duration duration = sheepSkin.getTimeUnit().duration;

    timeForNextUpdate = DateTime.now().add(duration * count);

    sheepSkin.notifyTimeOfNextWallpaperChange(timeForNextUpdate);
  }
}
