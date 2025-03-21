// Translated
import 'package:codigo/global_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:codigo/Paginas/edit_user_page.dart';
import 'package:codigo/Paginas/user_stats_page.dart';

/// Page to visualize all of the registered users, active or non active
class ViewUsersPage extends StatefulWidget {
  // Page constructor
  const ViewUsersPage({super.key});

  @override
  State<ViewUsersPage> createState() => _ViewUsersPageState();
}

class _ViewUsersPageState extends State<ViewUsersPage> {
  List<UserObject> users = [];
  List<UserObject> filteredUsers = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
    searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    List<UserObject> fetchedUsers =
        await SupabaseManager.instance.getAllUsers();
    setState(() {
      users = fetchedUsers;
      filteredUsers = fetchedUsers;
    });
  }

  void _filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers =
          users.where((user) {
            return user.firstName.toLowerCase().contains(query) ||
                user.lastName.toLowerCase().contains(query) ||
                user.role.toLowerCase().contains(query.replaceAll(' ', '_'));
          }).toList();
    });
  }

  /// Deactivate the parsed in user
  void deactivateUser(UserObject user) async {
    await SupabaseManager.instance.setUserAsInactive(user.id);
    fetchUsers(); // Update lists
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translations.translate('registeredUsers')),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: Translations.translate('lookUpUsers'),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          filteredUsers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  UserObject user = filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: Slidable(
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditUserPage(user: user),
                                ),
                              );
                            },
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: Translations.translate('edit'),
                          ),
                          SlidableAction(
                            onPressed: (context) => deactivateUser(user),
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: Translations.translate('deactivate'),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserStatsPage(user: user),
                              ),
                            );
                          },
                          child: Text(
                            "${user.firstName} ${user.lastName}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        subtitle: Text(user.role.replaceAll("_", " ")),
                        trailing:
                            user.status.toLowerCase() == 'activo'
                                ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                                : const Icon(Icons.cancel, color: Colors.red),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
