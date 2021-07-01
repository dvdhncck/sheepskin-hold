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
        var sheepState = SheepState.from(sharedPreferences);
        sheepState.log("Alarm fired", "Isn't that nice?");
        Wallpaperer.changeWallpaper(
            sheepState, () => bookAlarmCall(sheepState));

        Future.delayed(Duration(minutes: 1), () {
          if(sheepState.nextChangeIsInThePast()) {
            sheepState.log("Alarm update missing.", "Alarm ${sheepState.nextChangeText} is in the past");
          } else {
            sheepState.log("Alarm is good.", "Scheduled for future, which is good");
          }
        });
      });
    });

  }

  static void _scheduleAlarm(SheepState sheepState) async {
    int count = sheepState.timeValue.value;
    Duration duration = sheepState.timeUnit.duration;
    DateTime target = DateTime.now().add(duration * count);

    print("Alarm target: $target");

    // throws error with message: Attempted to start a duplicate background isolate#

    await AndroidAlarmManager.oneShotAt(
        target, sheepState.alarmId, _onAlarmCall,
        alarmClock: true,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true)
        .then((_) {
      sheepState.setNextChangeTimestamp(target);
      sheepState.log('Scheduled a wakeup call',
          'Alarm set for ${sheepState.nextChangeText}');
      return true;
    }).catchError((e) {
      sheepState.log('Failed to schedule alarm', '${e.toString()}');
      sheepState.clearNextChangeTimestamp();
      return false;
    });
  }
}
