// Inside AppEasyTheme class
import 'package:codigo/main.dart';
import 'package:flutter/material.dart';

class AppEasyTheme {
  /// Returns a [MaterialApp] with a theme based on the passed argument.
  MaterialApp buildAppWithTheme({
    required bool isDarkMode,
    required String title,
    required VoidCallback onThemeToggle, // Add the onThemeToggle parameter here
  }) {
    return MaterialApp(
      title: title,
      themeMode:
          isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light, // Toggle between light/dark theme
      theme: ThemeData(
        // Define the main color scheme for the application (light mode)
        colorScheme: ColorScheme(
          primary: Colors.black,
          secondary: Colors.blue,
          surface: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
          onSurfaceVariant: Colors.grey[400],
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        textTheme: TextTheme(
          bodySmall: TextStyle(color: Colors.black, fontFamily: 'Roboto'),
          bodyMedium: TextStyle(color: Colors.grey[700], fontFamily: 'Roboto'),
          bodyLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      darkTheme: ThemeData(
        // Define the main color scheme for the application (dark mode)
        colorScheme: ColorScheme(
          primary: Colors.white,
          secondary: Colors.blue,
          surface: Colors.black,
          error: Colors.red,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onSurfaceVariant: Colors.black54,
          onError: Colors.black,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
        ),
        textTheme: TextTheme(
          bodySmall: TextStyle(color: Colors.white, fontFamily: 'Roboto'),
          bodyMedium: TextStyle(color: Colors.grey[400], fontFamily: 'Roboto'),
          bodyLarge: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
      ),
      home: MyHomePage(
        title: title,
        onThemeToggle: onThemeToggle, // Pass the onThemeToggle here
      ),
    );
  }
}
