import 'package:flutter/material.dart';
import 'package:codigo/supabase_manager.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> changePassword() async {
    if (_formKey.currentState!.validate()) {
      // Validación de cambio de contraseña
      bool success = await SupabaseManager.instance.changeUserPassword(newPasswordController.text);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Contraseña actualizada correctamente")),
        );
        Navigator.pop(context, true);  // Regresa a la página anterior con un valor 'true'
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al actualizar la contraseña. Intenta nuevamente.")),
        );
      }
    }
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cambiar Contraseña")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: newPasswordController,
                decoration: const InputDecoration(labelText: "Nueva Contraseña"),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Debe tener al menos 6 caracteres";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(labelText: "Confirmar Contraseña"),
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return "Las contraseñas no coinciden";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: changePassword,
                child: const Text("Actualizar Contraseña"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
