import 'dart:async';
import 'package:mysql1/mysql1.dart';
import 'package:codigo/user.dart';

class MysqlManager {
  late MySqlConnection conn;

  MysqlManager() {
    _initialiseManager();
  }

  Future<void> _initialiseManager() async {
    // Open a connection (test_db should already exist)
    conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        db: 'FCT_DB',
        password: '12345678',
      ),
    );
  }

  Future<void> registerUser({
    required String email,
    required String hashedPassword,
    required String firstName,
    required String lastName,
    required String secondLastName,
    required String role,
    required String phone,
    required DateTime registrationDate,
  }) async {
    try {
      // Check for null connections
      if (conn == null) {
        print("Error: DB connection is not initialized");
        return;
      }

      // Convert fechaIncorporacion to UTC if it's not null
      DateTime? fechaUTC = registrationDate?.toUtc();

      // Debugging: Print the hashed password
      // print("Hashed Password being inserted: $hashedPassword");

      const String query =
          'INSERT INTO Usuarios (email, password_hash, nombre, apellido1, apellido2, rol, telefono, fecha_incorporacion) VALUES (?, ?, ?, ?, ?, ?, ?, ?)';

      var result = await conn.query(query, [
        email,
        hashedPassword,
        firstName,
        lastName,
        secondLastName,
        role,
        phone,
        fechaUTC,
      ]);

      print("User registered successfully with ID: ${result.insertId}");
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<User?> login({
    required String email,
    required String hashedPassword,
  }) async {
    try {
      // Check for null connections
      if (conn == null) {
        print("Error: DB connection is not initialized");
        return null;
      }

      const String query =
          "SELECT nombre, apellido1, apellido2, rol, email FROM Usuarios WHERE email = ? AND password_hash = ?";

      var result = await conn.query(query, [email, hashedPassword]);

      // Check if any results were returned
      if (result.isEmpty) {
        // print("No user found with the provided credentials");
        return null;
      }

      // Assuming only one user should match the credentials
      var user = result.first;

      // Extract user details from the result
      String firstName = user['nombre'];
      String lastName = user['apellido1'];
      String secondLastName = user['apellido2'];
      String role = user['rol'];
      String userEmail = user['email'];

      // Return a User object if login is successful
      return User(
        firstName: firstName,
        lastName: lastName,
        secondLastName: secondLastName,
        role: role,
        email: userEmail,
      );
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  /// Method to insert a new record into the users table
  Future<void> insert(String name) async {
    try {
      // Ensure the connection is initialized before using it
      if (conn == null) {
        print("Database connection is not initialized.");
        return;
      }

      var result = await conn.query('INSERT INTO users (name) VALUES (?)', [
        name,
      ]);

      print('Inserted row id: ${result.insertId}');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<void> closeConnection() async {
    await conn.close();
  }
}
