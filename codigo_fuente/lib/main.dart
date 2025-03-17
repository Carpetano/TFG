import 'package:codigo/Paginas/admin_main_menu_page.dart';
import 'package:codigo/Paginas/sala_main_menu_page.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:video_player/video_player.dart';
import 'package:codigo/Paginas/profesor_main_menu_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialization
  await SupabaseManager.instance
      .initialize(); // Initialize Supabase before running the app
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

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
    return MaterialApp(
      title: 'Guardias Calderón',
      themeMode: _themeMode, // Set theme mode dynamically
      theme: ThemeData(
        // Define the main color scheme for the application
        colorScheme: ColorScheme(
          primary:
              Colors
                  .black, // Main color for primary elements (e.g. AppBar, Buttons)
          secondary: Colors.blue, // Accent color used in UI elements like FABs
          surface: Colors.white, // Surface color for cards, dialogs, etc.
          error:
              Colors
                  .red, // Error color, typically used for form fields, error messages
          onPrimary:
              Colors.white, // Text and icons on the primary background color
          onSecondary:
              Colors.white, // Text and icons on the secondary background color
          onSurface:
              Colors
                  .black, // Text and icons on surface (e.g. Card) background color
          onError: Colors.white, // Text and icons on error color background
          brightness: Brightness.light, // Light theme
        ),
        scaffoldBackgroundColor:
            Colors.grey[100], // App background color (light grey)
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // Black AppBar
          foregroundColor: Colors.white, // White text/icons on the AppBar
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue, // Default button color
          textTheme: ButtonTextTheme.primary, // Button text color (inverted)
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
        colorScheme: ColorScheme(
          primary: Colors.white, // Main color for primary elements in dark mode
          secondary: Colors.blue, // Accent color used in UI elements like FABs
          surface: Colors.black, // Surface color for dark mode (cards, dialogs)
          error: Colors.red,
          onPrimary:
              Colors.black, // Text and icons on primary background in dark mode
          onSecondary: Colors.black, // Text and icons on secondary background
          onSurface: Colors.white, // Text and icons on surface (e.g. Card)
          onError: Colors.black, // Text and icons on error background
          brightness: Brightness.dark, // Dark theme
        ),
        scaffoldBackgroundColor: Colors.grey[900], // Dark background color
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black, // Black AppBar
          foregroundColor: Colors.white, // White text/icons on the AppBar
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
      home: const MyHomePage(title: 'Iniciar Sesión'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  Future<void> supabaseLogin() async {
    final supabaseUser = await SupabaseManager.instance.login(
      _emailController.text,
      _passwordController.text,
    );

    if (supabaseUser != null) {
      print('Logged in successfully via Supabase: $supabaseUser');
      showSnackBar(
        "Iniciado sesión con éxito, Bienvenido ${supabaseUser.firstName.toString()}",
        Colors.white,
        Colors.black,
      );
      print("Role: ${supabaseUser.role}");
      switch (supabaseUser.role.toLowerCase()) {
        case "administrador":
          print("Navigating to Admin page");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdminMainMenuPage()),
          );
          break;
        case "profesor":
          print("Navigating to Profesor page");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfesorMainMenuPage(),
            ),
          );
          break;
        case "sala_de_profesores":
          print("Navigating to Sala page");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SalaMainMenuPage()),
          );
          break;
        default:
          print("Unknown role: ${supabaseUser.role}");
          break;
      }
    } else {
      print('Login failed via Supabase');
      showSnackBar(
        "No se ha podido iniciar sesión",
        Colors.white,
        Colors.black,
      );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            // Toggle the theme mode when the button is pressed
            (context.findAncestorStateOfType<_MyAppState>() as _MyAppState)
                ._toggleTheme();
          });
        },
        child: Icon(Icons.brightness_6),
        backgroundColor:
            Theme.of(
              context,
            ).colorScheme.secondary, // Accent color for the button
      ),
    );
  }

  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    return Container(
      height: screenHeight, // Full vertical space
      child: Row(
        children: [
          // Form Fields Section (60% width)
          Expanded(
            flex: 3, // 60% of the screen
            child: Container(
              padding: EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TITLE
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
                              ).colorScheme.secondary, // Shadow color
                          offset: Offset(5.0, 5.0), // Shadow offset (x, y)
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  // EMAIL FIELD
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(hintText: "Correo"),
                  ),
                  SizedBox(height: 20),
                  // PASSWORD FIELD
                  TextFormField(
                    obscureText: true,
                    controller: _passwordController,
                    decoration: InputDecoration(hintText: "Contraseña"),
                  ),
                  SizedBox(height: 40),
                  // LOGIN BUTTON
                  ElevatedButton(
                    onPressed: supabaseLogin,
                    child: Text("Login in Supabase"),
                  ),
                ],
              ),
            ),
          ),
          // Video Section (40% width)
          Expanded(
            flex: 2, // 40% of the screen
            child: Container(
              color: Colors.grey[200], // Placeholder background
              child: Center(
                child:
                    _videoController.value.isInitialized
                        ? AspectRatio(
                          aspectRatio: _videoController.value.aspectRatio,
                          child: VideoPlayer(_videoController),
                        )
                        : CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMobileLayout(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: screenWidth * 0.8,
            child: TextFormField(
              controller: _emailController,
              decoration: InputDecoration(hintText: "Correo"),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: screenWidth * 0.8,
            child: TextFormField(
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(hintText: "Contraseña"),
            ),
          ),
        ],
      ),
    );
  }
}
