// Define the Enum for roles
enum Role { Admin, Profesor, SalaDeProfesores }

// User class to store user details
class User {
  String name;
  String lastName;
  String secondLastName;
  Role role; // Role as an Enum
  String phone;
  String email;

  // Constructor
  User({
    required this.name,
    required this.lastName,
    required this.secondLastName,
    required this.role,
    required this.phone,
    required this.email,
  });

  // Method to check if the user is an Admin
  bool get isAdmin => role == Role.Admin;

  // Method to check if the user is a Profesor
  bool get isProfesor => role == Role.Profesor;

  // Method to check if the user has access to Sala de Profesores
  bool get isSalaDeProfesores => role == Role.SalaDeProfesores;

  // Optional: Override the toString method to display user information nicely
  @override
  String toString() {
    return 'User: $name $lastName $secondLastName, Role: $role, Email: $email';
  }
}
