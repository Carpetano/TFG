// calendar_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

// Calendar Page where the user selects a single date
class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime? _selectedDate; // Store the selected date

  // Function to display the selected date
  String get _selectedDateText {
    if (_selectedDate == null) {
      return 'No date selected';
    } else {
      return 'Selected Date: ${_selectedDate?.toLocal().toString()}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Day Picker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 01, 01),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: DateTime.now(),
              selectedDayPredicate: (day) {
                // Highlight the selected date
                return _selectedDate != null && day.isSameDay(_selectedDate!);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  // Set the selected date when a day is clicked
                  _selectedDate = selectedDay;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(_selectedDateText, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            // Button to perform action with the selected date
            ElevatedButton(
              onPressed: () {
                if (_selectedDate != null) {
                  // You can perform any action with the selected date here
                  print('You selected: $_selectedDate');
                } else {
                  // If no date is selected, show an error message
                  print('No date selected');
                }
              },
              child: const Text("Confirm Date"),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to compare DateTime objects (ignoring time)
extension DateIsSameDay on DateTime {
  bool isSameDay(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}
