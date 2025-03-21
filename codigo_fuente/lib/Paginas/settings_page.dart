import 'package:codigo/main.dart';
import 'package:flutter/material.dart';
import 'package:codigo/Paginas/change_password_page.dart';
import 'package:codigo/global_settings.dart';
import 'dart:io';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificaciones = true;
  AppLanguage idioma =
      GlobalSettings.language.value; // Use AppLanguage enum for language
  bool temaOscuro =
      GlobalSettings.isDarkMode.value; // Use global dark mode setting

  @override
  void initState() {
    super.initState();

    // Listen for language and theme changes
    GlobalSettings.language.addListener(() {
      if (mounted) {
        setState(() {
          idioma = GlobalSettings.language.value;
        });
      }
    });

    GlobalSettings.isDarkMode.addListener(() {
      if (mounted) {
        setState(() {
          temaOscuro = GlobalSettings.isDarkMode.value;
        });
      }
    });
  }

  /// Save language preference and update the file.
  static Future<void> writeToLangConfigFile(String txt) async {
    final file = File('default_lang.txt');
    try {
      await file.writeAsString(
        txt,
        mode: FileMode.write,
      ); // Overwrites existing content
      print("[INFO] Written: '$txt' in default_lang.txt.");
    } catch (e) {
      print("[ERROR] Failed to update default_lang.txt: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    final maxPhoneWidth = 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
              iconSize: 24,
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);  // Regresar a la pantalla anterior
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage(title: "Guardias Calderón", onThemeToggle: () {})),
                    (route) => false, // Elimina todas las rutas anteriores
                  );
                }
              },
            ),
        title: Text(
          Translations.translate('pageTitle'),
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body:
          screenWidth > maxPhoneWidth
              ? buildDesktopLayout(screenWidth, screenHeight)
              : buildMobileLayout(screenWidth),
    );
  }

  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    return Center(
      child: Container(
        width: screenWidth > 600 ? screenWidth * 0.6 : screenWidth * 1,
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              Translations.translate(
                'personalization', // Get language code dynamically
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingTile(
              icon: Icons.dark_mode,
              title: Translations.translate(
                'darkMode',
                // Get language code dynamically
              ),
              subtitle: Translations.translate(
                'darkModeSubtitle',
                // Get language code dynamically
              ),
              trailing: Switch(
                value: GlobalSettings.isDarkMode.value,
                onChanged: (value) async {
                  await GlobalSettings.setTheme(value);
                },
              )
            ),
            _buildSettingTile(
              icon: Icons.language,
              title: Translations.translate(
                'language',
                // Get language code dynamically
              ),
              subtitle: Translations.translate(
                'languageSubtitle',
                // Get language code dynamically
              ),
              trailing: DropdownButton<AppLanguage>(
                value: idioma,
                onChanged: (newValue) async {
                  setState(() {
                    idioma = newValue!;
                  });

                  // Change language and update in GlobalSettings
                  if (newValue == AppLanguage.espanol) {
                    await GlobalSettings.setLanguage(AppLanguage.espanol);
                    writeToLangConfigFile('es');
                  } else if (newValue == AppLanguage.english) {
                    await GlobalSettings.setLanguage(AppLanguage.english);
                    writeToLangConfigFile('en');
                  }

                  // Refresh the page to apply changes
                  setState(() {});

                  // Ensure that the context is still valid before showing the dialog
                  if (mounted) {
                    // Show an AlertDialog to prompt the user to re-login
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            Translations.translate('reloginRequired'),
                          ),
                          content: Text(
                            Translations.translate('reloginRequired2'),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                // Close the dialog
                                Navigator.of(context).pop();

                                // Navigate to the login screen (replace LoginScreen with your actual screen)
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyApp(),
                                  ),
                                );
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },

                items:
                    AppLanguage.values
                        .map(
                          (AppLanguage value) => DropdownMenuItem<AppLanguage>(
                            value: value,
                            child: Text(
                              value == AppLanguage.english
                                  ? 'English'
                                  : 'Español',
                            ), // Translate enum to display name
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              Translations.translate(
                'notifications',
                // Get language code dynamically
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildSettingTile(
              icon: Icons.notifications_active,
              title: Translations.translate(
                'notifications',
                // Get language code dynamically
              ),
              subtitle: Translations.translate(
                'notificationsSubtitle',
                // Get language code dynamically
              ),
              trailing: Switch(
                value: notificaciones,
                onChanged: (value) => setState(() => notificaciones = value),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(Translations.translate('changePassword')),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMobileLayout(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Translations.translate('personalization'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: Translations.translate('darkMode'),
            subtitle: Translations.translate('darkModeSubtitle'),
            trailing: Switch(
              value: temaOscuro,
              onChanged: (value) async {
                await GlobalSettings.setTheme(value);
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          _buildSettingTile(
            icon: Icons.language,
            title: Translations.translate('language'),
            subtitle: Translations.translate('languageSubtitle'),
            trailing: DropdownButton<AppLanguage>(
              value: idioma,
              onChanged: (newValue) async {
                setState(() {
                  idioma = newValue!;
                });

                // Change language and update in GlobalSettings
                if (newValue == AppLanguage.espanol) {
                  await GlobalSettings.setLanguage(AppLanguage.espanol);
                  writeToLangConfigFile('es');
                } else if (newValue == AppLanguage.english) {
                  await GlobalSettings.setLanguage(AppLanguage.english);
                  writeToLangConfigFile('en');
                }

                // Refresh the page to apply changes
                setState(() {});
              },
              items:
                  AppLanguage.values
                      .map(
                        (AppLanguage value) => DropdownMenuItem<AppLanguage>(
                          value: value,
                          child: Text(
                            value == AppLanguage.english ? 'Inglés' : 'Español',
                          ), // Translate enum to display name
                        ),
                      )
                      .toList(),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            Translations.translate('notifications'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildSettingTile(
            icon: Icons.notifications_active,
            title: Translations.translate('notifications'),
            subtitle: Translations.translate('notificationsSubtitle'),
            trailing: Switch(
              value: notificaciones,
              onChanged: (value) => setState(() => notificaciones = value),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(
              Translations.translate('changePassword'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary, 
                fontWeight: FontWeight.bold, 
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8), // Más contraste
            fontWeight: FontWeight.w500, // Un poco más grueso para mayor legibilidad
          ),
        ),
        trailing: trailing,
      ),
    );
  }
}