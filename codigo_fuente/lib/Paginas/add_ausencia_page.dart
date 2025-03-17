// ignore_for_file: avoid_print

import 'package:codigo/aula_object.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:codigo/user_object.dart';
import 'package:flutter/material.dart';

class AddAusenciaPage extends StatefulWidget {
  const AddAusenciaPage({super.key});

  @override
  State<AddAusenciaPage> createState() => _AddAusenciaPageState();
}

class _AddAusenciaPageState extends State<AddAusenciaPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? selectedStatus = 'Pendiente';
  String? selectedTeacherId;
  String? selectedAulaCode;
  List<UserObject>? teachersToAssign;
  List<AulaObject>? classesToAssign;

  // Create a controller for the Tarea TextFormField
  final TextEditingController tareaController = TextEditingController();

  // Time pickers for Start and End time
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;

  @override
  void initState() {
    super.initState();
    populateActiveUsersList();
    populateAulasList();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    tareaController.dispose(); // Don't forget to dispose of the controller
    _controller.dispose();
    super.dispose();
  }

  Future<void> populateActiveUsersList() async {
    List<UserObject> fetchedTeachers =
        await SupabaseManager.instance.getActiveUsers();
    setState(() {
      teachersToAssign = fetchedTeachers;
    });
  }

  Future<void> populateAulasList() async {
    List<AulaObject> fetchedAulas =
        await SupabaseManager.instance.getAllAulas();
    setState(() {
      classesToAssign = fetchedAulas;
    });
  }

  void insertAusencia() {
    // Check if required fields are not null before proceeding
    if (selectedTeacherId == null ||
        selectedAulaCode == null ||
        selectedStatus == null ||
        selectedStartTime == null ||
        selectedEndTime == null) {
      print("Error: All fields except Tarea must be filled.");
      return; // Exit the function if any required field is missing
    }

    // Convert selectedTeacherId to int if it's a string
    int teacherId = int.tryParse(selectedTeacherId!) ?? 0;

    if (teacherId == 0) {
      print("Error: Invalid teacher ID.");
      return;
    }

    // Convert TimeOfDay to DateTime
    DateTime startDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      selectedStartTime!.hour,
      selectedStartTime!.minute,
    );

    DateTime endDateTime = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      selectedEndTime!.hour,
      selectedEndTime!.minute,
    );

    // Print the selected data
    print("");
    print("Selected teacher: $selectedTeacherId");
    print("Selected classroom: $selectedAulaCode");
    print("Selected status: $selectedStatus");
    print("Tarea (Task): ${tareaController.text}"); // Print the Tarea value
    print("Start time: ${startDateTime.toIso8601String()}");
    print("End time: ${endDateTime.toIso8601String()}");

    // Call the insert function with the correct types
    SupabaseManager.instance.insertAusencia(
      teacherId, // Pass the int value for teacherId
      selectedAulaCode!,
      selectedStatus!,
      tareaController.text,
      startDateTime,
      endDateTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Añadir ausencia")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // USER TO SET AS MISSING
            DropdownButtonFormField<String>(
              value: selectedTeacherId,
              decoration: InputDecoration(
                hintText: "Seleccionar profesor",
                border: OutlineInputBorder(),
              ),
              items:
                  (teachersToAssign ?? [])
                      .map(
                        (teacher) => DropdownMenuItem(
                          value: teacher.id.toString(),
                          child: Text(
                            "${teacher.firstName} ${teacher.lastName}",
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
            SizedBox(height: 16),

            // CLASSROOM SELECTION (NEW)
            DropdownButtonFormField<String>(
              value: selectedAulaCode,
              decoration: InputDecoration(
                hintText: "Seleccionar aula",
                border: OutlineInputBorder(),
              ),
              items:
                  (classesToAssign ?? [])
                      .map(
                        (aula) => DropdownMenuItem(
                          value: aula.classcode,
                          child: Text(
                            "${aula.classcode} - ${aula.floor} ${aula.wing}",
                          ),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedAulaCode = value;
                });
              },
            ),
            SizedBox(height: 16),

            // STATUS OF THE AUSENCIA (by default Pendiente)
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: InputDecoration(
                hintText: "Estado",
                border: OutlineInputBorder(),
              ),
              items:
                  ["Pendiente", "Asignada"]
                      .map(
                        (status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
            SizedBox(height: 16),

            // TAREA (Task) - Attach the controller here
            TextFormField(
              controller: tareaController, // Use the controller here
              decoration: InputDecoration(hintText: "Tarea"),
            ),
            SizedBox(height: 10),

            // Start Time Picker
            TextFormField(
              decoration: InputDecoration(hintText: "Hora de inicio"),
              onTap: () async {
                TimeOfDay? pickedStartTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedStartTime != null) {
                  setState(() {
                    selectedStartTime = pickedStartTime;
                  });
                }
              },
              controller: TextEditingController(
                text:
                    selectedStartTime != null
                        ? selectedStartTime!.format(context)
                        : '',
              ),
            ),
            SizedBox(height: 10),

            // End Time Picker
            TextFormField(
              decoration: InputDecoration(hintText: "Hora de fin"),
              onTap: () async {
                TimeOfDay? pickedEndTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedEndTime != null) {
                  setState(() {
                    selectedEndTime = pickedEndTime;
                  });
                }
              },
              controller: TextEditingController(
                text:
                    selectedEndTime != null
                        ? selectedEndTime!.format(context)
                        : '',
              ),
            ),
            SizedBox(height: 10),

            // BUTTON TO INSERT AUSENCIA
            ElevatedButton(onPressed: insertAusencia, child: Text("Confirmar")),
          ],
        ),
      ),
    );
  }
}
