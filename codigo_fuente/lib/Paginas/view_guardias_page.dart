import 'package:codigo/main.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:codigo/Objetos/guardia_object.dart';

class ViewGuardiasPage extends StatefulWidget {
  final DateTime day;
  const ViewGuardiasPage({super.key, required this.day});

  @override
  State<ViewGuardiasPage> createState() => _ViewGuardiasPageState();
}

class _ViewGuardiasPageState extends State<ViewGuardiasPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<GuardiaObject> guardiasToDisplay;
  List<GuardiaObject> pendienteGuardias = [];
  List<GuardiaObject> asignadaGuardias = [];

  // Fetch guardias by day
  Future<void> fetchGuardiasObjects() async {
    final response = await SupabaseManager.instance.getAllGuardiasByDay(
      widget.day,
    );
    setState(() {
      guardiasToDisplay = response;
      // Separate into 'pendiente' and 'asignada' states
      pendienteGuardias =
          guardiasToDisplay
              .where((guardia) => guardia.status.toLowerCase() == 'pendiente')
              .toList();
      asignadaGuardias =
          guardiasToDisplay
              .where((guardia) => guardia.status.toLowerCase() == 'asignada')
              .toList();
    });
  }

  Future<void> claimGuardia(int guardiaId) async {
    SupabaseManager.instance.assignGuardiaToUser(
      guardiaId,
      MyApp.loggedInUser!.id,
    );
  }

  Future<void> showGuardiaInfo(int guardiaId, BuildContext context) async {
    try {
      // Fetch GuardiaObject by ID
      GuardiaObject? guardia = await SupabaseManager.instance.getGuardiaById(
        guardiaId,
      );

      print(guardia);

      if (guardia == null) {
        // Show a dialog if no data was found
        if (context.mounted) {
          _showAlertDialog(context, 'No data found for Guardia ID $guardiaId');
        }
        return;
      }

      // Prepare the text to display
      String infoText = '''
    Guardia ID: ${guardia.id}
    Missing Teacher ID: ${guardia.missingTeacherId ?? 'N/A'}
    Substitute Teacher ID: ${guardia.substituteTeacherId ?? 'N/A'}
    Observations: ${guardia.observations}
    Status: ${guardia.status}
    Day: ${guardia.day.toLocal()}
    ''';

      // Show the dialog with the fetched data
      if (context.mounted) {
        _showAlertDialog(context, infoText);
      }
    } catch (e) {
      print("Error getting Guardia info: $e");
      if (context.mounted) {
        _showAlertDialog(context, 'Error fetching Guardia info');
      }
    }
  }

  // Helper function to show the AlertDialog
  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información sobre la guardia'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    fetchGuardiasObjects();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Guardias"),
            Text(
              "${widget.day.day} / ${widget.day.month} / ${widget.day.year}",
            ),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(top: 20, bottom: 20),
        children: [
          // Display pendientes section
          pendienteGuardias.isEmpty
              ? const Center(child: Text("No hay guardias pendientes"))
              : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Pendientes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...pendienteGuardias.map((guardia) {
                    return Slidable(
                      key: Key(guardia.id.toString()),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              // Handle action for pendiente
                              print("Pendiente action for ${guardia.id}");
                              claimGuardia(guardia.id);
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check,
                            label: 'Asignar',
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text("Guardia ${guardia.id}"),
                        subtitle: Text("Tramo: ${guardia.tramoHorario}"),
                      ),
                    );
                  }),
                ],
              ),
          // Display asignadas section
          asignadaGuardias.isEmpty
              ? const Center(child: Text("No hay guardias asignadas"))
              : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Asignadas",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...asignadaGuardias.map((guardia) {
                    return Slidable(
                      key: Key(guardia.id.toString()),
                      startActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              // Handle action for asignada
                              print("Asignada action for ${guardia.id}");
                              showGuardiaInfo(guardia.id, context);
                            },
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            icon: Icons.info,
                            label: 'Información',
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text("Guardia ${guardia.id}"),
                        subtitle: Text("Tramo: ${guardia.tramoHorario}"),
                      ),
                    );
                  }),
                ],
              ),
        ],
      ),
    );
  }
}