import 'package:flutter/material.dart';
import 'package:codigo/Paginas/profesor_main_menu_page.dart';
import 'package:codigo/Paginas/register_user_page.dart';
import 'package:codigo/Paginas/view_users_page.dart';
import 'package:codigo/Paginas/perfil_page.dart';
import 'package:codigo/Paginas/settings_page.dart';
import 'package:codigo/main.dart';

class AdminMainMenuPage extends StatefulWidget {
  const AdminMainMenuPage({super.key});

  @override
  State<AdminMainMenuPage> createState() => _AdminMainMenuPageState();
}

class _AdminMainMenuPageState extends State<AdminMainMenuPage> {
  int _selectedIndex = 0;

  void _onNavigationItemSelected(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerfilPage()),
      ); 
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
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
    );
  }

  Widget buildMobileLayout(double screenWidth) {
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
                  MaterialPageRoute(
                    builder: (context) => const PerfilPage(),
                  ),
                );
              } else if (value == 'ajustes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsPage(),
                  ),
                );
              } else if (value == 'salir') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyApp(),
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(
                    value: 'perfil',
                    child: Text('Ver Perfil'),
                  ),
                  const PopupMenuItem(value: 'ajustes', child: Text('Ajustes')),
                  const PopupMenuItem(
                    value: 'salir',
                    child: Text('Cerrar Sesión'),
                  ),
                ],
            icon: const Icon(
              Icons.account_circle,
              size: 30,
              color: Colors.white,
            ),
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
  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueAccent),
              child: Text('Menú Administrador', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Ver perfil'),
              onTap: () => _onNavigationItemSelected(0),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Ajustes'),
              onTap: () => _onNavigationItemSelected(1),
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: const Text('Cerrar Sesión'),
              onTap: () => _onNavigationItemSelected(2),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          NavigationRail(
              minWidth: 120,
              backgroundColor: Colors.blueAccent,
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onNavigationItemSelected,
              labelType: NavigationRailLabelType.all,
              useIndicator: false, 
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.account_circle),
                  label: Text('Ver perfil'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.tune_rounded),
                  label: Text('Ajustes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.logout),
                  label: Text('Cerrar Sesión'),
                ),
              ],
            ),
          Expanded(
            child: Padding(
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
          ),
        ]
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}