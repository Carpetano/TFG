// ignore_for_file: avoid_print

import 'package:codigo/Objetos/guardia_object.dart'; // Correct the file name here
import 'package:codigo/Objetos/aula_object.dart';
import 'package:codigo/Objetos/ausencia_object.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/global_settings.dart';
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

  /// Displays a snackbar message at the bottom of the screen
  /// This function creates a snackbar with the provided message, text color,
  /// and background color, then displays it using the ScaffoldMessenger
  ///
  /// - [message]: The text content of the snackbar
  /// - [textColor]: The color of the text inside the snackbar
  /// - [bgColor]: The background color of the snackbar
  void showSnackBar(String message, Color textColor, Color bgColor) {
    var snackBar = SnackBar(
      content: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Text(message),
      ),
      backgroundColor: bgColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> insertAusencia() async {
    if (selectedClassCode == null || selectedTurno == null) {
      // Ensure a turno is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translations.translate('plsSelectTeacherClassAndShift'),
          ),
        ),
      );
      showSnackBar("Insertado correctamente", Colors.white, Colors.black);
      return;
    }

    // Collect selected checkboxes (1-7)
    List<int> selectedCheckboxes =
        checkboxes.entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList();

    // Apply the turno offset to the selected checkboxes
    int turnoOffset = 0;
    if (selectedTurno == 'Verspertino') {
      turnoOffset = 7; // Shift values by 7 for Verspertino
    } else if (selectedTurno == 'Nocturno') {
      turnoOffset = 14; // Shift values by 14 for Nocturno
    }

    // Apply the calculated offset
    List<int> shiftedCheckboxes =
        selectedCheckboxes
            .map((checkboxId) => checkboxId + turnoOffset)
            .toList();

    AusenciaObject? ausencia = await SupabaseManager.instance.insertAusencia(
      MyApp.loggedInUser!.id,
      selectedClassCode!,
      widget.day, // Pass the page's day
    );

    print("AUSENCIA INSERTED: $ausencia");
    if (ausencia != null) {
      print("Successfully inserted Ausencia with ID: ${ausencia.id}");

      if (ausencia.id == 0) {
        print(
          "Error: Received an invalid id_ausencia (0). Aborting guardia insert.",
        );
        return;
      }

      List<GuardiaObject> guardiasToInsert =
          shiftedCheckboxes.map((checkboxId) {
            return GuardiaObject(
              missingTeacherId: MyApp.loggedInUser!.id,
              ausenciaId: ausencia.id,
              observations: comentarioController.text,
              tramoHorario: checkboxId,
              substituteTeacherId: 0,
              status: 'Pendiente',
              id: 0,
              day: widget.day,
            );
          }).toList();

      await SupabaseManager.instance.insertGuardias(guardiasToInsert);
    } else {
      print('Failed to insert ausencia.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar for a modern look
      appBar: AppBar(
        title: Text(
          Translations.translate('addAusencia'),
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            // Card for Aula selection
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Translations.translate('selectClass'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedClassCode,
                      decoration: const InputDecoration(
                        hintText: "Seleccionar aula",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          classesToSelect
                              .map(
                                (aula) => DropdownMenuItem(
                                  value: aula.classcode,
                                  child: Text(
                                    "Grupo: ${aula.group}  Planta: ${aula.floor.isEmpty ? 'N/A' : aula.floor}  Ala: ${aula.wing.isEmpty ? 'N/A' : aula.wing}  Código: ${aula.classcode}",
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Card for Turno selection
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleccionar turno:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedTurno,
                      decoration: const InputDecoration(
                        hintText: "Seleccionar turno",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items:
                          ["Diurno", "Verspertino", "Nocturno"]
                              .map(
                                (turno) => DropdownMenuItem(
                                  value: turno,
                                  child: Text(turno),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTurno = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Card for checkboxes to select period slots
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    // Display checkboxes 1 to 7 in a grid-like layout
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: List.generate(7, (index) {
                        int checkboxNumber = index + 1;
                        return SizedBox(
                          width: 50,
                          child: CheckboxListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              checkboxNumber.toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14),
                            ),
                            value: checkboxes[checkboxNumber],
                            onChanged: (bool? value) {
                              setState(() {
                                checkboxes[checkboxNumber] = value!;
                                selectAllCheckboxes = checkboxes.values.every(
                                  (e) => e,
                                );
                              });
                            },
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Card for Comentario input
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Comentario:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: comentarioController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        labelText: 'Comentarios (tarea, detalles, etc.)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: insertAusencia,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Guardar Ausencia',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}