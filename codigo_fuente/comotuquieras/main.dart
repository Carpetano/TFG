import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'screens/asignar_guardia.dart';
import 'screens/anadir_baja.dart';
import 'screens/mis_guardias.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Guardias',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.blueAccent,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueAccent,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: const CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profesor: {Nombre}", style: TextStyle(color: Colors.white)),
        actions: const [
          Icon(Icons.account_circle, size: 30, color: Colors.white),
          SizedBox(width: 10),
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
            selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_selectedDay != null && isSameDay(_selectedDay, selectedDay)) {
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
              titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18),
            ),
            calendarStyle: CalendarStyle(
              defaultDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.black12, width: 1),
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: Colors.blueAccent, width: 1),
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _selectedDay != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AsignarGuardia()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedDay != null ? Colors.blueAccent : Colors.grey[400],
                  foregroundColor: _selectedDay != null ? Colors.black : Colors.grey[600],
                ),
                child: const Text("Asignar guardia"),
              ),
              ElevatedButton(
                onPressed: _selectedDay != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AnadirBaja()),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedDay != null ? Colors.blueAccent : Colors.grey[400],
                  foregroundColor: _selectedDay != null ? Colors.black : Colors.grey[600],
                ),
                child: const Text("Añadir baja"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MisGuardias()),
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
        ],
      ),
    );
  }
}