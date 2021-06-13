// @dart=2.9

import 'dart:async';

import 'package:sheepskin/sheepskin.dart';
import 'package:sheepskin/wallpaperer.dart';

class MrBackground {
  DateTime timeForNextUpdate;

  Wallpaperer wallpaperer;
  SheepSkin sheepSkin;

  MrBackground(this.sheepSkin, this.wallpaperer);

  Timer timer;

  void beginBackgroundCheck() async {
    chooseTheTimeForNextUpdate();
  }

  void doBackgroundCheck() {
    timer = null;
    if (timeForNextUpdate != null) {
      if (DateTime.now().isAfter(timeForNextUpdate)) {
        wallpaperer.changeWallpaper(sheepSkin.notifyUi);
      } else {
        sheepSkin.log('Too soon', 'Timer fired too early');
      }
    } else {
      sheepSkin.log('Wonky data', 'timeForNextUpdate not set');
    }
    chooseTheTimeForNextUpdate();
  }

  void chooseTheTimeForNextUpdate() {
    int count = sheepSkin.getTimeValue().value;
    Duration duration = sheepSkin.getTimeUnit().duration;

    var pauseForEffect = duration * count;

    timeForNextUpdate = DateTime.now().add(pauseForEffect);

    if (timer != null) {
      sheepSkin.log('Cancelling wakeup call','');
      timer.cancel();
    }

    timer = new Timer(
        pauseForEffect + Duration(milliseconds: 100), doBackgroundCheck);

    sheepSkin.log('Scheduled a wakeup call',
        'Alarm set for ${sheepSkin.getNextChangeAsText()}');

    sheepSkin.notifyTimeOfNextWallpaperChange(timeForNextUpdate);
  }
}
