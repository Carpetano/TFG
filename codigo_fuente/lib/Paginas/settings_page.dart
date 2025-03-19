import 'package:flutter/material.dart';
import 'package:codigo/Paginas/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  final Function(Locale)?
  onLanguageChanged; // Optional, if you want language switching
  const SettingsPage({Key? key, this.onLanguageChanged}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificaciones = true;
  String idioma = "Español";
  bool temaOscuro = false;

  // Simple translations map for demonstration purposes.
  final Map<String, Map<String, String>> translations = {
    'Español': {
      'title': 'Ajustes',
      'personalization': 'Personalización',
      'darkMode': 'Modo oscuro',
      'darkModeSubtitle':
          'Cambia entre el tema claro y oscuro (solo en esta página)',
      'language': 'Idioma',
      'languageSubtitle': 'Selecciona el idioma de la aplicación',
      'notifications': 'Recibir notificaciones',
      'notificationsSubtitle': 'Activa o desactiva las notificaciones',
      'changePassword': 'Cambiar Contraseña',
    },
    'Inglés': {
      'title': 'Settings',
      'personalization': 'Personalization',
      'darkMode': 'Dark Mode',
      'darkModeSubtitle':
          'Switch between light and dark themes (this page only)',
      'language': 'Language',
      'languageSubtitle': 'Select the app language',
      'notifications': 'Receive Notifications',
      'notificationsSubtitle': 'Toggle notifications on or off',
      'changePassword': 'Change Password',
    },
    'Francés': {
      'title': 'Paramètres',
      'personalization': 'Personnalisation',
      'darkMode': 'Mode sombre',
      'darkModeSubtitle':
          'Changer entre les thèmes clair et sombre (cette page uniquement)',
      'language': 'Langue',
      'languageSubtitle': 'Sélectionnez la langue de l\'application',
      'notifications': 'Recevoir des notifications',
      'notificationsSubtitle': 'Activer ou désactiver les notifications',
      'changePassword': 'Changer le mot de passe',
    },
  };

  // Shortcut to get current translations.
  Map<String, String> get t => translations[idioma]!;

  // Navigate to change password page.
  void goToChangePassword() async {
    bool? passwordChanged = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
    if (passwordChanged == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${t['changePassword']} cambiada con éxito. Regresando a ajustes...",
          ),
        ),
      );
    }
  }

  // Build a light theme for this page.
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  // Build a dark theme for this page.
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Colors.blueAccent,
      scaffoldBackgroundColor: Colors.grey[900],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a local theme based on the toggle.
    ThemeData localTheme = temaOscuro ? _buildDarkTheme() : _buildLightTheme();

    // Wrap only the SettingsPage with a local Theme widget.
    return Theme(
      data: localTheme,
      child: Scaffold(
        appBar: AppBar(title: Text(t['title']!)),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              t['personalization']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Dark Mode toggle (local to this page)
            _buildSettingTile(
              icon: Icons.dark_mode,
              title: t['darkMode']!,
              subtitle: t['darkModeSubtitle']!,
              trailing: Switch(
                value: temaOscuro,
                onChanged: (value) => setState(() => temaOscuro = value),
              ),
            ),

            // Language selection
            _buildSettingTile(
              icon: Icons.language,
              title: t['language']!,
              subtitle: t['languageSubtitle']!,
              trailing: DropdownButton<String>(
                value: idioma,
                onChanged: (newValue) {
                  setState(() {
                    idioma = newValue!;
                  });
                },
                items:
                    <String>['Español', 'Inglés', 'Francés']
                        .map(
                          (String value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              t['notifications']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Notifications toggle
            _buildSettingTile(
              icon: Icons.notifications_active,
              title: t['notifications']!,
              subtitle: t['notificationsSubtitle']!,
              trailing: Switch(
                value: notificaciones,
                onChanged: (value) => setState(() => notificaciones = value),
              ),
            ),

            const SizedBox(height: 20),
            // Change Password Button
            ElevatedButton(
              onPressed: goToChangePassword,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(t['changePassword']!),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build setting tiles.
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
