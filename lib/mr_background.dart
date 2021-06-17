// @dart=2.9

import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:sheepskin/sheepskin.dart';
import 'package:sheepskin/wallpaperer.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String portName = 'quackomatic.sheepskin';


void _onAlarmCall() async {
  // ReceivePort rcPort = new ReceivePort();
  // IsolateNameServer.registerPortWithName(rcPort.sendPort, portName);
  // rcPort.listen((state) {
  //   print('_onAlarmCall: got some state...');
  // });
  // //sheepSkin.log('Brrrring!', 'Time to get busy');
  // //wallpaperer.changeWallpaper(() { bookAlarmCall(sheepSkin.notifyUi); });


  print("Alarm fired");

  await SharedPreferences.getInstance().then((sharedPreferences) {
    var paths = sharedPreferences.getStringList('paths');
    print('_onAlarmCall: found some paths $paths');


  });


}

class MrBackground {
  Wallpaperer wallpaperer;
  SheepSkin sheepSkin;

  MrBackground(this.sheepSkin, this.wallpaperer);

  void bookAlarmCall(Function onDone) {
    _cancelExistingAlarmThenSetNewAlarm(onDone);
  }

  void _cancelExistingAlarmThenSetNewAlarm(Function onDone) async {
    AndroidAlarmManager.cancel(sheepSkin.getAlarmId())
        .whenComplete(_scheduleAlarm)
        .whenComplete(onDone);
  }

  void _scheduleAlarm() async {
    int count = sheepSkin.getTimeValue().value;
    Duration duration = sheepSkin.getTimeUnit().duration;
    DateTime target = DateTime.now().add(duration * count);

    print("Alarm target: $target");

    await AndroidAlarmManager.oneShotAt(
            target, sheepSkin.getAlarmId(), _onAlarmCall,
            )
        .then((_) {
      sheepSkin.notifyTimeOfNextWallpaperChange(target);
      sheepSkin.log('Scheduled a wakeup call',
          'Alarm set for ${sheepSkin.getNextChangeAsText()}');
      sheepSkin.notifyTimeOfNextWallpaperChange(target);
    }).catchError((e) {
      sheepSkin.log('Failed to schedule alarm', '${e.toString()}');
      sheepSkin.notifyTimeOfNextWallpaperChange(null);
    });
  }
}
