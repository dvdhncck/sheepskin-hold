// @dart=2.9

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:sheepskin/sheepstate.dart';
import 'package:sheepskin/wallpaperer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model.dart';

const String portName = 'quackomatic.sheepskin';

void bookAlarmCall(SheepState sheepState) {
  _cancelExistingAlarmThenSetNewAlarm(sheepState, ()=>{});
}

void _onAlarmCall() async {

  await SharedPreferences.getInstance().then((sharedPreferences) async {
    await sharedPreferences.reload().then((_) {
      var sheepState = SheepState(sharedPreferences);
      sheepState.log("Alarm fired", "Isn't that nice?");
      Wallpaperer.changeWallpaper(sheepState, () => bookAlarmCall(sheepState));
    });
  });

}

/*
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
*/

// TODO: replace onDone with whenComplete()
void _cancelExistingAlarmThenSetNewAlarm(
    SheepState sheepState, Function onDone) async {
  AndroidAlarmManager.cancel(sheepState.alarmId)
      .whenComplete(() => _scheduleAlarm(sheepState, onDone));
}

void _scheduleAlarm(SheepState sheepState, Function onDone) async {
  int count = sheepState.getTimeValue().value;
  Duration duration = sheepState.getTimeUnit().duration;
  DateTime target = DateTime.now().add(duration * count);

  print("Alarm target: $target");

  await AndroidAlarmManager.oneShotAt(
    target,
    sheepState.alarmId,
    _onAlarmCall,
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
