import 'package:flutter/material.dart';

class HorarioObject {
  final int id;
  final String type;
  final TimeOfDay startTime, endTime;
  HorarioObject({
    required this.id,
    required this.type,
    required this.startTime,
    required this.endTime,
  });

  @override
  String toString() {
    return 'HorarioObject(id: $id, type: $type, startTime: ${startTime.format(const TimeOfDay(hour: 0, minute: 0) as BuildContext)}, endTime: ${endTime.format(const TimeOfDay(hour: 0, minute: 0) as BuildContext)})';
  }
}
