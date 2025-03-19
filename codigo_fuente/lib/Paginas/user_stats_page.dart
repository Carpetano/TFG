import 'package:flutter/material.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/supabase_manager.dart';

class UserStatsPage extends StatefulWidget {
  final UserObject user;

  const UserStatsPage({super.key, required this.user});

  @override
  _UserStatsPageState createState() => _UserStatsPageState();
}

class _UserStatsPageState extends State<UserStatsPage> {
  List guardiasAsignadas = [];
  List guardiasNoAsignadas = [];

  @override
  void initState() {
    super.initState();
    _fetchGuardias();
  }

  Future<void> _fetchGuardias() async {
    List asignadas =
        await SupabaseManager.instance.getAllGuardiasByUserId(widget.user.id);
    List realizadas =
        await SupabaseManager.instance.getAllGuardiasDoneByUser(widget.user.id);

    setState(() {
      guardiasAsignadas = asignadas;
      guardiasNoAsignadas = asignadas.where((g) => g.status == 'Pendiente').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Estadísticas de ${widget.user.firstName}")),
      body: Column(
        children: [
          ListTile(title: Text("Guardias Asignadas: ${guardiasAsignadas.length}")),
          ListTile(title: Text("Guardias No Asignadas: ${guardiasNoAsignadas.length}")),
        ],
      ),
    );
  }
}