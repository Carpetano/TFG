import 'package:codigo/global_settings.dart';
import 'package:codigo/main.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:codigo/Objetos/guardia_object.dart';

/// Page to visualize guardias given a specific date
class ViewGuardiasPage extends StatefulWidget {
  // Date to check fetch data from
  final DateTime day;
  // Page constructor
  const ViewGuardiasPage({super.key, required this.day});

  @override
  State<ViewGuardiasPage> createState() => _ViewGuardiasPageState();
}

class _ViewGuardiasPageState extends State<ViewGuardiasPage>
    with SingleTickerProviderStateMixin {
  // Animation controller to show only when it's loading
  late AnimationController _controller;

  // Null list of guardias to display
  late List<GuardiaObject> guardiasToDisplay;

  // List of pending and asigned guardias to populate later on
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
    // Get the list of guardias from supabase manager
    final response = await SupabaseManager.instance.getAllGuardiasByDay(
      widget.day,
    );

    // Assign states
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

  /// Assign the current user as substitute teacher for the parsed in guardia's id
  ///
  /// - [guardiaId] Guardia to assign the substitute teacher
  Future<void> claimGuardia(int guardiaId) async {
    // Assign the substitute teacher
    await SupabaseManager.instance.assignGuardiaToUser(
      guardiaId,
      MyApp.loggedInUser!.id,
    );
    // Refresh guardias list
    await fetchGuardiasObjects();
  }

  /// Show an information dialog given a guardia id
  ///
  /// - [guardiaId] Guardia to assign the substitute teacher
  /// - [context] current context
  Future<void> showGuardiaInfo(int guardiaId, BuildContext context) async {
    try {
      // Get a guardia object with matching guardia id
      GuardiaObject? guardia = await SupabaseManager.instance.getGuardiaById(
        guardiaId,
      );

      // Check for null values and if the widget is still mounted
      if (guardia == null) {
        if (context.mounted) {
          _showAlertDialog(context, 'No data found for Guardia ID $guardiaId');
        }
        return;
      }

      // Text to display
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

  /// Show an alart dialog given a message
  ///
  /// - [context] Current context
  /// - [message] Text to display
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

  /// Builds a section with a title and a list of Slidable ListTiles
  ///
  /// - [sectionTitle] Title of the section
  /// - [guardias] List of guardias to display
  /// - [actionColor] Color of the action
  /// - [actionIcon] Action Action Icon
  /// - [actionLabel] Label Action text
  /// - [onActionTap] Function to perform when tapping
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
                      foregroundColor: Colors.white,
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
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(formattedDate, style: const TextStyle(fontSize: 16)),
          ],
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
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
                ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      "No hay guardias asignadas",
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
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
