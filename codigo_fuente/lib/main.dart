import 'package:codigo/Profesor_main_menu_page.dart';
import 'package:codigo/admin_main_menu_page.dart';
import 'package:codigo/sala_main_menu_page.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:codigo/user_object.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure initialization
  await SupabaseManager.instance
      .initialize(); // Initialize Supabase before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MySQL Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  // ignore: avoid_init_to_null
  UserObject? loggedInUser = null;

  @override
  void initState() {
    super.initState();
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
      print('Logged in successfully via Supabase: ${supabaseUser}');
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

  Future<void> supabaseRegister() async {
    final supabaseUser = await SupabaseManager.instance.register(
      _emailController.text,
      _passwordController.text,
      "Sin asignar",
      "Sin asignar",
      "Sin asignar",
      "Sin asignar",
    );

    if (supabaseUser != null) {
      showSnackBar(
        "Te hemos envíado un correo para verificar tu cuenta",
        Colors.white,
        Colors.black,
      );
      print('Registered successfully via Supabase: ${supabaseUser.email}');
    } else {
      print('Registration failed via Supabase');
      showSnackBar("Algo salió mal", Colors.redAccent, Colors.black);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    final scalingFactor = 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: TextFormField(
                autofocus: true,
                controller: _emailController,
                decoration: InputDecoration(hintText: "Correo"),
              ),
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: TextFormField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(hintText: "Contraseña"),
              ),
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: ElevatedButton(
                onPressed: supabaseLogin,
                child: Text("Login in Supabase"),
              ),
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: ElevatedButton(
                onPressed: supabaseRegister,
                child: Text("Register in Supabase"),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
