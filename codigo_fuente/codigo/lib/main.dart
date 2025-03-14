import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Start with light mode
  ThemeMode _themeMode = ThemeMode.light;

  // Light Theme
  final ThemeData lightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: Colors.white, // Set light background color
  );

  // Dark Theme
  final ThemeData darkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: Colors.black, // Set dark background color
  );

  static const double PHONE_WIDTH = 800; // Threshold for phone layout

  // Method to toggle between light and dark mode
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isPhone = screenWidth <= PHONE_WIDTH;

    return MaterialApp(
      title: 'Flutter Demo', // Title of the page
      themeMode: _themeMode, // Whether it's dark or light mode
      theme: lightTheme, // Set the light theme by default
      darkTheme: darkTheme, // Declare dark theme
      home: MyHomePage(
        title: 'Inicio de Sesión',
        toggleTheme: _toggleTheme,
        isPhone: isPhone, // Pass the layout type to the home page
        screenHeight: screenHeight,
        screenWidth: screenWidth,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.toggleTheme,
    required this.isPhone,
    required this.screenHeight,
    required this.screenWidth,
  });

  final String title;
  final VoidCallback toggleTheme;
  final bool isPhone;
  final double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Modo: ${Theme.of(context).brightness == Brightness.dark ? "Oscuro" : "Claro"}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            // Conditional rendering based on isPhone
            if (isPhone) ...[
              /*
              
               Phone layout

              */

              // Mail
              Text('Dirección de correo:', textAlign: TextAlign.start),
              SizedBox(
                width: screenWidth * 0.8,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black, // Change this to a visible color
                        width: 3,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // Visible color
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue, // Highlight color when focused
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                ),
              ),

              // Password
              Text('Contraseña:', textAlign: TextAlign.start),
              SizedBox(
                width: screenWidth * 0.8,
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black, // Change this to a visible color
                        width: 3,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey, // Visible color
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.blue, // Highlight color when focused
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  autofocus: false,
                  keyboardType: TextInputType.text,
                ),
              ),
            ] else ...[
              // Desktop layout
              const Text('Este es un diseño de Escritorio'),
              // Add more widgets for the desktop layout if needed
              ElevatedButton(
                onPressed: () {
                  // Add your logic for desktop button
                },
                child: const Text('Botón para Escritorio'),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: toggleTheme,
        tooltip: 'Modo Claro / Oscuro',
        child: const Icon(Icons.sunny),
      ),
    );
  }
}
