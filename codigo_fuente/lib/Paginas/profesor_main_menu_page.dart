// ignore_for_file: avoid_print

import 'package:codigo/Objetos/guardia_object.dart';
import 'package:codigo/Paginas/view_guardias_page.dart';
import 'package:codigo/global_settings.dart';
import 'package:codigo/main.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:codigo/Paginas/add_ausencia_page.dart';
import 'package:codigo/Paginas/view_my_guardias_page.dart';
import 'package:codigo/Paginas/perfil_page.dart';
import 'package:codigo/Paginas/settings_page.dart';
import 'package:codigo/Paginas/register_user_page.dart';

/// Main menu page for those users which role is 'Profesor'
class ProfesorMainMenuPage extends StatefulWidget {
  // Page constructor
  const ProfesorMainMenuPage({super.key});

  @override
  _ProfesorMainMenuPageState createState() => _ProfesorMainMenuPageState();
}

class _ProfesorMainMenuPageState extends State<ProfesorMainMenuPage>
    with RouteAware {
  // Calendar widget for the user to interact
  final CalendarFormat _calendarFormat = CalendarFormat.month;

  // Keep track on which day is selected
  DateTime? _selectedDay;

  // Keep track on what day we live
  DateTime _focusedDay = DateTime.now();

  // List of unasigned guardia objects to show notifications
  List<GuardiaObject> unasignedGuardias = [];

  // Keep track on which calendar day index is selected
  int _selectedIndex = 0;

  /// Navigate to a page given it's index:
  ///
  /// - [index] page index to navigate:
  ///     0 -> Profile page
  ///     1 -> Settings page
  ///     2 -> Main menu page
  void _onNavigationItemSelected(int index) {
    // Change this inner class selected index
    setState(() => _selectedIndex = index);

    // Depending on the index navigate to one page or another
    if (index == 0) {
      // Goto profile page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerfilPage()),
      );
    } else if (index == 1) {
      // Goto settings page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      );
    } else if (index == 2) {
      // Goto main menu page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUnasignedGuardias();
  }

  @override
  void didPopNext() {
    /*
      SUPPOSEDLY this should when navigating back from other pages, but I can't get this page to refresh
    */
    fetchUnasignedGuardias();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Fetch and assign to the local list the retreived list of unassigned guardias in supabase
  Future<void> fetchUnasignedGuardias() async {
    // Fetch from supabase those unasigned supervisions
    final response = await SupabaseManager.instance.getUnasignedGuardias();
    // print(response);

    // Assign the value to the local list
    setState(() {
      unasignedGuardias = response;
    });

    // Show a message depending on the amount of unasigned supervisions
    if (unasignedGuardias.isNotEmpty) {
      showSnackBar(
        "${Translations.translate('unasignedGuardiasSnackBar')} ${unasignedGuardias.length}",
        Colors.white,
        Colors.black,
      );
    } else {
      showSnackBar(
        Translations.translate('noUnasignedGuardiasSnackBar'),
        Colors.white,
        Colors.black,
      );
    }
  }

  /// Displays a snackbar message at the bottom of the screen
  ///
  /// This function creates a snackbar with the provided message, text color,
  /// and background color, then displays it using the ScaffoldMessenger
  ///
  /// - [message]: The text content of the snackbar
  /// - [textColor]: The color of the text inside the snackbar
  /// - [bgColor]: The background color of the snackbar
  void showSnackBar(String message, Color textColor, Color bgColor) {
    // Create a Snack BAr given the parameters
    var snackBar = SnackBar(
      content: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Text(message),
      ),
      backgroundColor: bgColor,
    );
    // Show the snack bar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Make this a synchronous function to be compatible with eventLoader
  List<GuardiaObject> _getEventsForDay(DateTime day) {
    // Filter guardias that match the selected day and are unassigned (status "pendiente")
    return unasignedGuardias.where((guardia) {
      // Convert status to lowercase for case-insensitive comparison
      return isSameDay(guardia.day, day) &&
          guardia.status.toLowerCase() == 'pendiente'; // NO TRANSLATE
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    // Determine the threshold on where a screen is considered phone or desktop
    final maxPhoneWidth = 600;

    // Return the scaffold containing the layout
    return Scaffold(
      body:
          // Depengin on the screen width return either desktop or mobile layout
          screenWidth > maxPhoneWidth
              ? buildDesktopLayout(screenWidth, screenHeight)
              : buildMobileLayout(screenWidth),
    );
  }

  /// Return a scaffold containing the mobile layout
  ///
  /// - [screenWidth] screen width to calculate responseive design
  Widget buildMobileLayout(double screenWidth) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${Translations.translate('professor')}: ${MyApp.loggedInUser?.firstName ?? 'Desconocido'}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'perfil') {
                // NO TRANSLATE
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PerfilPage()),
                ).then((_) {
                  setState(() {
                    fetchUnasignedGuardias();
                  });
                });
              } else if (value == 'ajustes') {
                // NO TRANSLATE
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ).then((_) {
                  setState(() {
                    fetchUnasignedGuardias();
                  });
                });
              } else if (value == 'salir') {
                // NO TRANSLATE
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegistrationPage(),
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: 'perfil',
                    child: Text(Translations.translate('profile')),
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
            icon: const Icon(
              Icons.account_circle,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate:
                (day) => _selectedDay != null && isSameDay(_selectedDay, day),
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                if (_selectedDay != null &&
                    isSameDay(_selectedDay, selectedDay)) {
                  _selectedDay = null;
                } else {
                  _selectedDay = selectedDay;
                  // Get events for the selected day
                  List<GuardiaObject> events = _getEventsForDay(selectedDay);
                  if (events.isNotEmpty) {
                    print(
                      "Selected date has ${events.length} unassigned guardias.",
                    );
                  }
                }
                _focusedDay = focusedDay;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            headerStyle: HeaderStyle(
              titleTextStyle: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                fontSize: 18,
              ),
            ),
            calendarStyle: CalendarStyle(
              defaultTextStyle: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
              ),
              weekendTextStyle: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.orangeAccent
                        : Colors.red,
              ),
              outsideTextStyle: TextStyle(
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.black38,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VerMisGuardiasPage(),
                      ),
                    ).then((_) {
                      setState(() {
                        fetchUnasignedGuardias();
                      });
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(150, 50),
                  ),
                  child: Builder(
                    builder: (context) {
                      String languageCode = GlobalSettings.language.value.code;
                      print(
                        'Language Code: $languageCode',
                      ); // Check the current language code
                      print("Test???");
                      return Text(Translations.translate('viewMySupervisions'));
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      _selectedDay != null
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        AddAusenciaPage(day: _selectedDay!),
                              ),
                            ).then((_) {
                              setState(() {
                                fetchUnasignedGuardias();
                              });
                            });
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedDay != null
                            ? Colors.blueAccent
                            : Colors.grey[400],
                    foregroundColor:
                        _selectedDay != null ? Colors.black : Colors.grey[600],
                    minimumSize: const Size(150, 50),
                  ),
                  child: Text(Translations.translate('addAusencia')),
                ),
                ElevatedButton(
                  onPressed:
                      _selectedDay != null
                          ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ViewGuardiasPage(day: _selectedDay!),
                              ),
                            ).then((_) {
                              setState(() {
                                fetchUnasignedGuardias();
                              });
                            });
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedDay != null
                            ? Colors.blueAccent
                            : Colors.grey[400],
                    foregroundColor:
                        _selectedDay != null ? Colors.black : Colors.grey[600],
                    minimumSize: const Size(150, 50),
                  ),
                  child: Text(Translations.translate('viewGuardias')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Return a scaffold containing the layout for desktop or wide screens
  Widget buildDesktopLayout(double screenWidth, double screenHeight) {
    // Calculate the icon / Text size
    double iconSize = (screenWidth * 0.03).clamp(24.0, 40.0);
    double textSize = (screenWidth * 0.015).clamp(14.0, 20.0);

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
              leading: Icon(
                Icons.assignment,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              title: Text(
                'Ver perfil',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onTap: () => _onNavigationItemSelected(0),
            ),
            ListTile(
              leading: Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              title: Text(
                Translations.translate('settings'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onTap: () => _onNavigationItemSelected(1),
            ),
            ListTile(
              leading: Icon(
                Icons.view_list,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              title: Text(
                Translations.translate('logout'),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              onTap: () => _onNavigationItemSelected(2),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          Container(
            width: screenWidth * 0.20,
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    Translations.translate('professorMenu'),
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(color: Colors.white54, thickness: 1),
                Expanded(
                  child: NavigationRail(
                    minWidth: screenWidth * 0.15,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onNavigationItemSelected,
                    labelType: NavigationRailLabelType.all,
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.account_circle,
                          size: iconSize,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        selectedIcon: Icon(
                          Icons.account_circle,
                          size: iconSize,
                          color: Colors.white,
                        ),
                        label: Text(
                          Translations.translate('viewProfile'),
                          style: TextStyle(
                            fontSize: textSize,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.tune_rounded,
                          size: iconSize,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        selectedIcon: Icon(
                          Icons.tune_rounded,
                          size: iconSize,
                          color: Colors.white,
                        ),
                        label: Text(
                          Translations.translate('settings'),
                          style: TextStyle(
                            fontSize: textSize,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.logout,
                          size: iconSize,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        selectedIcon: Icon(
                          Icons.logout,
                          size: iconSize,
                          color: Colors.white,
                        ),
                        label: Text(
                          Translations.translate('logout'),
                          style: TextStyle(
                            fontSize: textSize,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
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
                  children: [
                    TableCalendar(
                      firstDay: DateTime.utc(2000, 1, 1),
                      lastDay: DateTime.utc(2100, 12, 31),
                      focusedDay: _focusedDay,
                      calendarFormat: _calendarFormat,
                      selectedDayPredicate:
                          (day) =>
                              _selectedDay != null &&
                              isSameDay(_selectedDay, day),
                      eventLoader: _getEventsForDay,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay =
                              _selectedDay != null &&
                                      isSameDay(_selectedDay, selectedDay)
                                  ? null
                                  : selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerMisGuardiasPage(),
                              ),
                            ).then((_) {
                              setState(() {
                                fetchUnasignedGuardias();
                              });
                            });
                          },
                          child: Text(
                            Translations.translate('viewMySupervisions'),
                          ),
                        ),
                        ElevatedButton(
                          onPressed:
                              _selectedDay != null
                                  ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => AddAusenciaPage(
                                              day: _selectedDay!,
                                            ),
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        fetchUnasignedGuardias();
                                      });
                                    });
                                  }
                                  : null,
                          child: Text(Translations.translate('addAusencia')),
                        ),
                        ElevatedButton(
                          onPressed:
                              _selectedDay != null
                                  ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ViewGuardiasPage(
                                              day: _selectedDay!,
                                            ),
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        fetchUnasignedGuardias();
                                      });
                                    });
                                  }
                                  : null,
                          child: Text(Translations.translate('viewGuardias')),
                        ),
                      ],
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
}
