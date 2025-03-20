// ignore_for_file: avoid_print

import 'package:codigo/Objetos/guardia_object.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/global_settings.dart';
import 'package:codigo/main.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';

class VerMisGuardiasPage extends StatefulWidget {
  final int userId = MyApp.loggedInUser!.id;
  VerMisGuardiasPage({super.key});

  @override
  State<VerMisGuardiasPage> createState() => _VerMisGuardiasPageState();
}

class _VerMisGuardiasPageState extends State<VerMisGuardiasPage> {
  List<GuardiaObject> guardiasRealizadas = [];
  List<GuardiaObject> guardiasUnasigned = [];
  List<GuardiaObject> selectedGuardias = [];

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

  // Fetch unassigned guardias
  Future<void> getAllUnasignedUserGuardias(int userId) async {
    final response = await SupabaseManager.instance.getAllUnasignedUserGuardias(
      userId,
    );
    setState(() {
      guardiasUnasigned = response;
    });
  }

  // Fetch guardias done by user
  Future<void> getAllGuardiasDoneByUser(int userId) async {
    final response = await SupabaseManager.instance.getAllGuardiasDoneByUser(
      userId,
    );
    setState(() {
      guardiasRealizadas = response;
    });
  }

  // Fetch user object by ID to get the teacher's first name
  Future<UserObject> getUserObjectById(int userId) async {
    try {
      final user = await SupabaseManager.instance.getUserObjectById(userId);
      print("Fetched user: $user");
      return user;
    } catch (e) {
      print("Error fetching user: $e");
      rethrow;
    }
  }

  // Delete an unassigned guardia by its ID
  Future<void> deleteUnasignedGuardia(int id) async {
    try {
      await SupabaseManager.instance.deleteGuardiaById(id);
      print("Deleted guardia with ID: $id");
    } catch (e) {
      print("Error deleting guardia: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getAllGuardiasDoneByUser(widget.userId);
    getAllUnasignedUserGuardias(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient AppBar for a modern header
      appBar: AppBar(
        title: Text(
          Translations.translate('mySupervisions'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section Title for Guardias Realizadas
            Text(
              Translations.translate('guardiasDone'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Card for Guardias Realizadas List
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: guardiasRealizadas.length,
                    itemBuilder: (context, index) {
                      final guardia = guardiasRealizadas[index];
                      String formattedDate =
                          '${guardia.day.day}/${guardia.day.month}/${guardia.day.year}';
                      return FutureBuilder<UserObject>(
                        future: getUserObjectById(guardia.missingTeacherId!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ListTile(
                              title: Text(formattedDate),
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            );
                          }
                          if (snapshot.hasData) {
                            // In a full implementation you might show the teacher's name
                            return ListTile(
                              title: Text(formattedDate),
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return ListTile(
                              title: Text('$formattedDate - Profesor: N/A'),
                              leading: const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                            );
                          }
                          return ListTile(
                            title: Text('$formattedDate - Profesor: N/A'),
                            leading: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Section Title for Guardias Pendientes
            Text(
              Translations.translate('pendingGuardias'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Card for Guardias Unasigned List
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orangeAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListView.builder(
                    itemCount: guardiasUnasigned.length,
                    itemBuilder: (context, index) {
                      final guardia = guardiasUnasigned[index];
                      String guardiaInfo =
                          '${guardia.day.day}/${guardia.day.month}/${guardia.day.year} - Tramo: ${guardia.tramoHorario}';
                      bool isSelected = selectedGuardias.contains(guardia);
                      return ListTile(
                        title: Text(guardiaInfo),
                        leading: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected ? Colors.blue : null,
                        ),
                        onTap: () {
                          setState(() {
                            isSelected
                                ? selectedGuardias.remove(guardia)
                                : selectedGuardias.add(guardia);
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    for (var guardia in selectedGuardias) {
                      await deleteUnasignedGuardia(guardia.id);
                      setState(() {
                        guardiasUnasigned.remove(guardia);
                      });
                    }
                    setState(() {
                      selectedGuardias.clear();
                    });
                    showSnackBar(
                      "Guardias Borradas",
                      Colors.white,
                      Colors.black,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(Translations.translate('deleteGuardia')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(Translations.translate('goback')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
