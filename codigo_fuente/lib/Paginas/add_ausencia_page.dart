// ignore_for_file: avoid_print

import 'package:codigo/Objetos/aula_object.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';

class AddAusenciaPage extends StatefulWidget {
  DateTime day;
  AddAusenciaPage({super.key, required this.day});

  @override
  State<AddAusenciaPage> createState() => _AddAusenciaPageState();
}

class _AddAusenciaPageState extends State<AddAusenciaPage> {
  final TextEditingController comentarioController = TextEditingController();

  List<UserObject> teachersToAssign = [];
  List<AulaObject> classesToSelect = [];
  String? selectedTeacherId;
  String? selectedClassCode; // Variable to store selected Aula (class)

  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isAllDay = true;

  @override
  void initState() {
    super.initState();
    populateActiveUsersList();
    populateClasesToSelect();
  }

  Future<TimeOfDay?> pickTime(
    BuildContext context,
    TimeOfDay? initialTime,
  ) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  Future<void> populateActiveUsersList() async {
    List<UserObject> fetchedTeachers =
        await SupabaseManager.instance.getActiveUsers();
    setState(() {
      teachersToAssign = fetchedTeachers;
    });
  }

  Future<void> populateClasesToSelect() async {
    List<AulaObject> fetchedClases =
        await SupabaseManager.instance.getAllAulas();
    setState(() {
      classesToSelect = fetchedClases;
    });
  }

  void insertAusencia() {
    if (selectedTeacherId == null ||
        selectedClassCode == null ||
        (!isAllDay && (startTime == null || endTime == null))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona profesor, aula y horarios'),
        ),
      );
      return;
    }

    // If "All Day" is selected, set times to 00:00 and 23:59 respectively.
    TimeOfDay start =
        isAllDay ? const TimeOfDay(hour: 0, minute: 0) : startTime!;
    TimeOfDay end = isAllDay ? const TimeOfDay(hour: 23, minute: 59) : endTime!;

    // Use the selected day passed via widget.day.
    DateTime selectedDay = widget.day;

    // Build DateTime values for the start and end times on that day,
    // then convert them to UTC so they are stored correctly.
    DateTime horaInicio =
        DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          start.hour,
          start.minute,
        ).toUtc();

    DateTime horaFin =
        DateTime(
          selectedDay.year,
          selectedDay.month,
          selectedDay.day,
          end.hour,
          end.minute,
        ).toUtc();

    // Print the values for debugging (display in local time)
    print('\nProfesor ID: $selectedTeacherId');
    print('Aula: $selectedClassCode');
    print('Inicio: ${start.format(context)}}');
    print('Fin: ${end.format(context)}}');
    print('Comentario: ${comentarioController.text}');

    // Convert teacher id from string to int.
    int teacherId = int.tryParse(selectedTeacherId!) ?? 0;

    // Call the Supabase insertion method.
    SupabaseManager.instance.insertAusencia(
      teacherId,
      selectedClassCode!,
      "Pendiente",
      comentarioController.text,
      horaInicio,
      horaFin,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Ausencia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Label for professor missing
            const Text(
              'Profesor Ausente:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // Dropdown for teacher selection
            DropdownButtonFormField<String>(
              value: selectedTeacherId,
              decoration: const InputDecoration(
                hintText: "Seleccionar profesor",
                border: OutlineInputBorder(),
              ),
              items:
                  teachersToAssign
                      .map(
                        (teacher) => DropdownMenuItem(
                          value: teacher.id.toString(),
                          child: Text(
                            "${teacher.firstName} ${teacher.lastName} ${teacher.secondLastName} ${teacher.id}",
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedTeacherId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // Dropdown for aula (class) selection
            const Text(
              'Seleccionar aula:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedClassCode,
              decoration: const InputDecoration(
                hintText: "Seleccionar aula",
                border: OutlineInputBorder(),
              ),
              items:
                  classesToSelect
                      .map(
                        (aula) => DropdownMenuItem(
                          value: aula.classcode,
                          child: Text(
                            "Grupo: ${aula.group} Planta: ${aula.floor.isEmpty ? 'N/A' : aula.floor} Ala: ${aula.wing.isEmpty ? 'N/A' : aula.floor} Codigo: ${aula.classcode}",
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedClassCode = value;
                });
              },
            ),
            const SizedBox(height: 20),
            // All-Day Checkbox
            Row(
              children: [
                Checkbox(
                  value: isAllDay,
                  onChanged: (value) {
                    setState(() {
                      isAllDay = value!;
                      if (isAllDay) {
                        startTime = const TimeOfDay(hour: 0, minute: 0);
                        endTime = const TimeOfDay(hour: 23, minute: 59);
                      }
                    });
                  },
                ),
                const Text('Todo el día', style: TextStyle(fontSize: 16)),
              ],
            ),
            // Row for start & end time pickers if not all-day
            if (!isAllDay)
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hora de inicio:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText:
                                startTime != null
                                    ? startTime!.format(context)
                                    : 'Seleccionar hora',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.access_time),
                          ),
                          onTap: () async {
                            TimeOfDay? picked = await pickTime(
                              context,
                              startTime,
                            );
                            if (picked != null) {
                              setState(() => startTime = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hora de finalización:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText:
                                endTime != null
                                    ? endTime!.format(context)
                                    : 'Seleccionar hora',
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.access_time),
                          ),
                          onTap: () async {
                            TimeOfDay? picked = await pickTime(
                              context,
                              endTime,
                            );
                            if (picked != null) {
                              setState(() => endTime = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            // Comentario Text Field
            const Text(
              'Comentario:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: comentarioController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Comentarios (tarea, detalles, etc.)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            // Buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: insertAusencia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.only(left: 60, right: 60),
                  ),
                  child: const Text('Guardar Baja'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.only(left: 60, right: 60),
                  ),
                  child: const Text('Volver'),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
