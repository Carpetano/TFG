// ignore_for_file: avoid_print

import 'dart:math';
import 'package:codigo/Objetos/user_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:codigo/supabase_manager.dart';

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
    List<UserObject> fetchedUsers = await SupabaseManager.instance.getAllUsers();
    setState(() {
      users = fetchedUsers;
      filteredUsers = fetchedUsers;
    });
  }

  void _filterUsers() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = users.where((user) {
        return user.firstName.toLowerCase().contains(query) ||
            user.lastName.toLowerCase().contains(query) ||
            user.role.toLowerCase().contains(query.replaceAll(' ', '_'));
      }).toList();
    });
  }

  void deactivateUser(UserObject user) async {
    print("Deactivating user: ${user.id}");
    SupabaseManager.instance.setUserAsInactive(user.id);
    fetchUsers();
  }

  void resetPassword(UserObject user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Resetear Contraseña"),
          content: Text(
            "¿Estás seguro de que quieres resetear la contraseña de ${user.firstName} ${user.lastName}?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                print("Contraseña reseteada para el usuario: ${user.id}");
              },
              child: const Text("Confirmar", style: TextStyle(color: Colors.red)),
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
        title: const Text("Usuarios Registrados"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
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
      body: filteredUsers.isEmpty
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
                    startActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) => resetPassword(user),
                          backgroundColor: Colors.orange,
                          icon: Icons.lock_reset,
                          label: 'Resetear',
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {}, // Implementar editar usuario
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          label: 'Editar',
                        ),
                        SlidableAction(
                          onPressed: (context) => deactivateUser(user),
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: 'Desactivar',
                        ),
                      ],
                    ),
                    //Pongo este comentario para probar
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        "${user.firstName} ${user.lastName}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Text(user.role.replaceAll("_", " ")),
                      trailing: user.status.toLowerCase() == 'activo'
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.cancel, color: Colors.red),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
