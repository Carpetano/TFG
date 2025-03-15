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

  // Add a toString method for better readability
  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, secondLastName: $secondLastName, role: $role, email: $email, phone: $phone, registrationDate: $registrationDate)';
  }
}
