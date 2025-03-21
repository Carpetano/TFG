import 'package:flutter/material.dart';

/// Object representing a schedule in the database, holds the id, whether the schedule type, morning, afternoon or nocturnal, and from how much time it covers
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

  factory HorarioObject.fromMap(Map<String, dynamic> data) {
    return HorarioObject(
      id: data['id'] as int,
      type: data['type'] as String,
      startTime: _parseTimeOfDay(data['start_time'] as String),
      endTime: _parseTimeOfDay(data['end_time'] as String),
    );
  }

  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static List<HorarioObject> mapFromResponse(List<dynamic>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }

    return response.map((data) => HorarioObject.fromMap(data)).toList();
  }

  @override
  String toString() {
    return 'HorarioObject(id: $id, type: $type, startTime: ${startTime.format(const TimeOfDay(hour: 0, minute: 0) as BuildContext)}, endTime: ${endTime.format(const TimeOfDay(hour: 0, minute: 0) as BuildContext)})';
  }
}
