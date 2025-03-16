import 'package:flutter/material.dart';
import 'package:codigo/mysql_manager.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:codigo/user.dart';

class EditUserPagePassword extends StatefulWidget {
  final User userToEdit;

  const EditUserPagePassword({Key? key, required this.userToEdit})
    : super(key: key);

  @override
  State<EditUserPagePassword> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<EditUserPagePassword>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Controllers for the text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _secondLastNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController(); // New controller for password

  // Move selectedRole outside of build to make it persist
  String? selectedRole = 'Profesor';

  @override
  void initState() {
    super.initState();

    // Initialize the controllers with data from the userToEdit object
    _firstNameController.text = widget.userToEdit.firstName;
    _lastNameController.text = widget.userToEdit.lastName;
    _secondLastNameController.text = widget.userToEdit.secondLastName;
    _emailController.text = widget.userToEdit.email;
    _phoneController.text = widget.userToEdit.phone; // Auto-fill phone here

    // Set the selected role dropdown to the user's current role
    selectedRole = widget.userToEdit.role.replaceAll(
      '_',
      ' ',
    ); // Adjust the format for consistency
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // This function will be called when the user selects a new item
  void onChanged(String? newValue) {
    setState(() {
      selectedRole = newValue?.replaceAll(
        ' ',
        '_',
      ); // Match the DB format (e.g., Sala_de_Profesores)
    });
  }

  Future<void> editUserById() async {
    // Get the text from the controllers
    int id = widget.userToEdit.id;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String secondLastName = _secondLastNameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text; // Get the password text
    String selectedRoleText = selectedRole!.replaceAll(
      ' ',
      '_',
    ); // Format role text for DB

    // Initialize hashedPassword as a nullable string
    String? hashedPassword;

    // If password is provided, hash it
    if (password.isNotEmpty) {
      hashedPassword = BCrypt.hashpw(
        password,
        "\$2a\$10\$yVxztTQyA0dxldZfbx7TuOQ2akDZxKc6o7l0ns29kw.XJ2ykQyySO",
      );
    }

    // Print the data to the console for debugging
    print('First Name: $firstName');
    print('Last Name: $lastName');
    print('Second Last Name: $secondLastName');
    print('Email: $email');
    print('Phone: $phone');
    print('Password: $hashedPassword');
    print('Selected Role: $selectedRoleText');

    // Create the updated User object
    final updatedUser = User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      secondLastName: secondLastName,
      email: email,
      phone: phone,
      role: selectedRoleText,
      registrationDate: DateTime.now(), // not needed
    );

    // Get the MysqlManager instance (this returns a Future, so we need to await it)
    final dbManager = await MysqlManager.getInstance();

    // If password is provided, update with password
    if (hashedPassword != null) {
      // If password was provided, update with password
      await dbManager.updateUserById(id, updatedUser, hashedPassword);
    } else {
      // If password is empty, just update the other fields (excluding password)
      await dbManager.updateUserByIdWithoutPassword(id, updatedUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    final scalingFactor = 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar usuario"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center vertically
        children: [
          // FULL NAME FIELDS
          Align(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // First TextFormField for 'Nombre'
                Container(
                  width: screenWidth * 0.25,
                  child: TextFormField(
                    controller: _firstNameController, // Link controller
                    decoration: InputDecoration(hintText: "Nombre"),
                  ),
                ),
                SizedBox(width: 8), // Spacer
                // Second TextFormField for 'Primer apellido'
                Container(
                  width: screenWidth * 0.25,
                  child: TextFormField(
                    controller: _lastNameController, // Link controller
                    decoration: InputDecoration(hintText: "Primer apellido"),
                  ),
                ),
                SizedBox(width: 8), // Spacer
                // Third TextFormField for 'Segundo apellido'
                Container(
                  width: screenWidth * 0.25,
                  child: TextFormField(
                    controller: _secondLastNameController, // Link controller
                    decoration: InputDecoration(hintText: "Segundo apellido"),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // EMAIL TEXTFIELD
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: TextFormField(
                controller: _emailController, // Link controller
                decoration: InputDecoration(hintText: "Correo"),
              ),
            ),
          ),
          SizedBox(height: 10),
          // PHONE TEXTFIELD
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: TextFormField(
                controller: _phoneController, // Link controller
                decoration: InputDecoration(hintText: "Teléfono"),
              ),
            ),
          ),
          SizedBox(height: 10),
          // PASSWORD TEXTFIELD
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: TextFormField(
                controller: _passwordController, // Link controller
                decoration: InputDecoration(hintText: "Nueva contraseña"),
                obscureText: true, // Hide password input
              ),
            ),
          ),
          SizedBox(height: 40),
          // ROLE DROPDOWN SELECTION
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: DropdownButton<String>(
                value: selectedRole, // This is the currently selected role
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue!;
                  });
                },
                items:
                    [
                      'Sala de Profesores',
                      'Administrador',
                      'Profesor',
                    ].map<DropdownMenuItem<String>>((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
              ),
            ),
          ),
          SizedBox(height: 40),
          // REGISTER BUTTON
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: ElevatedButton(
                onPressed: editUserById,
                child: Text("Registrar"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
