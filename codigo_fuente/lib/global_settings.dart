import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for supported languages.
enum AppLanguage { english, espanol }

/// Extension to get language code and display name.
extension AppLanguageExtension on AppLanguage {
  String get code {
    switch (this) {
      case AppLanguage.english:
        return 'en';
      case AppLanguage.espanol:
        return 'es';
    }
  }

  String get displayName {
    switch (this) {
      case AppLanguage.english:
        return 'English';
      case AppLanguage.espanol:
        return 'Español';
    }
  }
}

/// Class for managing translations.
class Translations {
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Settings',
      'personalization': 'Personalization',
      'darkMode': 'Dark Mode',
      'darkModeSubtitle': 'Switch to dark mode for a different look',
      'language': 'Language',
      'languageSubtitle': 'Select the language for the app',
      'notifications': 'Notifications',
      'notificationsSubtitle': 'Turn on to receive notifications',
      'changePassword': 'Change Password',
      'profile': 'Profile',
      'settings': 'Settings',
      'logout': 'Log-out',
      'viewMySupervisions': 'View my Supervisions',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'reloginRequired': 'Re-login Required',
      'reloginRequired2': 'You need to re-login to apply the changes',
      'addAusencia': 'Add new absence',
      'viewGuardias': 'View supervisions',
      'registeredUsers': 'Registered users',
      'lookUpUsers': 'Look up users...',
      'edit': 'Edit',
      'deactivate': 'Deactivate',
    },
    'es': {
      'title': 'Ajustes',
      'personalization': 'Personalización',
      'darkMode': 'Modo Oscuro',
      'darkModeSubtitle': 'Activa el modo oscuro para un estilo diferente',
      'language': 'Idioma',
      'languageSubtitle': 'Selecciona el idioma de la aplicación',
      'notifications': 'Notificaciones',
      'notificationsSubtitle': 'Actívalas para recibir notificaciones',
      'changePassword': 'Cambiar Contraseña',
      'profile': 'Perfil',
      'settings': 'Ajustes',
      'logout': 'Cerrar Sesión',
      'viewMySupervisions': 'Ver mis guardias',
      'email': 'Email',
      'password': 'Contraseña',
      'login': 'Iniciar Sesión',
      'reloginRequired': 'Reinicio de sesión requirido',
      'reloginRequired2': 'Necesita reiniciar sesión para aplicar los cambios',
      'addAusencia': 'Añadir ausencia',
      'viewGuardias': 'Ver guardias',
      'registeredUsers': 'Usuarios registrados',
      'lookUpUsers': 'Buscar usuarios...',
      'edit': 'Editar',
      'deactivate': 'Desactivar',
    },
  };

  static String translate(String key, String languageCode) {
    return _localizedValues[languageCode]?[key] ?? key;
  }
}

/// Global app settings.
class GlobalSettings {
  static final GlobalSettings instance = GlobalSettings._internal();

  static ValueNotifier<bool> isDarkMode = ValueNotifier(false);
  static ValueNotifier<AppLanguage> language = ValueNotifier(
    AppLanguage.espanol,
  );

  GlobalSettings._internal();

  /// Load stored preferences on app start.
  static Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;

    String langCode = prefs.getString('language') ?? 'es';
    language.value = AppLanguage.values.firstWhere(
      (e) => e.code == langCode,
      orElse: () => AppLanguage.espanol,
    );
  }

  /// Save theme preference.
  static Future<void> setTheme(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    isDarkMode.value = value;
  }

  /// Save language preference.
  static Future<void> setLanguage(AppLanguage lang) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang.code);
    language.value = lang;
  }

  /// Light theme configuration.
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: Color(0xFF4A90E2),
      secondary: Color(0xFFB8B8B8),
      surface: Colors.white,
      error: Colors.redAccent,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black87,
      onSurfaceVariant: Colors.grey[300]!,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF4A90E2),
      foregroundColor: Colors.white,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF4A90E2),
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(color: Colors.black87, fontFamily: 'Roboto'),
      bodyMedium: TextStyle(color: Colors.black54, fontFamily: 'Roboto'),
      bodyLarge: TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
    ),
  );

  /// Dark theme configuration.
  static final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF4A90E2),
      secondary: Color(0xFFB8B8B8),
      surface: Color(0xFF2E2E2E),
      error: Colors.redAccent,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: Colors.white70,
      onSurfaceVariant: Colors.grey[800]!,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Color(0xFF1C1C1C),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF4A90E2),
      foregroundColor: Colors.white,
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF4A90E2),
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: TextTheme(
      bodySmall: TextStyle(color: Colors.white70, fontFamily: 'Roboto'),
      bodyMedium: TextStyle(color: Colors.white54, fontFamily: 'Roboto'),
      bodyLarge: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w400,
        fontFamily: 'Roboto',
      ),
    ),
  );
}