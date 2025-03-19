import 'package:codigo/supabase_manager.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  // Controladores de los campos de entrada
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _secondLastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? selectedRole = 'Profesor';

  void registerIntoDB() {
  String firstName = _firstNameController.text;
  String lastName = _lastNameController.text;
  String secondLastName = _secondLastNameController.text;
  String email = _emailController.text;
  String password = _passwordController.text;
  String phone = _phoneController.text;
  String selectedRoleText = selectedRole!.replaceAll(' ', '_');

  SupabaseManager.instance.register(
    email,
    password,
    firstName,
    lastName,
    secondLastName,
    phone,
    selectedRoleText,
  );
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWideScreen = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Usuario"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Crear una Cuenta",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Campos de nombre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTextField(_firstNameController, "Nombre", width: isWideScreen ? screenWidth * 0.28 : null),
                      _buildTextField(_lastNameController, "Primer Apellido", width: isWideScreen ? screenWidth * 0.28 : null),
                      _buildTextField(_secondLastNameController, "Segundo Apellido", width: isWideScreen ? screenWidth * 0.28 : null),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Correo
                  _buildTextField(_emailController, "Correo Electrónico"),
                  const SizedBox(height: 10),

                  // Contraseña
                  _buildTextField(_passwordController, "Contraseña", isPassword: true),
                  const SizedBox(height: 10),

                  // Teléfono
                  _buildTextField(_phoneController, "Teléfono"),
                  const SizedBox(height: 20),

                  // Selección de rol
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<String>(
                      value: selectedRole,
                      isExpanded: true,
                      underline: const SizedBox(),
                      onChanged: (newValue) => setState(() => selectedRole = newValue),
                      items: ["Administrador", "Profesor", "Sala de profesores"]
                          .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Botón de registro
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: registerIntoDB,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Registrar", style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false, double? width}) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}