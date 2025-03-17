class UserObject {
  final int id;
  final String authId;
  final String role;

  final String firstName;
  final String lastName;
  final String secondLastName;

  final String phone;
  final String email;
  final DateTime registrationDate;
  final String status;

  UserObject({
    required this.id,
    required this.authId,
    required this.firstName,
    required this.lastName,
    required this.secondLastName,
    required this.role,
    required this.email,
    required this.phone,
    required this.registrationDate,
    required this.status,
  });

  // Add a toString method for better readability
  @override
  String toString() {
    return 'User(id: $id, firstName: $firstName, lastName: $lastName, secondLastName: $secondLastName, role: $role, email: $email, phone: $phone, registrationDate: $registrationDate, auth_id: $authId)';
  }
}
