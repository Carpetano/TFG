import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:codigo/edit_user_page.dart';
import 'package:codigo/edit_user_page_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:codigo/mysql_manager.dart';
import 'package:codigo/logged_in_user.dart';

class ViewUsers extends StatefulWidget {
  final MysqlManager dbManager;
  final LoggedInUser loggedAsUser;

  const ViewUsers({
    super.key,
    required this.dbManager,
    required this.loggedAsUser,
  });

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  List<LoggedInUser> users = [];
  List<LoggedInUser> filteredUsers = []; // This will hold the filtered list
  TextEditingController searchController =
      TextEditingController(); // Controller for search box

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(
      _filterUsers,
    ); // Listen to changes in the search box
  }

  Future<void> fetchUsers() async {
    List<LoggedInUser> fetchedUsers = await widget.dbManager.getAllUsers();
    setState(() {
      users = fetchedUsers;
      filteredUsers = fetchedUsers; // Initially show all users
    });
  }

  void _filterUsers() {
    // Get the search query
    String query = searchController.text.toLowerCase();

    // Filter the users based on the search query
    setState(() {
      filteredUsers =
          users
              .where(
                (user) =>
                    user.firstName.toLowerCase().contains(query) ||
                    user.lastName.toLowerCase().contains(query) ||
                    user.role.toLowerCase().contains(query),
              ) // Filter by first name, last name, or role
              // TODO Maybe search by id
              .toList();
    });
  }

  void showSnackBar(String message, Color textColor, Color bgColor) {
    var snackBar = SnackBar(
      content: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Text(message),
      ),
      backgroundColor: bgColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void deleteUser(LoggedInUser user) async {
    if (user.id == widget.loggedAsUser.id) {
      showSnackBar(
        "You are trying to delete yourself, don't do that!",
        Colors.white,
        Colors.black,
      );
    } else {
      await widget.dbManager.deleteUserById(user.id);
      fetchUsers();
    }
  }

  void editUser(LoggedInUser user) {
    if (user.id == widget.loggedAsUser.id) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditUserPagePassword(userToEdit: user),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditUserPage(userToEdit: user)),
      );
    }
  }

  String generateRandomPassword({int length = 10}) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final Random random = Random();

    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String hashPassword(String password) {
    return BCrypt.hashpw(password, MysqlManager.fixedSalt);
  }

  Future<void> resetPassword(LoggedInUser user) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: Text(
            "Are you sure you want to reset the password for ${user.firstName} ${user.lastName}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                String newPassword = generateRandomPassword();
                String newPasswordHashed = hashPassword(newPassword);

                final dbManager = await MysqlManager.getInstance();
                await dbManager.updateUserById(
                  user.id,
                  user,
                  newPasswordHashed,
                );

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("New Password"),
                      content: SelectableText(
                        "The new password for ${user.firstName} ${user.lastName} is:\n\n$newPassword",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Done"),
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text("Confirm", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menú Administrador"),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0), // Height of search box
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body:
          filteredUsers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  LoggedInUser user = filteredUsers[index];

                  return Slidable(
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => resetPassword(user),
                          backgroundColor: Colors.orange,
                          icon: Icons.lock_reset,
                          label: 'Reset Password',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => editUser(user),
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        SlidableAction(
                          onPressed: (context) => deleteUser(user),
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Delete',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text("${user.firstName} ${user.lastName}"),
                      subtitle: Text(user.role.replaceAll("_", " ")),
                    ),
                  );
                },
              ),
    );
  }
}
