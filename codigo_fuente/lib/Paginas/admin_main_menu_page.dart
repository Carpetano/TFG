import 'package:codigo/Paginas/profesor_main_menu_page.dart';
import 'package:codigo/Paginas/register_user_page.dart';
import 'package:codigo/Paginas/view_Users_page.dart';
import 'package:flutter/material.dart';

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
          // Existing content
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
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
              SizedBox(width: 20),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
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
          SizedBox(height: 20),

          // Floating action button to toggle theme
        ],
      ),
    );
  }
}
