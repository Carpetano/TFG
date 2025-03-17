// ignore_for_file: avoid_print

import 'package:codigo/Paginas/admin_main_menu_page.dart';
import 'package:codigo/Paginas/profesor_main_menu_page.dart';
import 'package:codigo/Paginas/sala_main_menu_page.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:codigo/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:video_player/video_player.dart';

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
    return AppEasyTheme().buildAppWithTheme(
      isDarkMode: _themeMode == ThemeMode.dark, // Pass the correct theme mode
      title: "Test",
      onThemeToggle: _toggleTheme, // Pass the theme toggle function
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
        onPressed: widget.onThemeToggle,
        backgroundColor:
            Theme.of(
              context,
            ).colorScheme.primary, // Call the theme toggle function
        child: Icon(Icons.brightness_6), // Accent color for the button
      ),
    );
  }

  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    return SizedBox(
      height: screenHeight, // Full vertical space
      child: Row(
        children: [
          // Form Fields Section (60% width)
          Expanded(
            flex: 3, // 60% of the screen
            child: Container(
              color: Theme.of(context).colorScheme.surface,
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
                              ).colorScheme.primary, // Shadow color
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(
                            context,
                          ).colorScheme.primary, // Background color
                      foregroundColor:
                          Theme.of(context).colorScheme.onPrimary, // Text color
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ), // Button padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Rounded corners
                        side: BorderSide(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.secondary, // Border color
                          width: 2, // Border thickness
                        ),
                      ),
                    ),
                    onPressed: supabaseLogin,
                    child: Text("Iniciar Sesión"),
                  ),
                ],
              ),
            ),
          ),
          // Vertical Divider (Bar) between the two sections
          VerticalDivider(
            thickness: 3, // Thickness of the divider
            width: 3, // Width of the divider
            color: Colors.grey[500], // Divider color
          ),
          // Video Section (40% width)
          Expanded(
            flex: 2, // 40% of the screen
            child: Container(
              padding: EdgeInsets.all(20),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              child: Center(
                child:
                    _videoController.value.isInitialized
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Rounded corners
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primary, // Border color
                                width: 3, // Border width
                              ),
                            ),
                            child: AspectRatio(
                              aspectRatio: _videoController.value.aspectRatio,
                              child: VideoPlayer(_videoController),
                            ),
                          ),
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
              decoration: InputDecoration(hintText: "Correo"),
            ),
          ),
          SizedBox(height: 10),
          SizedBox(
            width: screenWidth * 0.8,
            child: TextFormField(
              obscureText: true,
              controller: _passwordController,
              decoration: InputDecoration(hintText: "Contraseña"),
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
                  color:
                      Theme.of(context).colorScheme.secondary, // Border color
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
