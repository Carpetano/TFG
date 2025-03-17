import 'package:codigo/profesor_main_menu_page.dart';
import 'package:codigo/register_user_page.dart';
import 'package:codigo/view_Users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AdminMainMenuPage extends StatefulWidget {
  const AdminMainMenuPage({super.key});

  @override
  State<AdminMainMenuPage> createState() => _AdminMainMenuPageState();
}

class _AdminMainMenuPageState extends State<AdminMainMenuPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Menú administrador")),
      body: Column(
        children: [
          //
          //
          // GO TO USER REGISTRATION PAGE
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers items in row
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationPage(),
                    ),
                  );
                },
                child: Text('Registrar nuevo Usuario'),
              ),
              SizedBox(width: 20), // Space between buttons
            ],
          ),
          SizedBox(height: 20), // Space between row and next element
          //
          //
          // GO TO VIEW USERS
          SizedBox(height: 20), // Space before next row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  print("thing2");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ViewUsersPage(),
                    ),
                  );
                },
                child: Text('Ver Usuarios registrados'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  print("thing2");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfesorMainMenuPage(),
                    ),
                  );
                },
                child: Text('Ver ausencias'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
