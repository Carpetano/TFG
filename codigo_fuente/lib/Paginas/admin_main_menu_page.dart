import 'package:codigo/global_settings.dart';
import 'package:flutter/material.dart';
import 'package:codigo/Paginas/profesor_main_menu_page.dart';
import 'package:codigo/Paginas/register_user_page.dart';
import 'package:codigo/Paginas/view_users_page.dart';
import 'package:codigo/Paginas/perfil_page.dart';
import 'package:codigo/Paginas/settings_page.dart';
import 'package:codigo/main.dart';

/// Admin main menu page, this page should allow the allowed users to perform almost anything
class AdminMainMenuPage extends StatefulWidget {
  // Page constructor
  const AdminMainMenuPage({super.key});

  @override
  State<AdminMainMenuPage> createState() => _AdminMainMenuPageState();
}

class _AdminMainMenuPageState extends State<AdminMainMenuPage> {
  int _selectedIndex = 0;

  /// Navigate to a page given an index
  ///
  /// - [index] index of the page to navigate to
  ///     1 - Profile page
  ///     2 - Settings page
  ///     3 - Main menu
  void _onNavigationItemSelected(int index) {
    // Set this inner class attribute as the parsed in argument
    setState(() => _selectedIndex = index);

    // Depending on the parsed in index, navigate to the corresponding page
    if (index == 0) {
      Navigator.push(
        context, // Navigate to the profile page
        MaterialPageRoute(builder: (context) => const PerfilPage()),
      );
    } else if (index == 1) {
      Navigator.push(
        context, // Navigate to the settings page
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    } else if (index == 2) {
      Navigator.push(
        context, // Navigate to the Main menu
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    // Whats the threshold to determine whether to build a desktop or mobile layout
    final maxPhoneWidth = 600;

    // Return a scaffold depending on the current screen size
    return Scaffold(
      body:
          // If screen size is greater than 600 build a desktop layout, otherwise build a mobile layout
          screenWidth > maxPhoneWidth
              ? buildDesktopLayout(screenWidth, screenHeight)
              : buildMobileLayout(screenWidth),
    );
  }

  /// Build a thinner screen, associated to mobile devices
  ///
  /// - [screenWidth] Current screen width for responsive design
  Widget buildMobileLayout(double screenWidth) {
    // Calculate the icon/Text/Tile size given the screen width
    double iconSize = (screenWidth * 0.04).clamp(30.0, 50.0);
    double textSize = (screenWidth * 0.02).clamp(20.0, 40.0);
    double titleSize = (screenWidth * 0.04).clamp(30.0, 50.0);

    // Return a scaffold containing the mobile layout
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'perfil') {
                // Navigate to the profile page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilPage()),
                );
              } else if (value == 'ajustes') {
                // Navigate to the settings page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              } else if (value == 'salir') {
                // Log out or go to the main menu
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  // Profile translation dependingon the displaly language
                  PopupMenuItem(
                    value: 'perfil',
                    child: Text(Translations.translate('viewProfile')),
                  ),
                  // Settings translation depending on the display language
                  PopupMenuItem(
                    value: 'ajustes',
                    child: Text(Translations.translate('settings')),
                  ),
                  // Log out translation depening on the display language
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
          const SizedBox(width: 10), // Add some spacing to remove cluttering
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              // Title text
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
              // Subtitle text
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

  /// Build a desktop or 'wide' layout
  ///
  /// - [screenWidth] Current screen width for responsive design
  /// - [screenHeight] Current scren Height for responsive design
  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    // Calculate the icon/Text/Tile size given the screen width
    double iconSize = (screenWidth * 0.03).clamp(24.0, 40.0);
    double textSize = (screenWidth * 0.015).clamp(14.0, 20.0);
    double titleSize = (screenWidth * 0.03).clamp(18.0, 30.0);

    // Return a scaffold containing a wide / desktop layout
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
          Container(
            // Calculate the width of the container depending on the screen width
            width: screenWidth * 0.20,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    Translations.translate('adminMenu'),
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Spacing
                const Divider(color: Colors.white54, thickness: 1),
                Expanded(
                  child: NavigationRail(
                    minWidth: screenWidth * 0.15,
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
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        crossAxisCount: screenWidth > 1000 ? 3 : 2,
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

  /// Get a card given the following attributes:
  ///
  /// - [icon] Icon to display
  /// - [text] Text to display
  /// - [iconSize] Size of the display icon
  /// - [textSize] Size of the display text
  /// - [onTap] Which function to perform when tapped
  /// - [textColor] color of the display color
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
        color: Theme.of(context).colorScheme.secondary,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).colorScheme.onPrimary,
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
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Navigate to the parsed in page
  ///
  /// - [page] Page to navigate to
  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
