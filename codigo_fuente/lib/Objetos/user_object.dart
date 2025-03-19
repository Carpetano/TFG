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

  // Factory constructor to create a UserObject from a map
  factory UserObject.fromMap(Map<String, dynamic> data) {
    return UserObject(
      id: data['id'] as int,
      authId: data['auth_id'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      secondLastName: data['second_last_name'] as String,
      role: data['role'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      registrationDate: DateTime.parse(data['registration_date'] as String),
      status: data['status'] as String,
    );
  }

  // Static method to map a list of response data into a list of UserObject instances
  static List<UserObject> mapFromResponse(List<dynamic>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }
    // Map each entry in the response list to a UserObject using the fromMap factory constructor
    return response.map((data) => UserObject.fromMap(data)).toList();
  }

  // Add a toString method for better readability
  @override
  String toString() {
    return 'UserObject(id: $id, firstName: $firstName, lastName: $lastName, secondLastName: $secondLastName, role: $role, email: $email, phone: $phone, registrationDate: $registrationDate, authId: $authId, status: $status)';
  }
}
