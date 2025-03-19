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
                            backgroundColor: Colors.blue,
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
                  }).toList(),
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
                            },
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            icon: Icons.check_circle,
                            label: 'Finalizar',
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text("Guardia ${guardia.id}"),
                        subtitle: Text("Tramo: ${guardia.tramoHorario}"),
                      ),
                    );
                  }).toList(),
                ],
              ),
        ],
      ),
    );
  }
}
