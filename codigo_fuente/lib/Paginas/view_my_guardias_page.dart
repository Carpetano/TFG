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
  List<String> guardiasUnasigned = [];
  String? guardiaSeleccionada;

  void eliminarGuardia() {
    if (guardiaSeleccionada != null) {
      setState(() {
        guardiasUnasigned.remove(guardiaSeleccionada);
        guardiaSeleccionada = null;
      });
    }
  }

  Future<void> fetchAllGuardias() async {
    try {
      // Fetch all guardias for the user by their id
      final response = await SupabaseManager.instance.getAllGuardiasByUserId(
        widget.userId,
      );

      // Fetch all completed guardias (Asignada) from the function getAllGuardiasDoneByUser
      final completedGuardias = await SupabaseManager.instance
          .getAllGuardiasDoneByUser(widget.userId);

      // Clear existing lists before populating them again
      setState(() {
        guardiasRealizadas.clear();
        guardiasUnasigned.clear();
      });

      // Set to hold unique guardias to avoid duplicates
      Set<String> addedGuardias = {};

      // Process the response and add completed guardias to the 'guardiasRealizadas' list
      for (var guardia in response) {
        String guardiaInfo = 'Guardia ${guardia.id} - ${guardia.observations}';

        if (guardia.substituteTeacherId == widget.userId) {
          // Add completed guardias to guardiasRealizadas if not already added
          if (!addedGuardias.contains(guardiaInfo)) {
            guardiasRealizadas.add(guardiaInfo);
            addedGuardias.add(guardiaInfo); // Mark this guardia as added
          }
        } else {
          // Add unassigned guardias to guardiasUnasigned if not already added
          if (!addedGuardias.contains(guardiaInfo)) {
            guardiasUnasigned.add(guardiaInfo);
            addedGuardias.add(guardiaInfo); // Mark this guardia as added
          }
        }
      }

      // Add the completed guardias from the getAllGuardiasDoneByUser function to the list
      for (var completedGuardia in completedGuardias) {
        String completedGuardiaInfo =
            'Guardia ${completedGuardia.id} - ${completedGuardia.observations}';
        // Add to guardiasRealizadas only if not already added
        if (!addedGuardias.contains(completedGuardiaInfo)) {
          guardiasRealizadas.add(completedGuardiaInfo);
          addedGuardias.add(completedGuardiaInfo); // Mark this guardia as added
        }
      }
    } catch (e) {
      print("Error fetching guardias: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAllGuardias(); // Fetch the data when the page is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Guardias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                    return ListTile(
                      title: Text(guardiasUnasigned[index]),
                      leading: Icon(
                        guardiaSeleccionada == guardiasUnasigned[index]
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color:
                            guardiaSeleccionada == guardiasUnasigned[index]
                                ? Colors.blue
                                : null,
                      ),
                      onTap: () {
                        setState(() {
                          // If the same guardia is tapped, toggle the selection
                          if (guardiaSeleccionada == guardiasUnasigned[index]) {
                            guardiaSeleccionada = null;
                          } else {
                            guardiaSeleccionada = guardiasUnasigned[index];
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
                  child: const Text(
                    'Eliminar Guardia Seleccionada (pa que no?)',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  child: const Text('Volver'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
