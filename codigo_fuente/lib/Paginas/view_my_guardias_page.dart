// ignore_for_file: avoid_print

// Translated
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
      print("Fetched user: $user"); // Debugging statement
      return user;
    } catch (e) {
      print("Error fetching user: $e"); // Error if fetching fails
      rethrow; // Propagate error if necessary
    }
  }

  // Delete an unassigned guardia by its ID
  Future<void> deleteUnasignedGuardia(int id) async {
    try {
      await SupabaseManager.instance.deleteGuardiaById(id);
      print("Deleted guardia with ID: $id"); // Debugging statement
    } catch (e) {
      print("Error deleting guardia: $e"); // Error if deleting fails
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch the data for both done and unassigned guardias
    getAllGuardiasDoneByUser(widget.userId);
    getAllUnasignedUserGuardias(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Guardias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              Translations.translate('guardiasDone'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent),
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
                          // Handle null value
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
            const SizedBox(height: 20),
            Text(
              Translations.translate('pendingGuardias'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orangeAccent),
                ),
                child: ListView.builder(
                  itemCount: guardiasUnasigned.length,
                  itemBuilder: (context, index) {
                    final guardia = guardiasUnasigned[index];
                    String guardiaInfo =
                        '${guardia.day.day}/${guardia.day.month}/${guardia.day.year} - Tramo horario: ${guardia.tramoHorario}';
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    for (var guardia in selectedGuardias) {
                      await deleteUnasignedGuardia(guardia.id);
                      // After deleting, remove from the list
                      setState(() {
                        guardiasUnasigned.remove(guardia);
                      });
                    }
                    setState(() {
                      // Clear the selected guardias list after deletion
                      selectedGuardias.clear();
                    });
                  },
                  child: Text(Translations.translate('deleteGuardia')),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
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
