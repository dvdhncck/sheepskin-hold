// @dart=2.9

import 'package:shared_preferences/shared_preferences.dart';

class LogMessage {
  String timestamp;
  String message;

  LogMessage(this.timestamp, this.message);

  static List<LogMessage> retrieveFrom(SharedPreferences sharedPreferences) {
    List<LogMessage> result = [];
    List<String> messages = sharedPreferences.getStringList("logMessages");
    List<String> timestamps = sharedPreferences.getStringList("logTimestamps");
    if (messages != null && timestamps != null) {
      for (int i = 0; i < messages.length; i++) {
        result.add(LogMessage(timestamps[i], messages[i]));
      }
    }
    return result;
  }

  static void persistTo(
      List<LogMessage> list, SharedPreferences sharedPreferences) {
    List<String> messages = [];
    List<String> timestamps = [];
    for (int i = 0; i < list.length; i++) {
      messages.add(list[i].message);
      timestamps.add(list[i].timestamp);
    }
    sharedPreferences.setStringList("logMessages", messages);
    sharedPreferences.setStringList("logTimestamps", timestamps);
  }
}
