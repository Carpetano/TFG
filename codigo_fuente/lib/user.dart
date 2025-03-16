class User {
  final int id;
  final String role;

  final String firstName;
  final String lastName;
  final String secondLastName;

  final String phone;
  final String email;
  final DateTime registrationDate;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.secondLastName,
    required this.role,
    required this.email,
    required this.phone,
    required this.registrationDate,
  });

  // Convert a JSON map to a User object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'],
      firstName: json['nombre'],
      lastName: json['apellido1'],
      secondLastName: json['apellido2'],
      role: json['rol'],
      email: json['email'],
      phone: json['telefono'],
      registrationDate: DateTime.parse(json['fecha_incorporacion']),
    );
  }

  // Add a toString method for better readability
  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, secondLastName: $secondLastName, role: $role, email: $email, phone: $phone, registrationDate: $registrationDate)';
  }
}
