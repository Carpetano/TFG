import 'package:codigo/add_ausencia_page.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:codigo/ausencia_object.dart'; // Your model for 'ausencias'
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Import the slidable package

class ProfesorMainMenuPage extends StatefulWidget {
  const ProfesorMainMenuPage({super.key});

  @override
  State<ProfesorMainMenuPage> createState() => _ProfesorMainMenuPageState();
}

class _ProfesorMainMenuPageState extends State<ProfesorMainMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<AusenciaObject> ausencias = []; // List to store fetched 'ausencias'

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    fetchAusencias(); // Fetch the ausencias when the page is initialized
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Fetch the ausencias from the database
  Future<void> fetchAusencias() async {
    try {
      // Fetch the list of unassigned ausencias (pendiente)
      List<AusenciaObject> fetchedAusencias =
          await SupabaseManager.instance.getAllUnasignedAusencias();
      setState(() {
        ausencias = fetchedAusencias; // Set the fetched ausencias to the state
      });
    } catch (e) {
      print("Error fetching ausencias: $e");
    }
  }

  void gotoAddAusencia() {
    print("Navigating to Adding ausencia page");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAusenciaPage()),
    );
  }

  // Function to delete an ausencia
  void deleteAusencia(AusenciaObject ausencia) async {
    print("Deleting $ausencia");
    // Add your delete functionality here
  }

  // Function to show info of an ausencia
  void showInfo(AusenciaObject ausencia) {
    print("Showing info for ausencia with id: ${ausencia.id}");
    // You can navigate to a new screen here to show details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menú profesor")),
      body: Column(
        children: [
          // Display a loading indicator while fetching data
          if (ausencias.isEmpty) Center(child: CircularProgressIndicator()),

          // If there are ausencias, display them in a slidable list
          if (ausencias.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: ausencias.length,
                itemBuilder: (context, index) {
                  final ausencia = ausencias[index];

                  return Slidable(
                    // Action when swiped from the start (left)
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            // Show info about the ausencia
                            showInfo(ausencia);
                          },
                          backgroundColor: Colors.blue,
                          icon: Icons.info,
                          label: 'Info',
                        ),
                      ],
                    ),
                    // Action when swiped from the end (right)
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            // Delete the ausencia
                            deleteAusencia(ausencia);
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Eliminar',
                        ),
                      ],
                    ),
                    // Child is a simple Row with Text
                    child: ListTile(
                      title: Text("Ausencia: ${ausencia.missingTeacherId}"),
                      subtitle: Text("Aula: ${ausencia.classCode}"),
                      onTap: () {
                        // You can navigate to a new screen to show details or edit
                      },
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 10),
          // The button to "Add new Ausencia"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: gotoAddAusencia, // Trigger the same navigation
              child: Text("Añadir Nueva Ausencia"),
            ),
          ),
        ],
      ),
    );
  }
}
