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
          primary: Color(
            0xFF4A90E2,
          ), // A soft blue for accents (primary actions like buttons)
          secondary: Color(
            0xFFB8B8B8,
          ), // A muted gray for secondary actions (links, secondary buttons)
          surface:
              Colors
                  .white, // Light surface background color (for cards, containers)
          error: Colors.redAccent, // A soft red for error indications
          onPrimary:
              Colors
                  .white, // Text color on primary-colored elements (light text on blue buttons)
          onSecondary:
              Colors
                  .black, // Text color on secondary-colored elements (dark text on secondary elements)
          onSurface:
              Colors
                  .black87, // Text color on surface-colored elements (soft black text)
          onSurfaceVariant:
              Colors
                  .grey[300]!, // Text color for secondary surfaces or variant elements
          onError:
              Colors
                  .white, // Text color for error-related elements (white text on red)
          brightness:
              Brightness
                  .light, // Specifies the brightness of the theme (light mode)
        ),
        scaffoldBackgroundColor: Color(
          0xFFF5F5F5,
        ), // Light background color for the entire app (off-white)
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF4A90E2), // App bar color (primary blue)
          foregroundColor:
              Colors.white, // App bar text (foreground) color (white text)
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF4A90E2), // Button color (primary blue)
          textTheme:
              ButtonTextTheme
                  .primary, // Text color for buttons, uses primary color theme
        ),
        textTheme: TextTheme(
          bodySmall: TextStyle(
            color: Colors.black87,
            fontFamily: 'Roboto',
          ), // Smaller body text color
          bodyMedium: TextStyle(
            color: Colors.black54,
            fontFamily: 'Roboto',
          ), // Medium body text color
          bodyLarge: TextStyle(
            color: Colors.black, // Large body text color (main content)
            fontWeight: FontWeight.w400, // Regular weight for normal text
            fontFamily: 'Roboto',
          ),
        ),
      ),
      darkTheme: ThemeData(
        // Define the main color scheme for the application (dark mode)
        colorScheme: ColorScheme(
          primary: Color(
            0xFF4A90E2,
          ), // A soft blue for accents (same for both modes)
          secondary: Color(
            0xFFB8B8B8,
          ), // A muted gray for secondary actions (same for both modes)
          surface: Color(
            0xFF2E2E2E,
          ), // Dark surface background color (for cards, containers)
          error:
              Colors
                  .redAccent, // Soft red for error indications (same for both modes)
          onPrimary:
              Colors
                  .black, // Text color on primary-colored elements (black text on blue)
          onSecondary:
              Colors
                  .white, // Text color on secondary-colored elements (white text on gray)
          onSurface:
              Colors
                  .white70, // Text color on surface-colored elements (light text on dark backgrounds)
          onSurfaceVariant:
              Colors
                  .grey[800]!, // Text color for secondary surfaces or variant elements
          onError:
              Colors
                  .white, // Text color for error-related elements (white text on red)
          brightness:
              Brightness
                  .dark, // Specifies the brightness of the theme (dark mode)
        ),
        scaffoldBackgroundColor: Color(
          0xFF1C1C1C,
        ), // Dark background color for the entire app (dark gray)
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF4A90E2), // App bar color (primary blue)
          foregroundColor:
              Colors.white, // App bar text (foreground) color (white text)
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Color(0xFF4A90E2), // Button color (primary blue)
          textTheme:
              ButtonTextTheme
                  .primary, // Text color for buttons, uses primary color theme
        ),
        textTheme: TextTheme(
          bodySmall: TextStyle(
            color: Colors.white70,
            fontFamily: 'Roboto',
          ), // Smaller body text color (light gray)
          bodyMedium: TextStyle(
            color: Colors.white54,
            fontFamily: 'Roboto',
          ), // Medium body text color (lighter gray)
          bodyLarge: TextStyle(
            color: Colors.white, // Large body text color (main content)
            fontWeight: FontWeight.w400, // Regular weight for normal text
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
