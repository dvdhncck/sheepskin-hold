// @dart=2.9

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:sheepskin/sheepstate.dart';
import 'package:sheepskin/wallpaperer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MrBackground {

  static void bookAlarmCall(SheepState sheepState) {
    AndroidAlarmManager.cancel(sheepState.alarmId)
        .whenComplete(() => _scheduleAlarm(sheepState));
  }

  static void _onAlarmCall() async {
    await SharedPreferences.getInstance().then((sharedPreferences) async {
      await sharedPreferences.reload().then((_) {
        var sheepState = SheepState(sharedPreferences);
        sheepState.log("Alarm fired", "Isn't that nice?");
        Wallpaperer.changeWallpaper(
            sheepState, () => bookAlarmCall(sheepState));
      });
    });
  }

  static void _scheduleAlarm(SheepState sheepState) async {
    int count = sheepState
        .getTimeValue()
        .value;
    Duration duration = sheepState
        .getTimeUnit()
        .duration;
    DateTime target = DateTime.now().add(duration * count);

    print("Alarm target: $target");

    // throws error with message: Attempted to start a duplicate background isolate#

    await AndroidAlarmManager.oneShotAt(
        target,
        sheepState.alarmId,
        _onAlarmCall,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true
    ).then((_) {
      sheepState.setNextChangeTimestamp(target);
      sheepState.log('Scheduled a wakeup call',
          'Alarm set for ${sheepState.getNextChangeTimestampAsText()}');
      return true;
    }).catchError((e) {
      sheepState.log('Failed to schedule alarm', '${e.toString()}');
      sheepState.setNextChangeTimestamp(null);
      return false;
    });
  }
}