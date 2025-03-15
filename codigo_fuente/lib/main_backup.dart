import 'package:codigo/register_use_page.dart';
import 'package:flutter/material.dart';
import 'mysql_manager.dart';
import 'package:bcrypt/bcrypt.dart';

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
      home: const MyHomePage(title: 'Flutter MySQL Demo Home Page'),
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
  MysqlManager dbManager = MysqlManager(); // Your dbManager instance

  @override
  void initState() {
    super.initState();
    // Load data when the page initializes.
  }

  String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  void insertTestData() {
    dbManager.insert("Test data2wer");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Text("hello world"),
          ElevatedButton(
            onPressed: () {
              // Remove the 'const' here since dbManager is not a constant value
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => RegistrationPage(
                        dbManager: dbManager, // Pass the dbManager instance
                      ),
                ),
              );
            },
            child: Text("Go to register user page"),
          ),
        ],
      ),
    );
  }
}
