import 'package:flutter/material.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/supabase_manager.dart';

/// Page to display data given an user id
class UserStatsPage extends StatefulWidget {
  // User to retreive data from
  final UserObject user;

  const UserStatsPage({super.key, required this.user});

  @override
  _UserStatsPageState createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage> {
  // List of the number of guardias done
  List guardiasAsignadas = [];

  // List of unasigned guardias
  List guardiasNoAsignadas = [];

  // Store whether if supabase hasn't retreived information
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchGuardias();
  }

  /// Fetch and update local lists with guardias
  Future<void> _fetchGuardias() async {
    try {
      // Get all of the assigned guardias for the current user
      List asignadas = await SupabaseManager.instance.getAllGuardiasByUserId(
        widget.user.id,
      );

      // Get all of the done guardias by the current user
      List realizadas = await SupabaseManager.instance.getAllGuardiasDoneByUser(
        widget.user.id,
      );

      // Update local lists
      setState(() {
        guardiasAsignadas = asignadas;
        guardiasNoAsignadas =
            asignadas.where((g) => g.status == 'Pendiente').toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Estadísticas de ${widget.user.firstName}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, Colors.yellow],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : hasError
              ? const Center(child: Text("Error al cargar las estadísticas."))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Card for Guardias Asignadas
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.assignment_turned_in,
                          color: Colors.green,
                        ),
                        title: const Text("Guardias Asignadas"),
                        trailing: Text(
                          "${guardiasAsignadas.length}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Card for Guardias No Asignadas
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.error_outline,
                          color: Colors.orange,
                        ),
                        title: const Text("Guardias No Asignadas"),
                        trailing: Text(
                          "${guardiasNoAsignadas.length}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
