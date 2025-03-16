import 'package:codigo/logged_in_user.dart';
import 'package:flutter/material.dart';
import 'package:codigo/register_user_page.dart';
import 'package:codigo/mysql_manager.dart';
import 'package:codigo/view_Users_page.dart';

class AdminMenu extends StatefulWidget {
  final MysqlManager dbManager;
  final LoggedInUser loggedAsUser;

  // Constructor
  const AdminMenu({
    Key? key,
    required this.dbManager,
    required this.loggedAsUser,
  }) : super(key: key);

  @override
  State<AdminMenu> createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu>
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

  void goToRegistrationPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => RegistrationPage(
              dbManager: widget.dbManager,
            ), // Access dbManager from widget
      ),
    );
  }

  void goToViewUsersPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ViewUsers(
              dbManager: widget.dbManager,
              loggedAsUser: widget.loggedAsUser,
            ), // Access dbManager from widget
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    final scalingFactor = 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text("Menú Administrador"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        mainAxisAlignment:
            MainAxisAlignment.center, // Centers content vertically
        children: [
          //
          //
          // GO TO USER REGISTRATION PAGE
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centers items in row
            children: [
              ElevatedButton(
                onPressed: goToRegistrationPage,
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
                onPressed: goToViewUsersPage,
                child: Text('Ver Usuarios'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
