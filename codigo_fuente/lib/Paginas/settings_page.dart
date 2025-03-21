import 'package:codigo/main.dart';
import 'package:flutter/material.dart';
import 'package:codigo/Paginas/change_password_page.dart';
import 'package:codigo/global_settings.dart';
import 'dart:io';

/// Settings page
class SettingsPage extends StatefulWidget {
  // Page constructor
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificaciones = true;

  // Store the display language and whether if it should use light or dark mode
  AppLanguage language = GlobalSettings.language.value;
  bool darkMode = GlobalSettings.isDarkMode.value;

  @override
  void initState() {
    super.initState();

    // Listen for language changes
    GlobalSettings.language.addListener(() {
      if (mounted) {
        setState(() {
          language = GlobalSettings.language.value;
        });
      }
    });

    // Listen for theme changes
    GlobalSettings.isDarkMode.addListener(() {
      if (mounted) {
        setState(() {
          darkMode = GlobalSettings.isDarkMode.value;
        });
      }
    });
  }

  /// Save language preference and update the file
  ///
  /// - [txt] String to write to the file
  static Future<void> writeToLangConfigFile(String txt) async {
    // Which file to write to
    final file = File('default_lang.txt');
    try {
      // Write to the file the parsed in text as attribute in the function
      await file.writeAsString(txt, mode: FileMode.write);
      print("[INFO] Written: '$txt' in default_lang.txt.");
    } catch (e) {
      print("[ERROR] Failed to update default_lang.txt: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    // Define a limit to differenciate between a desktop and mobile screen to assign the neccessary layout
    final maxPhoneWidth = 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.translate('pageTitle'),
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          screenWidth > maxPhoneWidth
              ? buildDesktopLayout(screenWidth, screenHeight)
              : buildMobileLayout(screenWidth),
    );
  }

  /// Build desktop layout
  ///
  /// - [screenWidth] Current screen width
  /// - [screenHeight] Current screen height
  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    return Center(
      child: Container(
        width: screenWidth > 600 ? screenWidth * 0.6 : screenWidth * 1,
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
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
                value: darkMode,
                onChanged: (value) async {
                  await GlobalSettings.setTheme(value);
                },
              ),
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
                value: language,
                onChanged: (newValue) async {
                  setState(() {
                    language = newValue!;
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

                                // Navigate to the login screen
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(Translations.translate('changePassword')),
            ),
          ],
        ),
      ),
    );
  }

  /// Build mobils layout
  ///
  /// - [screenWidth] Current screen width
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
              value: darkMode,
              onChanged: (value) async {
                await GlobalSettings.setTheme(value);
              },
            ),
          ),
          _buildSettingTile(
            icon: Icons.language,
            title: Translations.translate('language'),
            subtitle: Translations.translate('languageSubtitle'),
            trailing: DropdownButton<AppLanguage>(
              value: language,
              onChanged: (newValue) async {
                setState(() {
                  language = newValue!;
                });

                // Change language, update GlobalSettings and write to the file with the corresponding lanugage code
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
                            value == AppLanguage.english
                                ? 'Inglés'
                                : 'Español', // DO NOT TRANSLATE
                          ),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(Translations.translate('changePassword')),
          ),
        ],
      ),
    );
  }

  /// Build a tile with the parsed in arguments
  ///
  /// - [icon] Icon to display
  /// - [title] Text to display
  /// - [subtitle] Smaller text to display
  /// - [trailing] Widget trailing the tile
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
