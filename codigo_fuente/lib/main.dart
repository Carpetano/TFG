// ignore_for_file: avoid_print

import 'package:codigo/Paginas/admin_main_menu_page.dart';
import 'package:codigo/Paginas/profesor_main_menu_page.dart';
import 'package:codigo/Paginas/sala_main_menu_page.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:codigo/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:video_player/video_player.dart';

/// Main function for the entire app
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialization
  await SupabaseManager.instance
      .initialize(); // Initialize Supabase before running the app
  runApp(const MyApp());
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
    return AppEasyTheme().buildAppWithTheme(
      isDarkMode: _themeMode == ThemeMode.dark, // Pass the correct theme mode
      title: "Test",
      onThemeToggle:
          () =>
              _toggleTheme(), // Pass the theme toggle function wrapped in a closure
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
  ///
  /// This function creates a snackbar with the provided message, text color,
  /// and background color, then displays it using the ScaffoldMessenger
  ///
  /// - [message]: The text content of the snackbar
  /// - [textColor]: The color of the text inside the snackbar
  /// - [bgColor]: The background color of the snackbar
  void showSnackBar(String message, Color textColor, Color bgColor) {
    // Create a Snack BAr given the parameters
    var snackBar = SnackBar(
      content: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Text(message),
      ),
      backgroundColor: bgColor,
    );
    // Show the snack bar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Attempt to log-in into Supabase given the text inside the email and password controllers
  ///
  /// If it succeeds it will redirect the user to the corresponding page depending on the assigned role
  /// Otherwise, it will display a snackbar providing the Supabase error
  Future<void> supabaseLogin() async {
    // Attempt to log in with the data from the form fields
    final supabaseUser = await SupabaseManager.instance.login(
      _emailController.text,
      _passwordController.text,
    );

    // Check if the returned user is null
    if (supabaseUser != null) {
      // Store the logged-in user globally in MyApp
      MyApp.loggedInUser = supabaseUser;

      // Show a welcome message
      showSnackBar(
        "Bienvenido ${supabaseUser.firstName.toString()}",
        Colors.white,
        Colors.black,
      );

      // Depending on the role navigate to a page or another
      switch (supabaseUser.role.toLowerCase()) {
        // Admin Role
        case "administrador":
          // Navigate to the admin page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminMainMenuPage()),
          );
          break;
        // Profesor Role
        case "profesor":
          // Navigate to the Profesor page
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
            MaterialPageRoute(builder: (context) => const SalaMainMenuPage()),
          );
          break;
        // This shouldn't show up but just in case
        default:
          // Show an error snack bar
          showSnackBar(
            "Error redirigiendo, no se ha encontrado un rol válido: ${supabaseUser.role}",
            Colors.red,
            Colors.black,
          );
          break;
      }
    } else {
      // Show error sign
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
        // Video de fondo que ocupa toda la pantalla
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
        // Contenido centrado en el contenedor responsivo
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
                Text(
                  "Guardias Calderón",
                  style: TextStyle(
                    fontSize: 48, // Font size of 48
                    fontWeight: FontWeight.bold, // Make the text bold
                    fontStyle: FontStyle.italic, // Make the text italic
                    color:
                        Theme.of(context)
                            .colorScheme
                            .primary, // Use the primary color from the theme
                    shadows: [
                      Shadow(
                        blurRadius: 30.0, // Blur radius of the shadow
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.primary, // Shadow color
                        offset: Offset(5.0, 5.0), // Shadow offset (x, y)
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Correo",
                    hintStyle: TextStyle(
                      color:
                          Theme.of(context)
                              .colorScheme
                              .onSecondary, // Cambia el color del texto
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
                    hintText: "Contraseña",
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
                  child: Text("Iniciar Sesión"),
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
            "Guardias Calderón",
            style: TextStyle(
              fontSize: 48, // Font size of 48
              fontWeight: FontWeight.bold, // Make the text bold
              fontStyle: FontStyle.italic, // Make the text italic
              color:
                  Theme.of(
                    context,
                  ).colorScheme.primary, // Use the primary color from the theme
              shadows: [
                Shadow(
                  blurRadius: 30.0, // Blur radius of the shadow
                  color: Theme.of(context).colorScheme.primary, // Shadow color
                  offset: Offset(5.0, 5.0), // Shadow offset (x, y)
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
                hintText: "Correo",
                hintStyle: TextStyle(
                  color:
                      Theme.of(
                        context,
                      ).colorScheme.onSecondary, // Cambia el color del texto
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
          ),
          SizedBox(height: 10),
          SizedBox(
            width: screenWidth * 0.8,
            child: TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Contraseña",
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
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  Theme.of(context).colorScheme.primary, // Background color
              foregroundColor:
                  Theme.of(context).colorScheme.onPrimary, // Text color
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ), // Button padding
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Rounded corners
                side: BorderSide(
                  color: Theme.of(context).colorScheme.primary, // Border color
                  width: 2, // Border thickness
                ),
              ),
            ),
            onPressed: supabaseLogin,
            child: Text("Iniciar Sesión"),
          ),
        ],
      ),
    );
  }
}
