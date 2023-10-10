import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  DateTime applied(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }

  TimeOfDay daytime(DateTime dt){
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  DateTime datetime(DateTime dt){
    return DateTime(year, month, day, dt.hour, dt.minute);
  }
}