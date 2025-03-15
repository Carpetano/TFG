import 'package:codigo/edit_user_page.dart';
import 'package:codigo/edit_user_page_password.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:codigo/mysql_manager.dart';
import 'package:codigo/user.dart';

class ViewUsers extends StatefulWidget {
  final MysqlManager dbManager;
  final User loggedAsUser;

  const ViewUsers({
    super.key,
    required this.dbManager,
    required this.loggedAsUser,
  });

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    List<User> fetchedUsers = await widget.dbManager.getAllUsers();
    setState(() {
      users = fetchedUsers;
    });
  }

  void showSnackBar(String message, Color textColor, Color bgColor) {
    // TODO, maybe add so you can give a formatted text, so it has diff colors
    var snackBar = SnackBar(
      content: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: Text(message),
      ),
      backgroundColor: bgColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void deleteUser(User user) async {
    // Check he is not deleting himself, that would be weird
    if (user.id == widget.loggedAsUser.id) {
      showSnackBar(
        "You are trying to delete yourself, don't do that!",
        Colors.white,
        Colors.black,
      );
    } else {
      await widget.dbManager.deleteUserById(user.id);
      fetchUsers(); // Refresh list after deletion
    }
  }

  void editUser(User user) {
    print("Editing: $user");
    // Check if user is editing himself to navigate to the page with password
    if (user.id == widget.loggedAsUser.id) {
      print("pass");
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

  void resetPassword(User user) {
    print("Reset password for user: $user");
    print("Not implemented yet");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menú Administrador")),
      body:
          users.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  User user = users[index];

                  return Slidable(
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(), // Animation style
                      children: [
                        // Reset Password Button
                        SlidableAction(
                          onPressed: (context) => resetPassword(user),
                          backgroundColor:
                              Colors
                                  .orange, // You can change the color as needed
                          icon: Icons.lock_reset,
                          label: 'Reset Password',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(), // Animation style
                      children: [
                        // Edit Button
                        SlidableAction(
                          onPressed: (context) => editUser(user),
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'Edit',
                        ),
                        // Delete Button
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
