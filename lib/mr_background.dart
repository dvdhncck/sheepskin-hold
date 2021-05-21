// @dart=2.9

import 'dart:async';
import "dart:math";
import 'dart:isolate';

import 'dart:convert';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:intl/intl.dart';
import 'package:stream_channel/isolate_channel.dart';

class MrBackground {
  static int count = 0;

  static final DateFormat formatter = DateFormat('yyyy-MM-dd H:m:ss');
  static final _random = new Random(DateTime.now().millisecondsSinceEpoch);

  static List<String> paths;
  static String timeValue;
  static String timeUnit;
  static String destination;

  static DateTime timeForNextUpdate;

  static IsolateChannel channel;

  static void beginBackgroundCheck(SendPort theSendPort) async {
    // start the periodic updater
    backgroundCheck();

    channel = new IsolateChannel.connectSend(theSendPort);

    // listen forever
    channel.stream.listen((data) {
      try {
        var state = Map<String, dynamic>.from(jsonDecode(data));
        timeValue = state['timeValue'];
        timeUnit = state['timeUnit'];
        destination = state['timeValue'];

        onStateUpdate();
      } catch (e) {
        print(e);
        channel.sink.add('{"state_set":"false"}');
      }
    });
  }

  static void sendMessage(String message) {
    if (channel == null) {
    } else {
      channel.sink.add(message);
    }
  }

  static void onStateUpdate() {
    var duration = Duration(hours: 1);
    switch (timeUnit) {
      case "seconds":
        duration = Duration(seconds: 1);
        break;
      case "minutes":
        duration = Duration(minutes: 1);
        break;
      case "hours":
        duration = Duration(hours: 1);
        break;
      case "days":
        duration = Duration(days: 1);
        break;
      case "weeks":
        duration = Duration(days: 7);
        break;
    }
    if(timeValue=="null") {
      // state not yet loaded by front end
    } else {
      var value = int.parse(timeValue);
      timeForNextUpdate = DateTime.now().add(duration * value);

      sendMessage('{"next_update":"${formatter.format(timeForNextUpdate)}"}');
    }
  }

  static void backgroundCheck() {
    count += 1;

    sendMessage('{"heartbeat":${count.toString()}}');

    if (timeForNextUpdate != null) {
      if (DateTime.now().isAfter(timeForNextUpdate)) {
        //doChange();

        sendMessage('{"changing":"${formatter.format(DateTime.now())}"}');

        onStateUpdate();
      }
    }

    Future.delayed(Duration(seconds: 1), backgroundCheck);
  }

  static int _generateRandomAlarmId() {
    return _random.nextInt(pow(2, 31).toInt());
  }

  static void scheduleNextPoking() async {
    // try {
    //   if (periodicAlarmId > -1) {
    //     print("cancelling alarm $periodicAlarmId");
    //     await AndroidAlarmManager.cancel(periodicAlarmId);
    //   } else {
    //     print("no alarm known to be scheduled");
    //   }
    // } catch (e) {
    //   // not important, the alarm was already dead
    // }

    // TODO: work out how long until the next poke is required
    int secondsUntilNextPoke = 10;

    int periodicAlarmId = _generateRandomAlarmId();

    print(
        "[mr.background] set alarm $periodicAlarmId for $secondsUntilNextPoke seconds");

    await AndroidAlarmManager.oneShot(Duration(seconds: secondsUntilNextPoke),
        periodicAlarmId, beginBackgroundCheck,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }
}
