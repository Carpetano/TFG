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

  // Factory constructor to create a HorarioObject from a map
  factory HorarioObject.fromMap(Map<String, dynamic> data) {
    return HorarioObject(
      id: data['id'] as int, // Assuming 'id' field is always present
      type: data['type'] as String, // Assuming 'type' field is always present
      startTime: _parseTimeOfDay(
        data['start_time'] as String,
      ), // Assuming start_time is in string format
      endTime: _parseTimeOfDay(
        data['end_time'] as String,
      ), // Assuming end_time is in string format
    );
  }

  // Helper function to parse TimeOfDay from a string (e.g., "14:30")
  static TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  // Static method to map a list of response data into a list of HorarioObject instances
  static List<HorarioObject> mapFromResponse(List<dynamic>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }
    // Map each entry in the response list to a HorarioObject using the fromMap factory constructor
    return response.map((data) => HorarioObject.fromMap(data)).toList();
  }

  @override
  String toString() {
    return 'HorarioObject(id: $id, type: $type, startTime: ${startTime.format(const TimeOfDay(hour: 0, minute: 0) as BuildContext)}, endTime: ${endTime.format(const TimeOfDay(hour: 0, minute: 0) as BuildContext)})';
  }
}
