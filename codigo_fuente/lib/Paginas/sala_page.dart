import 'package:codigo/Objetos/guardia_object.dart';
import 'package:codigo/global_settings.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';

class SalaProfesoresPage extends StatefulWidget {
  const SalaProfesoresPage({super.key});

  @override
  State<SalaProfesoresPage> createState() => _SalaProfesoresPageState();
}

class _SalaProfesoresPageState extends State<SalaProfesoresPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<GuardiaObject> guardiasFromToday = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    getGuardiasFromToday();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getGuardiasFromToday() async {
    try {
      final response = await SupabaseManager.instance.getTodayGuardias();
      print('TODAY GUARDIAS ---- $response');
      setState(() {
        guardiasFromToday = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pendiente':
        return Icons.error_outline; // Exclamation mark
      case 'Asignada':
        return Icons.check_circle; // Checkmark
      default:
        return Icons.info_outline; // Fallback info icon
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.orange;
      case 'Asignada':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.translate('viewGuardias'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator()) // Loading
                : hasError
                ? const Center(
                  child: Text("Error loading data. Please try again."),
                )
                : guardiasFromToday.isEmpty
                ? const Center(child: Text("No guardias found for today."))
                : ListView.builder(
                  itemCount: guardiasFromToday.length,
                  itemBuilder: (context, index) {
                    final guardia = guardiasFromToday[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          "${Translations.translate('guardia')}: ${guardia.id}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${Translations.translate('date')}: ${guardia.day.day}/${guardia.day.month}/${guardia.day.year} - ${Translations.translate('tram')}: ${guardia.tramoHorario != null ? (guardia.tramoHorario! >= 1 && guardia.tramoHorario! <= 7 ? 'diurno' : (guardia.tramoHorario! >= 8 && guardia.tramoHorario! <= 15 ? 'vespertino' : (guardia.tramoHorario! >= 16 && guardia.tramoHorario! <= 22 ? 'nocturno' : 'n/a'))) : 'n/a'}",
                            ),
                            Text(
                              "${Translations.translate('status')}: ${guardia.status}",
                              style: TextStyle(
                                color: getStatusColor(guardia.status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        leading: Icon(
                          getStatusIcon(guardia.status),
                          color: getStatusColor(guardia.status),
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
