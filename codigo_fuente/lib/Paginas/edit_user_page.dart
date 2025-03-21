import 'package:flutter/material.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:codigo/supabase_manager.dart';

/// Page to edit details of an user
class EditUserPage extends StatefulWidget {
  // User object to modify data
  final UserObject user;

  // Constructor of the page
  const EditUserPage({super.key, required this.user});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  // Controllers to keep track of typed information
  final _formKey = GlobalKey<FormState>();
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    phoneController = TextEditingController(text: widget.user.phone);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Fetch and update users in the local list variables
  Future<void> updateUser() async {
    // Check if the formKey statis is valid
    if (_formKey.currentState!.validate()) {
      // Populate the fields with the data from the user
      UserObject updatedUser = widget.user.copyWith(
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        phone: phoneController.text,
      );

      // Store the result of updating the user
      bool success = await SupabaseManager.instance.updateUser(updatedUser);

      // If it was successfull go back, otherwise
      //    show a snackbar
      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al actualizar usuario")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Este campo no puede estar vacío"
                            : null,
              ),
              TextFormField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "Apellido"),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Este campo no puede estar vacío"
                            : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Teléfono"),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? "Este campo no puede estar vacío"
                            : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateUser,
                child: const Text("Guardar Cambios"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
