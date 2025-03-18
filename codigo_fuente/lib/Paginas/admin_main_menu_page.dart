import 'package:flutter/material.dart';
import 'package:codigo/Paginas/profesor_main_menu_page.dart';
import 'package:codigo/Paginas/register_user_page.dart';
import 'package:codigo/Paginas/view_Users_page.dart';

class AdminMainMenuPage extends StatefulWidget {
  const AdminMainMenuPage({super.key});

  @override
  State<AdminMainMenuPage> createState() => _AdminMainMenuPageState();
}

class _AdminMainMenuPageState extends State<AdminMainMenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Menú Administrador",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'perfil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegistrationPage()),
                );
              } else if (value == 'ajustes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewUsersPage()),
                );
              } else if (value == 'salir') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfesorMainMenuPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'perfil',
                child: Text('Ver Perfil'),
              ),
              const PopupMenuItem(
                value: 'ajustes',
                child: Text('Ajustes'),
              ),
              const PopupMenuItem(
                value: 'salir',
                child: Text('Cerrar Sesión'),
              ),
            ],
            icon: const Icon(Icons.account_circle, size: 30, color: Colors.white),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(
              icon: Icons.person_add,
              text: 'Registrar nuevo Usuario',
              onTap: () => _navigateTo(const RegistrationPage()),
            ),
            const SizedBox(height: 15),
            _buildMenuButton(
              icon: Icons.people,
              text: 'Ver Usuarios registrados',
              onTap: () => _navigateTo(const ViewUsersPage()),
            ),
            const SizedBox(height: 15),
            _buildMenuButton(
              icon: Icons.event,
              text: 'Ver ausencias',
              onTap: () => _navigateTo(const ProfesorMainMenuPage()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({required IconData icon, required String text, required VoidCallback onTap}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}