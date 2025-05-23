import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enum for supported languages
enum AppLanguage { english, espanol }

/// Extension to get language code and display name
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

/// Class for managing translations
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
      'professor': 'Professor',
      'pageTitle': 'Settings',
      'professorMenu': 'Professor Menu',
      'viewProfile': 'View Profile',
      'adminMenu': 'Admin Menu',
      'unasignedGuardiasSnackBar': 'Unassigned supervisions: ',
      'noUnasignedGuardiasSnackBar': 'There\'s no unassigned supervisions',
      'welcome': 'Welcome',
      'unknown': 'Unknown',
      'selectOption2Continue': 'Select an option to continue:',
      'registerNewUser': 'Register new user',
      'viewRegistredUsers': 'View Registered Users',
      'viewAbences': 'View absences',
      'guardiasDone': 'Supervisions done',
      'pendingGuardias': 'Pending supervisions',
      'deleteGuardia': 'Delete selected supervisions',
      'goback': 'Go back',
      'plsSelectTeacherClassAndShift':
          'Please select a teachr, a class and a shift',
      'selectClass': 'Select class',
      'supervisions': 'Guardias',
      'noPendingGuardias': 'No pending Supervisions',
      'mySupervisions': 'My supervisions',
      'phone': 'Phone number',
      'role': 'Role',
      'date': 'Date',
      'status': 'Status',
      'guardia': 'Supervision',
      'tram': 'Tram',
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
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'login': 'Iniciar Sesión',
      'reloginRequired': 'Reinicio de sesión requerido',
      'reloginRequired2': 'Necesita reiniciar sesión para aplicar los cambios',
      'addAusencia': 'Añadir ausencia',
      'viewGuardias': 'Ver guardias',
      'registeredUsers': 'Usuarios registrados',
      'lookUpUsers': 'Buscar usuarios...',
      'edit': 'Editar',
      'deactivate': 'Desactivar',
      'professor': 'Profesor',
      'pageTitle': 'Ajustes',
      'professorMenu': 'Menú de Profesor',
      'viewProfile': 'Ver Perfil',
      'adminMenu': 'Menú de Administrador',
      'unasignedGuardiasSnackBar': 'Guardias no asignadas: ',
      'noUnasignedGuardiasSnackBar': 'No hay guardias no asignadas',
      'welcome': 'Bienvenido',
      'unknown': 'Desconocido',
      'selectOption2Continue': 'Seleccione una opción para continuar:',
      'registerNewUser': 'Registrar nuevo usuario',
      'viewRegistredUsers': 'Ver usuarios registrados',
      'viewAbences': 'Ver ausencias',
      'guardiasDone': 'Guardias realizadas',
      'pendingGuardias': 'Guardias pendientes',
      'deleteGuardia': 'Borrar guardias seleccionadas',
      'goback': 'Volver',
      'plsSelectTeacherClassAndShift':
          'Porfavor selecciona un profesor, un aula y un turno',
      'selectClass': 'Seleccionar clase',
      'supervisions': 'Guardias',
      'noPendingGuardias': 'No hay guardias sin asignar',
      'mySupervisions': 'Mis guardias',
      'phone': 'Número de teléfono',
      'role': 'Rol',
      'date': 'Fecha',
      'status': 'Estado',
      'guardia': 'Guardia',
      'tram': 'Tramo horario',
    },
  };

  /// Translate a text given it's reference in the local dictionaries, automatically gets the display language and returns the translaed text
  static String translate(String key) {
    String langCode = GlobalSettings.language.value.code;
    return _localizedValues[langCode]?[key] ?? key;
  }
}

/// Global app settings
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
