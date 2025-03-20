// ignore_for_file: avoid_print

import 'package:codigo/Objetos/guardia_object.dart';
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
  List<String> guardiasRealizadas = [];
  List<GuardiaObject> guardiasUnasigned = [];
  List<GuardiaObject> selectedGuardias = [];

  // Function to print the ids of selected guardias when the "delete" button is pressed
  void eliminarGuardia() async {
    if (selectedGuardias.isNotEmpty) {
      // Loop through all selected guardias and delete them
      for (var guardia in selectedGuardias) {
        print('Selected Guardia id: ${guardia.id}');

        // Call the delete method from SupabaseManager to delete the guardia
        bool result = await SupabaseManager.instance.deleteGuardiaById(
          guardia.id,
        );
        if (result) {
          print('Guardia ${guardia.id} deleted successfully');
        } else {
          print('Failed to delete Guardia ${guardia.id}');
        }
      }

      // Ensure `guardiasUnasigned` is not null before updating
      setState(() {
        // Safely remove the deleted guardias from the unasigned list
        if (guardiasUnasigned != null) {
          guardiasUnasigned.removeWhere(
            (guardia) => selectedGuardias.contains(guardia),
          );
        }

        // Clear the selected guardias list after deletion
        selectedGuardias.clear();
      });
    } else {
      print('No guardias selected for deletion.');
    }
  }

  // Fetch the unasigned guardias for the current user
  Future<void> fetchAllUserUnasignedGuardias() async {
    try {
      // Call the function from SupabaseManager that returns a List<GuardiaObject>
      final unasigned = await SupabaseManager.instance
          .getAllUnasignedUserGuardias(MyApp.loggedInUser!.id);

      print(unasigned); // Debug print to check the fetched data
      setState(() {
        guardiasUnasigned = unasigned;
      });
    } catch (e) {
      print("Error fetching unasigned guardias: $e");
    }
  }

  // Fetch all guardias (both completed and pending)
  Future<void> fetchAllGuardias() async {
    try {
      final response = await SupabaseManager.instance.getAllGuardiasByUserId(
        widget.userId,
      );

      final completedGuardias = await SupabaseManager.instance
          .getAllGuardiasDoneByUser(widget.userId);

      setState(() {
        guardiasRealizadas.clear();
      });

      Set<String> addedGuardias = {};

      // Process the response and add completed guardias to the 'guardiasRealizadas' list
      for (var guardia in response) {
        String guardiaInfo = 'Guardia ${guardia.id} - ${guardia.observations}';
        if (guardia.substituteTeacherId == widget.userId) {
          if (!addedGuardias.contains(guardiaInfo)) {
            guardiasRealizadas.add(guardiaInfo);
            addedGuardias.add(guardiaInfo);
          }
        }
      }

      // Add the completed guardias from the getAllGuardiasDoneByUser function to the list
      for (var completedGuardia in completedGuardias) {
        String completedGuardiaInfo =
            'Guardia ${completedGuardia.id} - ${completedGuardia.observations}';
        if (!addedGuardias.contains(completedGuardiaInfo)) {
          guardiasRealizadas.add(completedGuardiaInfo);
          addedGuardias.add(completedGuardiaInfo);
        }
      }
    } catch (e) {
      print("Error fetching guardias: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllGuardias();
    fetchAllUserUnasignedGuardias();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Guardias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section for completed guardias
            const Text(
              'Guardias Realizadas',
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
                    return ListTile(
                      title: Text(guardiasRealizadas[index]),
                      leading: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Section for unasigned guardias (pending)
            const Text(
              'Guardias Pendientes',
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
                        'Guardia ${guardia.id} - ${guardia.observations}';
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
                          if (isSelected) {
                            selectedGuardias.remove(guardia);
                          } else {
                            selectedGuardias.add(guardia);
                          }
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
                  onPressed: eliminarGuardia,
                  child: const Text('Eliminar Guardia Seleccionadas'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Volver'),
                ),
              ],
            ),
            // Added test button to print retrieved guardias
          ],
        ),
      ),
    );
  }
}