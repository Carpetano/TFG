// ignore_for_file: avoid_print

import 'package:codigo/Objetos/guardia_object.dart'; // Correct the file name here

import 'package:codigo/main.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:codigo/Paginas/asignar_guardia.dart';
import 'package:codigo/Paginas/add_ausencia_page.dart';
import 'package:codigo/Paginas/mis_guardias.dart';

class ProfesorMainMenuPage extends StatefulWidget {
  const ProfesorMainMenuPage({super.key});

  @override
  _ProfesorMainMenuPageState createState() => _ProfesorMainMenuPageState();
}

class _ProfesorMainMenuPageState extends State<ProfesorMainMenuPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  List<GuardiaObject> unasignedGuardias = []; // Holds all retrieved ausencias

  @override
  void initState() {
    super.initState();
    // Fetch initial data from the database
    fetchAllUnasignedGuardias();
  }

  /// Fetches all pending guardias from Supabase and updates state.
  Future<void> fetchAllUnasignedGuardias() async {
    try {
      final response = await SupabaseManager.instance.getAllUnasignedGuardias();

      // Debug print: Show the number of guardias fetched
      print("Fetched ${response.length} unasigned guardias:");

      // Debug print: Print each guardia's details
      for (var guardia in response) {
        print(
          "Guardia: ${guardia.toString()}",
        ); // Assuming you have a toJson() method
      }

      setState(() {
        unasignedGuardias = response;
      });
    } catch (e) {
      print("Error fetching unasigned guardias: $e");
    }
  }

  /// Returns a list of unasigned guardias for a given day.
  List<GuardiaObject> _getEventsForDay(DateTime day) {
    // Exclude weekends (Saturday = 6, Sunday = 7)
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return [];
    }

    return unasignedGuardias.where((guardia) {
      // Extract the date from tramoHorario assuming it represents a timestamp
      final DateTime eventDate = DateTime.fromMillisecondsSinceEpoch(
        guardia.tramoHorario * 1000,
      );

      // Check if the event date matches the selected day (ignoring time)
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profesor: ${MyApp.loggedInUser?.firstName ?? 'Desconocido'}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: const [
          Icon(Icons.account_circle, size: 30, color: Colors.white),
          SizedBox(width: 10),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CALENDAR
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate:
                (day) => _selectedDay != null && isSameDay(_selectedDay, day),
            eventLoader:
                _getEventsForDay, // Returns ausencias for the given day
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_selectedDay != null &&
                    isSameDay(_selectedDay, selectedDay)) {
                  _selectedDay = null;
                } else {
                  _selectedDay = selectedDay;
                }
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                fontSize: 18,
              ),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.orangeAccent
                        : Colors.red,
              ),
              outsideTextStyle: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black38,
              ),
              defaultDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.grey, width: 1),
              ),
              todayDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.blueAccent, width: 2),
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  // Draw a small red circular marker at the bottom-center of the cell.
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // BOTTOM BUTTONS
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Button to navigate to AsignarGuardia page
              ElevatedButton(
                onPressed:
                    _selectedDay != null
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AsignarGuardia(),
                            ),
                          ).then((_) {
                            // Refresh ausencias after returning from the page
                            fetchAllUnasignedGuardias();
                          });
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedDay != null
                          ? Colors.blueAccent
                          : Colors.grey[400],
                  foregroundColor:
                      _selectedDay != null ? Colors.black : Colors.grey[600],
                ),
                child: const Text("Asignar guardia"),
              ),
              // Button to navigate to AddAusenciaPage
              ElevatedButton(
                onPressed:
                    _selectedDay != null
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      AddAusenciaPage(day: _selectedDay!),
                            ),
                          ).then((_) {
                            // Refresh ausencias after returning from the page
                            fetchAllUnasignedGuardias();
                          });
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _selectedDay != null
                          ? Colors.blueAccent
                          : Colors.grey[400],
                  foregroundColor:
                      _selectedDay != null ? Colors.black : Colors.grey[600],
                ),
                child: const Text("Añadir Ausencia"),
              ),
              // Button to navigate to MisGuardias page
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MisGuardias(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text("Ver mis guardias"),
              ),
            ],
          ),
          // A button for debugging: prints the selected date.
          ElevatedButton(
            onPressed: () {
              if (_selectedDay != null) {
                print("Selected date: $_selectedDay");
              } else {
                print("No date selected");
              }
            },
            child: const Text("Print Selected Date"),
          ),
        ],
      ),
    );
  }
}
