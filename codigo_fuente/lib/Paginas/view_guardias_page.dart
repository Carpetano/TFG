import 'package:codigo/global_settings.dart';
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
    await SupabaseManager.instance.assignGuardiaToUser(
      guardiaId,
      MyApp.loggedInUser!.id,
    );
    // Optionally, refresh the list after claiming
    await fetchGuardiasObjects();
  }

  Future<void> showGuardiaInfo(int guardiaId, BuildContext context) async {
    try {
      GuardiaObject? guardia = await SupabaseManager.instance.getGuardiaById(
        guardiaId,
      );

      if (guardia == null) {
        if (context.mounted) {
          _showAlertDialog(context, 'No data found for Guardia ID $guardiaId');
        }
        return;
      }

      String infoText = '''
ID: ${guardia.id}
Profesor ausente ID: ${guardia.missingTeacherId ?? 'N/A'}
Profesor sustituto ID: ${guardia.substituteTeacherId ?? 'N/A'}
Observaciones: ${guardia.observations}
Estado: ${guardia.status}
Dia: ${guardia.day.toLocal()}
      ''';

      if (context.mounted) {
        _showAlertDialog(context, infoText);
      }
    } catch (e) {
      if (context.mounted) {
        _showAlertDialog(context, 'Error fetching Guardia info');
      }
    }
  }

  // Helper to show an AlertDialog
  void _showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Información sobre la guardia',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
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

  // Builds a section with a title and a list of Slidable ListTiles
  Widget buildGuardiaSection({
    required String sectionTitle,
    required List<GuardiaObject> guardias,
    required Color actionColor,
    required IconData actionIcon,
    required String actionLabel,
    required Function(GuardiaObject, BuildContext) onActionTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                sectionTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ...guardias.map((guardia) {
              return Slidable(
                key: Key(guardia.id.toString()),
                startActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        onActionTap(guardia, context);
                      },
                      backgroundColor: actionColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      icon: actionIcon,
                      label: actionLabel,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  title: Text(
                    "Id Profesor ausente: ${guardia.missingTeacherId}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text("Tramo: ${guardia.tramoHorario}"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onPrimary),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        "${widget.day.day}/${widget.day.month}/${widget.day.year}";
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              Translations.translate('supervisions'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
            ),
            Text(formattedDate, style: const TextStyle(fontSize: 16)),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).colorScheme.primary, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: fetchGuardiasObjects,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // Pendientes Section
            pendienteGuardias.isEmpty
                ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      Translations.translate('noPendingGuardias'),
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ),
                )
                : buildGuardiaSection(
                  sectionTitle: "Pendientes",
                  guardias: pendienteGuardias,
                  actionColor: Colors.green,
                  actionIcon: Icons.check,
                  actionLabel: 'Asignar',
                  onActionTap: (guardia, ctx) {
                    claimGuardia(guardia.id);
                    showSnackBar(
                      "Asignada correctamente",
                      Colors.white,
                      Colors.black,
                    );
                  },
                ),
            // Asignadas Section
            asignadaGuardias.isEmpty
                ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "No hay guardias asignadas",
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                )
                : buildGuardiaSection(
                  sectionTitle: "Asignadas",
                  guardias: asignadaGuardias,
                  actionColor: Colors.blue,
                  actionIcon: Icons.info,
                  actionLabel: 'Información',
                  onActionTap: (guardia, ctx) {
                    showGuardiaInfo(guardia.id, ctx);
                  },
                ),
          ],
        ),
      ),
    );
  }
}