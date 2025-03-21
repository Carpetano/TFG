import 'package:codigo/global_settings.dart';
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
       Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MyApp()), 
      (Route<dynamic> route) => false,
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
    double iconSize = (screenWidth * 0.04).clamp(
      30.0,
      50.0,
    ); // Tamaño entre 24px y 40px
    double textSize = (screenWidth * 0.02).clamp(
      20.0,
      40.0,
    ); // Tamaño entre 14px y 20px
    double titleSize = (screenWidth * 0.04).clamp(
      30.0,
      50.0,
    ); // Título de 18px a 30px

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Translations.translate('adminMenu'),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'perfil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilPage()),
                );
              } else if (value == 'ajustes') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              } else if (value == 'salir') {
                Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()), 
        (Route<dynamic> route) => false,
      );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: 'perfil',
                    child: Text(Translations.translate('viewProfile')),
                  ),
                  PopupMenuItem(
                    value: 'ajustes',
                    child: Text(Translations.translate('settings')),
                  ),
                  PopupMenuItem(
                    value: 'salir',
                    child: Text(Translations.translate('logout')),
                  ),
                ],
            icon: Icon(
              Icons.account_circle,
              size: 30,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "${Translations.translate('welcome')}, ${MyApp.loggedInUser?.firstName ?? ''} 👋",
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                Translations.translate('selectOption2Continue'),
                style: TextStyle(
                  fontSize: textSize,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  _buildOptionCard(
                    icon: Icons.person_add,
                    text: Translations.translate('registerNewUser'),
                    iconSize: iconSize,
                    textSize: textSize,
                    textColor: Theme.of(context).colorScheme.onSecondary,
                    onTap: () => _navigateTo(const RegistrationPage()),
                  ),
                  _buildOptionCard(
                    icon: Icons.people,
                    text: Translations.translate('viewRegistredUsers'),
                    iconSize: iconSize,
                    textSize: textSize,
                    textColor: Theme.of(context).colorScheme.onSecondary,
                    onTap: () => _navigateTo(const ViewUsersPage()),
                  ),
                  _buildOptionCard(
                    icon: Icons.event,
                    text: Translations.translate('viewAbences'),
                    iconSize: iconSize,
                    textSize: textSize,
                    textColor: Theme.of(context).colorScheme.onSecondary,
                    onTap: () => _navigateTo(const ProfesorMainMenuPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    double iconSize = (screenWidth * 0.03).clamp(
      24.0,
      40.0,
    ); // Tamaño entre 24px y 40px
    double textSize = (screenWidth * 0.015).clamp(
      14.0,
      20.0,
    ); // Tamaño entre 14px y 20px
    double titleSize = (screenWidth * 0.03).clamp(
      18.0,
      30.0,
    ); // Título de 18px a 30px

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                Translations.translate('adminMenu'),
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: Text(Translations.translate('viewProfile')),
              textColor: Theme.of(context).colorScheme.onPrimary,
              onTap: () => _onNavigationItemSelected(0),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: Text(Translations.translate('settings')),
              textColor: Theme.of(context).colorScheme.onPrimary,
              onTap: () => _onNavigationItemSelected(1),
            ),
            ListTile(
              leading: const Icon(Icons.view_list),
              title: Text(Translations.translate('logout')),
              textColor: Theme.of(context).colorScheme.onPrimary,
              onTap: () => _onNavigationItemSelected(2),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Contenedor para el NavigationRail con un encabezado
          Container(
            width:
                screenWidth *
                0.20, // El NavigationRail ocupa el 20% de la pantalla
            color: Theme.of(context).colorScheme.primary, // Fondo azul
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Encabezado con texto responsivo
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    Translations.translate('adminMenu'),
                    style: TextStyle(
                      fontSize: textSize, // 3% del ancho de la pantalla
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(
                  color: Colors.white54,
                  thickness: 1,
                ), // Línea separadora
                // NavigationRail
                Expanded(
                  child: NavigationRail(
                    minWidth: screenWidth * 0.15, // Ocupa el 20% de la pantalla
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onNavigationItemSelected,
                    labelType: NavigationRailLabelType.all,
                    selectedLabelTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    useIndicator: false,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.account_circle,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: iconSize,
                        ),
                        selectedIcon: Icon(
                          Icons.account_circle,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: iconSize,
                        ),
                        label: Text(
                          Translations.translate('viewProfile'),
                          style: TextStyle(fontSize: textSize),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.tune_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: iconSize,
                        ),
                        selectedIcon: Icon(
                          Icons.tune_rounded,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: iconSize,
                        ),
                        label: Text(
                          Translations.translate('settings'),
                          style: TextStyle(fontSize: textSize),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: iconSize,
                        ),
                        selectedIcon: Icon(
                          Icons.logout,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: iconSize,
                        ),
                        label: Text(
                          Translations.translate('logout'),
                          style: TextStyle(fontSize: textSize),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Center(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centra los elementos
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        "${Translations.translate('welcome')}, ${MyApp.loggedInUser?.firstName ?? ''} 👋",
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        Translations.translate('selectOption2Continue'),
                        style: TextStyle(
                          fontSize: textSize,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount:
                            screenWidth > 1000
                                ? 3
                                : 2, // 3 columnas en pantallas grandes, 2 en pequeñas
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        children: [
                          _buildOptionCard(
                            icon: Icons.person_add,
                            text: Translations.translate('registerNewUser'),
                            iconSize: iconSize,
                            textSize: textSize,
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onTap: () => _navigateTo(const RegistrationPage()),
                          ),
                          _buildOptionCard(
                            icon: Icons.people,
                            text: Translations.translate('viewRegistredUsers'),
                            iconSize: iconSize,
                            textSize: textSize,
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onTap: () => _navigateTo(const ViewUsersPage()),
                          ),
                          _buildOptionCard(
                            icon: Icons.event,
                            text: Translations.translate('viewAbences'),
                            iconSize: iconSize,
                            textSize: textSize,
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onTap:
                                () => _navigateTo(const ProfesorMainMenuPage()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Card estilizada para las opciones
  Widget _buildOptionCard({
    required IconData icon,
    required String text,
    required double iconSize,
    required double textSize,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 6,
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: textSize,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}