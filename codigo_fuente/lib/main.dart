import 'package:codigo/admin_menu_page.dart';
import 'package:flutter/material.dart';
import 'mysql_manager.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:codigo/user.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the application.
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

/// Home page widget that demonstrates CRUD operations.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// State for MyHomePage, which interacts with the database.
class _MyHomePageState extends State<MyHomePage> {
  // Controller to get data from textedit widgets
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  User? loggedInUser = null;

  @override
  void initState() {
    super.initState();
    // Load data when the page initializes.
  }

  String hashPassword(String password) {
    const String fixedSalt =
        '\$2a\$10\$yVxztTQyA0dxldZfbx7TuOQ2akDZxKc6o7l0ns29kw.XJ2ykQyySO';
    return BCrypt.hashpw(password, fixedSalt);
  }

  Future<void> login() async {
    String email = _emailController.text;
    String hashedPassword = hashPassword(_passwordController.text);

    // Await the static instance of MysqlManager
    final mysqlManager = await MysqlManager.getInstance();

    // Call the login method on the instance
    loggedInUser = await mysqlManager.login(
      email: email,
      hashedPassword: hashedPassword,
    );

    if (loggedInUser == null) {
      print("Not logged in");
    } else {
      print("Logged in as: ${loggedInUser!.role}");
      switch (loggedInUser!.role) {
        case "Administrador":
          print("Navigating to Admin page");
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => AdminMenu(
                    dbManager: mysqlManager,
                    loggedAsUser: loggedInUser!,
                  ),
            ),
          );
          break;
        case "Profesor":
          print("Navigating to Profesor page");
          // Add navigation for Profesor here if needed
          break;
        case "Sala_de_Profesores":
          print("Navigating to Sala de Profesores page");
          // Add navigation for Sala_de_Profesores here if needed
          break;
        default:
          print("Unknown role");
      }
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
          //
          //
          // MAIL TEXTFIELD
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: TextFormField(
                autofocus: true,
                controller: _emailController, // Link controller
                decoration: InputDecoration(hintText: "Correo"),
              ),
            ),
          ),
          SizedBox(height: 10),
          //
          //
          // PASSWORD TEXT FIELD
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: TextFormField(
                obscureText: true,
                controller: _passwordController, // Link controller
                decoration: InputDecoration(hintText: "Contraseña"),
              ),
            ),
          ),
          SizedBox(height: 10),
          //
          //
          // LOGIN BUTTON
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: ElevatedButton(
                onPressed: login,
                child: Text("Iniciar Sesión"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
