// ignore_for_file: avoid_print

import 'package:codigo/Objetos/guardia_object.dart';
import 'package:codigo/Paginas/view_guardias_page.dart';
import 'package:codigo/main.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:codigo/Paginas/asignar_guardia.dart';
import 'package:codigo/Paginas/add_ausencia_page.dart';
import 'package:codigo/Paginas/mis_guardias.dart';
import 'package:codigo/Paginas/perfil_page.dart';
import 'package:codigo/Paginas/ajustes_page.dart';
import 'package:codigo/Paginas/register_user_page.dart';

class ProfesorMainMenuPage extends StatefulWidget {
  const ProfesorMainMenuPage({super.key});

  @override
  _ProfesorMainMenuPageState createState() => _ProfesorMainMenuPageState();
}

class _ProfesorMainMenuPageState extends State<ProfesorMainMenuPage> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  List<GuardiaObject> unasignedGuardias = [];

  @override
  void initState() {
    super.initState();
    fetchUnasignedGuardias(); // Fetch the unassigned guardias when the page is initialized
  }

  Future<void> fetchUnasignedGuardias() async {
    final response = await SupabaseManager.instance.getUnasignedGuardias();
    print(response);
    setState(() {
      unasignedGuardias = response; // Store the fetched guardias in the list
    });
  }

  // Make this a synchronous function to be compatible with eventLoader
  List<GuardiaObject> _getEventsForDay(DateTime day) {
    // Filter the guardias that match the selected day
    return unasignedGuardias
        .where((guardia) => isSameDay(guardia.day, day))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profesor: ${MyApp.loggedInUser?.firstName ?? 'Desconocido'}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'perfil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilPage()),
                );
              } else if (value == 'ajustes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AjustesPage()),
                );
              } else if (value == 'salir') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationPage(),
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'perfil',
                    child: Text('Ver Perfil'),
                  ),
                  const PopupMenuItem(value: 'ajustes', child: Text('Ajustes')),
                  const PopupMenuItem(
                    value: 'salir',
                    child: Text('Cerrar Sesión'),
                  ),
                ],
            icon: const Icon(
              Icons.account_circle,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate:
                (day) => _selectedDay != null && isSameDay(_selectedDay, day),
            eventLoader:
                _getEventsForDay, // Use _getEventsForDay to load events
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_selectedDay != null &&
                    isSameDay(_selectedDay, selectedDay)) {
                  _selectedDay = null;
                } else {
                  _selectedDay = selectedDay;

                  // Check if there are unassigned guardias for the selected day
                  List<GuardiaObject> events = _getEventsForDay(selectedDay);
                  if (events.isNotEmpty) {
                    print(
                      "Selected date has ${events.length} unassigned guardias.",
                    );
                  }
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
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                // Show a marker if events are present for the day
                if (events.isNotEmpty) {
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

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
                          );
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
              ElevatedButton(
                onPressed:
                    _selectedDay != null
                        ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      ViewGuardiasPage(day: _selectedDay!),
                            ),
                          );
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
                child: const Text("Ver Ausencias"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
