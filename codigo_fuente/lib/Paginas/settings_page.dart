import 'package:codigo/main.dart';
import 'package:flutter/material.dart';
import 'package:codigo/Paginas/change_password_page.dart';
import 'package:codigo/theme_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificaciones = true;
  String idioma = "Español";
  bool temaOscuro = false;

  // Simple translations map for demonstration.
  final Map<String, Map<String, String>> translations = {
    'Español': {
      'title': 'Ajustes',
      'personalization': 'Personalización',
      'darkMode': 'Modo oscuro',
      'darkModeSubtitle': 'Cambia entre el tema claro y oscuro',
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
      'darkModeSubtitle': 'Switch between light and dark themes',
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
      'darkModeSubtitle': 'Changer entre les thèmes clair et sombre',
      'language': 'Langue',
      'languageSubtitle': 'Sélectionnez la langue de l\'application',
      'notifications': 'Recevoir des notifications',
      'notificationsSubtitle': 'Activer ou désactiver les notifications',
      'changePassword': 'Changer le mot de passe',
    },
  };

  // Shortcut getter for current translations.
  Map<String, String> get t => translations[idioma]!;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load the stored theme preference
  void _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool savedTheme = prefs.getBool('temaOscuro') ?? false;
    setState(() {
      temaOscuro = savedTheme;
    });
  }

  // Save the theme preference
  void _saveThemePreference(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('temaOscuro', value);
  }

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

  // Toggle the theme for the entire app by rebuilding with the new theme.
  void toggleTheme(bool value) {
    setState(() {
      temaOscuro = value;
    });
    _saveThemePreference(temaOscuro); // Save the theme preference when toggled.

    // Rebuild the app with the new theme using AppEasyTheme.
    runApp(
      AppEasyTheme().buildAppWithTheme(
        isDarkMode: temaOscuro,
        title: "Test", // You can change this title as needed.
        onThemeToggle: () {}, // Passing this function again.
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t['title']!),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            t['personalization']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          // Dark Mode Toggle (changes the global theme)
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: t['darkMode']!,
            subtitle: t['darkModeSubtitle']!,
            trailing: Switch(value: temaOscuro, onChanged: toggleTheme),
          ),
          // Language selection (local state only)
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
                        (String value) =>
                            DropdownMenuItem(value: value, child: Text(value)),
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
          // Notifications toggle (local)
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
    );
  }

  // Helper widget to build each setting tile.
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
