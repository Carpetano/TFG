// Translated
import 'package:codigo/global_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/supabase_manager.dart';
import 'package:codigo/Paginas/edit_user_page.dart';
import 'package:codigo/Paginas/user_stats_page.dart';

class ViewUsersPage extends StatefulWidget {
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

  void deactivateUser(UserObject user) async {
    await SupabaseManager.instance.setUserAsInactive(user.id);
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(Translations.translate('registeredUsers'),style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
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
                fillColor: Theme.of(context).colorScheme.surface,
                prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
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
                    color: Theme.of(context).colorScheme.surface,
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
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          user.role.replaceAll("_", " "), 
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                        ),
                        trailing: Icon(
                          user.status.toLowerCase() == 'activo' ? Icons.check_circle : Icons.cancel,
                          color: user.status.toLowerCase() == 'activo'
                            ? Colors.green
                            : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}