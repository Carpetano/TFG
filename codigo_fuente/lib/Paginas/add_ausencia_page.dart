// ignore_for_file: avoid_print

import 'package:codigo/Objetos/aula_object.dart';
import 'package:codigo/Objetos/ausencia_object.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/main.dart';
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

  bool isAllDay = true;

  // New variables for Diurno, Verspertino, Nocturno and checkboxes
  String? selectedTurno;
  Map<int, bool> checkboxes = {
    1: false,
    2: false,
    3: false,
    4: false,
    5: false,
    6: false,
    7: false,
  };
  bool selectAllCheckboxes = false;

  @override
  void initState() {
    super.initState();
    populateActiveUsersList();
    populateClasesToSelect();
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

  Future<void> insertAusencia() async {
    // Add print statements to debug the values of the form fields
    print("selectedClassCode: $selectedClassCode");
    print("selectedTurno: $selectedTurno");

    if (selectedClassCode == null || selectedTurno == null) {
      // Ensure a turno is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona profesor, aula y turno'),
        ),
      );
      return;
    }

    // Collect selected checkboxes (1-7)
    List<int> selectedCheckboxes =
        checkboxes.entries
            .where(
              (entry) => entry.value,
            ) // Only get the entries where the checkbox is checked
            .map((entry) => entry.key) // Get the checkbox number (1-7)
            .toList();

    // Print the values for debugging
    print('\nProfesor ID: ${MyApp.loggedInUser?.id}');
    print('Aula: $selectedClassCode');
    print('Turno: $selectedTurno');
    print('Comentario: ${comentarioController.text}');
    print('Checkboxes seleccionados: ${selectedCheckboxes.join(", ")}');

    AusenciaObject? ausencia = await SupabaseManager.instance.insertAusencia(
      MyApp.loggedInUser!.id,
      selectedClassCode!,
    );
    if (ausencia != null) {
      print('Inserted ausencia: $ausencia');
    } else {
      print('Failed to insert ausencia');
    }

    // Continue with your logic to insert data into Supabase or handle it further.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Añadir Ausencia')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
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

            // Dropdown for Turno (Diurno, Verspertino, Nocturno)
            const Text(
              'Seleccionar turno:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedTurno,
              decoration: const InputDecoration(
                hintText: "Seleccionar turno",
                border: OutlineInputBorder(),
              ),
              items:
                  ["Diurno", "Verspertino", "Nocturno"]
                      .map(
                        (turno) =>
                            DropdownMenuItem(value: turno, child: Text(turno)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedTurno = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // Checkbox to select all 1-7
            Row(
              children: [
                Checkbox(
                  value: selectAllCheckboxes,
                  onChanged: (bool? value) {
                    setState(() {
                      selectAllCheckboxes = value!;
                      if (selectAllCheckboxes) {
                        checkboxes = {
                          1: true,
                          2: true,
                          3: true,
                          4: true,
                          5: true,
                          6: true,
                          7: true,
                        };
                      } else {
                        checkboxes = {
                          1: false,
                          2: false,
                          3: false,
                          4: false,
                          5: false,
                          6: false,
                          7: false,
                        };
                      }
                    });
                  },
                ),
                const Text('Seleccionar todos'),
              ],
            ),
            // Checkboxes for 1 to 7
            Row(
              children: List.generate(7, (index) {
                return Expanded(
                  child: CheckboxListTile(
                    title: Text((index + 1).toString()),
                    value: checkboxes[index + 1],
                    onChanged: (bool? value) {
                      setState(() {
                        checkboxes[index + 1] = value!;
                        selectAllCheckboxes = checkboxes.values.every((e) => e);
                      });
                    },
                  ),
                );
              }),
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
                  child: const Text('Guardar Ausencia'),
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
