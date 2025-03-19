import 'package:flutter/material.dart';
import 'package:codigo/Paginas/change_password_page.dart'; // Asegúrate de importar ChangePasswordPage

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificaciones = true;
  String idioma = "Español";
  bool temaOscuro = false;

  // Navegar a la página de cambio de contraseña
  void goToChangePassword() async {
    // Navegar a la página de cambio de contraseña y esperar el resultado
    bool? passwordChanged = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );

    // Si la contraseña se cambió correctamente, regresamos a la página de ajustes
    if (passwordChanged == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña cambiada con éxito. Regresando a ajustes...")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ajustes"),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Personalización",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Modo oscuro
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: "Modo oscuro",
            subtitle: "Cambia entre el tema claro y oscuro",
            trailing: Switch(
              value: temaOscuro,
              onChanged: (value) {
                setState(() {
                  temaOscuro = value;
                });
              },
            ),
          ),

          // Idioma
          _buildSettingTile(
            icon: Icons.language,
            title: "Idioma",
            subtitle: "Selecciona el idioma de la aplicación",
            trailing: DropdownButton<String>(
              value: idioma,
              onChanged: (newValue) {
                setState(() {
                  idioma = newValue!;
                });
              },
              items: <String>['Español', 'Inglés', 'Francés']
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 20),
          const Text(
            "Notificaciones",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // Notificaciones
          _buildSettingTile(
            icon: Icons.notifications_active,
            title: "Recibir notificaciones",
            subtitle: "Activa o desactiva las notificaciones",
            trailing: Switch(
              value: notificaciones,
              onChanged: (value) {
                setState(() {
                  notificaciones = value;
                });
              },
            ),
          ),

          const SizedBox(height: 20),
          
          // Botón para cambiar la contraseña
          ElevatedButton(
            onPressed: goToChangePassword,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Cambiar Contraseña"),
          ),
        ],
      ),
    );
  }

  // Widget para construir cada opción de ajuste con un diseño bonito
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: trailing,
      ),
    );
  }
}
