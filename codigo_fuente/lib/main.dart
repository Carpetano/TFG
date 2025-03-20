// ignore_for_file: avoid_print

// Translated
import 'package:codigo/Paginas/admin_main_menu_page.dart';
import 'package:codigo/Paginas/profesor_main_menu_page.dart';
import 'package:codigo/Paginas/sala_page.dart';
import 'package:codigo/global_settings.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

/// Main function for the entire app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseManager.instance.initialize();
  await GlobalSettings.initialize();

  // Load the default language from file
  GlobalSettings.setLanguage(await getDefaultLanguage());
  print("[DEBUG]: Display lang: ${GlobalSettings.language.value.name}");

  runApp(const MyApp());
}

Future<AppLanguage> getDefaultLanguage() async {
  final file = File('default_lang.txt');
  try {
    if (!await file.exists()) {
      // If the file doesn't exist, create it and set default to 'es'
      await file.writeAsString('es');
      print("[INFO] default_lang.txt not found. Created and set to 'es'.");
    }

    String langCode = await file.readAsString();
    print('LANG FROM FILE: $langCode');

    switch (langCode.toLowerCase()) {
      case 'en':
        return AppLanguage.english;
    }
  } catch (e) {
    print("[ERROR] Failed to read/write default language: $e");
  }

  // Fallback language
  return AppLanguage.espanol;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static UserObject? loggedInUser;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Add a theme mode state variable
  ThemeMode _themeMode = ThemeMode.light;

  // Toggle theme function
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: GlobalSettings.language,
      builder: (context, language, _) {
        return MaterialApp(
          title: "Test",
          themeMode: _themeMode, // Use the stored theme mode
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              secondary: Colors.blueAccent,
              onSecondary: Colors.black,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.blueGrey,
            colorScheme: ColorScheme.dark(
              primary: Colors.blueGrey,
              onPrimary: Colors.white,
              secondary: Colors.teal,
              onSecondary: Colors.white70,
            ),
          ),
          home: MyHomePage(title: "Test", onThemeToggle: _toggleTheme),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.onThemeToggle,
  });
  final String title;
  final VoidCallback onThemeToggle; // Accept the theme toggle function

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Controllers to get the text from form fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UserObject? loggedInUser;

  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(
        "https://gykqibexlzwxpliezelo.supabase.co/storage/v1/object/public/tfgbucket/videos/main.mp4",
      ),
    );

    // Add a listener to check if the video is initialized
    _videoController.addListener(() {
      if (_videoController.value.isInitialized) {
        // Start playing the video as soon as it's initialized
        setState(() {});
        _videoController.play();
      }
    });

    // Initialize the video player
    _videoController.initialize().then((_) {
      _videoController.setLooping(true);

      // Trigger re-build after initialization
      setState(() {});
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  /// Displays a snackbar message at the bottom of the screen
  /// This function creates a snackbar with the provided message, text color,
  /// and background color, then displays it using the ScaffoldMessenger
  ///
  /// - [message]: The text content of the snackbar
  /// - [textColor]: The color of the text inside the snackbar
  /// - [bgColor]: The background color of the snackbar
  void showSnackBar(String message, Color textColor, Color bgColor) {
    var snackBar = SnackBar(
      content: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Text(message),
      ),
      backgroundColor: bgColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Attempt to log-in into Supabase given the text inside the email and password controllers
  /// If it succeeds it will redirect the user to the corresponding page depending on the assigned role
  /// Otherwise, it will display a snackbar providing the Supabase error
  Future<void> supabaseLogin() async {
    final supabaseUser = await SupabaseManager.instance.login(
      _emailController.text,
      _passwordController.text,
    );

    if (supabaseUser != null) {
      MyApp.loggedInUser = supabaseUser;

      switch (supabaseUser.role.toLowerCase()) {
        case "administrador":
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminMainMenuPage()),
          );
          break;
        case "profesor":
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfesorMainMenuPage(),
            ),
          );
          break;
        // Sala role
        case "sala_de_profesores":
          // Navigate to the Sala page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalaProfesoresPage()),
          );
          break;
        // This shouldn't show up but just in case
        default:
          showSnackBar(
            "Error redirigiendo, no se ha encontrado un rol válido: ${supabaseUser.role}",
            Colors.red,
            Colors.black,
          );
          break;
      }
    } else {
      showSnackBar("Credenciales incorrectas", Colors.white, Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;
    final maxPhoneWidth = 600;

    return Scaffold(
      body:
          screenWidth > maxPhoneWidth
              ? buildDesktopLayout(screenWidth, screenHeight)
              : buildMobileLayout(screenWidth),
    );
  }

  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        Positioned.fill(
          child:
              _videoController.value.isInitialized
                  ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                  : const Center(child: CircularProgressIndicator()),
        ),
        Center(
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
                Center(
                  // Add a Center widget to center the Text
                  child: Text(
                    "Guardias Calderón",
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.primary,
                      shadows: [
                        Shadow(
                          blurRadius: 30.0,
                          color: Theme.of(context).colorScheme.primary,
                          offset: Offset(5.0, 5.0),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: Translations.translate('email'),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: Translations.translate('password'),
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: supabaseLogin,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(Translations.translate('login')),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildMobileLayout(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Translations.translate('hello'),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).colorScheme.primary,
              shadows: [
                Shadow(
                  blurRadius: 30.0,
                  color: Theme.of(context).colorScheme.primary,
                  offset: Offset(5.0, 5.0),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: screenWidth * 0.8,
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.onSecondary, // Cambia el color del texto
                ),
                hintText: Translations.translate('email'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: screenWidth * 0.8,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                hintText: Translations.translate('password'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary, // Border color
                  width: 2, // Border thickness
                ),
              ),
            ),
            onPressed: supabaseLogin,
            child: Text(Translations.translate('login')),
          ),
        ],
      ),
    );
  }
}
