// @dart=2.9

import 'package:shared_preferences/shared_preferences.dart';

class LogMessage {
  String timestamp;
  String message;
  String details;

  LogMessage(this.timestamp, this.message, this.details);

  static List<LogMessage> retrieveFrom(SharedPreferences sharedPreferences) {
    List<LogMessage> result = [];
    List<String> details = sharedPreferences.getStringList("logDetails");
    List<String> messages = sharedPreferences.getStringList("logMessages");
    List<String> timestamps = sharedPreferences.getStringList("logTimestamps");
    if (details != null && messages != null && timestamps != null) {
      for (int i = 0; i < messages.length; i++) {
        result.add(LogMessage(timestamps[i], messages[i], details[i]));
      }
    }
    return result;
  }

  static void persistTo(
      List<LogMessage> list, SharedPreferences sharedPreferences) {
    List<String> details = [];
    List<String> messages = [];
    List<String> timestamps = [];
    for (int i = 0; i < list.length; i++) {
      details.add(list[i].message);
      messages.add(list[i].message);
      timestamps.add(list[i].timestamp);
    }
    sharedPreferences.setStringList("logDetails", details);
    sharedPreferences.setStringList("logMessages", messages);
    sharedPreferences.setStringList("logTimestamps", timestamps);
  }
}
