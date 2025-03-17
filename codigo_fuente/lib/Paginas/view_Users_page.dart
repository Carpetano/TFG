// ignore_for_file: avoid_print

import 'dart:math';

import 'package:codigo/Objetos/user_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:codigo/supabase_manager.dart'; // Adjust the import path as needed

class ViewUsersPage extends StatefulWidget {
  const ViewUsersPage({super.key});

  @override
  State<ViewUsersPage> createState() => _ViewUsersPageState();
}

class _ViewUsersPageState extends State<ViewUsersPage> {
  // List of all users fetched from Supabase
  List<UserObject> users = [];
  // List of users that match the current search query
  List<UserObject> filteredUsers = [];
  // Controller for the search text field
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch the users when the widget is initialized
    fetchUsers();
    // Listen for changes in the search box to update the filtered list
    searchController.addListener(_filterUsers);
  }

  // Dispose the controller when the widget is disposed to free resources
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Fetch all users from the Supabase 'usuarios' table.
  Future<void> fetchUsers() async {
    // Retrieve the list of users using the SupabaseManager
    List<UserObject> fetchedUsers =
        await SupabaseManager.instance.getAllUsers();
    // Update both the full users list and the filtered list
    setState(() {
      users = fetchedUsers;
      filteredUsers = fetchedUsers;
    });
  }

  /// Filter users based on the search query.
  void _filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers =
          users.where((user) {
            // Filter by first name, last name, or role (ignoring case)
            return user.firstName.toLowerCase().contains(query) ||
                user.lastName.toLowerCase().contains(query) ||
                user.role.toLowerCase().contains(query.replaceAll(' ', '_'));
          }).toList();
    });
  }

  /// Function to generate a random password
  String generateRandomPassword({int length = 10}) {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*';
    final Random random = Random();

    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
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

  /// Deletes the user and re-fetches the list of users after deletion.
  void deactivateUser(UserObject user) async {
    print("Deactivating user: ${user.id}");
    SupabaseManager.instance.setUserAsInactive(user.id);
  }

  /// Navigate to the appropriate edit page based on the user.
  void editUser(UserObject user) {
    // If you need to differentiate the edit page based on the current user, adjust here.
  }

  /// Display a confirmation dialog to reset the user's password
  void resetPassword(UserObject user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Password"),
          content: Text(
            "Are you sure you want to reset the password for ${user.firstName} ${user.lastName}?",
          ),
          actions: [
            // Cancel button to dismiss the dialog
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            // Confirm button to trigger password reset
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog

                print("Reset password for user: ${user.id}");
              },
              child: const Text("Confirm", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Build the main UI including the search bar and the list of slidable users.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Usuarios Registrados"),
        // Add a search bar below the app bar title
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      // If no users are found, show a progress indicator; otherwise, display the list
      body:
          filteredUsers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  UserObject user = filteredUsers[index];
                  // Each user item is wrapped in a Slidable widget for slide actions
                  return Slidable(
                    // Action pane when swiped from the start (left)
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
                    // Action pane when swiped from the end (right)
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
                          onPressed: (context) => deactivateUser(user),
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Desactivar',
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(
                        "${user.firstName} ${user.lastName} ${user.status.toLowerCase() == 'activo' ? "" : "[INACTIVO]"}",
                      ),
                      subtitle: Text(user.role.replaceAll("_", " ")),
                    ),
                  );
                },
              ),
    );
  }
}
