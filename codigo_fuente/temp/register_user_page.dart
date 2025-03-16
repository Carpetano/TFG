import 'package:flutter/material.dart';
import 'package:codigo/mysql_manager.dart';
import 'package:bcrypt/bcrypt.dart';

class RegistrationPage extends StatefulWidget {
  final MysqlManager dbManager;

  // Constructor
  const RegistrationPage({Key? key, required this.dbManager}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<RegistrationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Controllers for the text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _secondLastNameController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Move selectedRole outside of build to make it persist
  String? selectedRole = 'Profesor';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // This function will be called when the user selects a new item
  void onChanged(String? newValue) {
    setState(() {
      selectedRole = newValue;
    });
  }

  // Function to handle the registration and print the data
  void registerIntoDB() {
    // Get the text from the controllers
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String secondLastName = _secondLastNameController.text;
    String email = _emailController.text;
    String password = _passwordController.text;
    String hashedPassword = hashPassword(password);
    String phone = _phoneController.text;
    String selectedRoleText = selectedRole!.replaceAll(
      ' ',
      '_',
    ); // Convert spaces to underscores for DB

    // Print the data to the console
    print('First Name: $firstName');
    print('Last Name: $lastName');
    print('Second Last Name: $secondLastName');
    print('Email: $email');
    print('Password: $password');
    print('Hashed password: $hashedPassword');
    print('Phone: $phone');
    print('Selected Role: $selectedRoleText');

    // Finally insert into db
    widget.dbManager.registerUser(
      email: email,
      hashedPassword: hashedPassword,
      firstName: firstName,
      lastName: lastName,
      secondLastName: secondLastName,
      phone: phone,
      role: selectedRoleText,
      registrationDate: DateTime.now(),
    );
  }

  String hashPassword(String password) {
    const String fixedSalt =
        '\$2a\$10\$yVxztTQyA0dxldZfbx7TuOQ2akDZxKc6o7l0ns29kw.XJ2ykQyySO';
    return BCrypt.hashpw(password, fixedSalt);
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
          //
          //
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
          //
          //
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
          //
          //
          // PASSWORD TEXTFIELD
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: TextFormField(
                obscureText: true,
                controller: _passwordController, // Link controller
                decoration: InputDecoration(hintText: "Contraseña"),
              ),
            ),
          ),
          SizedBox(height: 30),
          //
          //
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
          SizedBox(height: 40),
          //
          //
          // ROLE DROPDOWN SELECTION
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: DropdownButton<String>(
                value: selectedRole, // Set the initial selected value
                items:
                    ["Administrador", "Profesor", "Sala de profesores"].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value), // Display each value as an option
                      );
                    }).toList(),
                onChanged:
                    onChanged, // Function to call when an option is selected
              ),
            ),
          ),
          SizedBox(height: 20),
          //
          //
          // REGISTER BUTTON
          Align(
            alignment: Alignment.center,
            child: Container(
              width: screenWidth * scalingFactor,
              child: ElevatedButton(
                onPressed: registerIntoDB,
                child: Text("Registrar"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
