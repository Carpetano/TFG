import 'dart:async';
import 'package:mysql1/mysql1.dart';
import 'package:codigo/user.dart';

class MysqlManager {
  late MySqlConnection conn;

  static MysqlManager? _instance; // Private static variable

  // Private constructor to prevent direct instantiation
  MysqlManager._();

  // Public static method to access the instance
  static Future<MysqlManager> getInstance() async {
    if (_instance == null) {
      _instance = MysqlManager._();
      await _instance!._initialiseManager();
    } else {
      // Optionally, attempt a simple query to verify connection
      try {
        await _instance!.conn.query("SELECT 1");
      } catch (e) {
        print(
          "Connection appears closed or invalid. Reinitializing. Error: $e",
        );
        await _instance!._initialiseManager();
      }
    }
    return _instance!;
  }

  // Initialize the connection (called only once when required)
  Future<void> _initialiseManager() async {
    conn = await MySqlConnection.connect(
      ConnectionSettings(
        host: 'localhost',
        port: 3306,
        user: 'root',
        db: 'FCT_DB',
        password: '12345678',
      ),
    );
    print("MySQL Connection established.");
  }

  // Method to register a user
  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String secondLastName,
    required String email,
    required String hashedPassword,
    required String phone,
    required String role,
    required DateTime registrationDate,
  }) async {
    try {
      const String query = """
      INSERT INTO Usuarios (rol, nombre, apellido1, apellido2, telefono, fecha_incorporacion, email, password_hash)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """;

      var result = await conn.query(query, [
        role,
        firstName,
        lastName,
        secondLastName,
        phone,
        registrationDate.toIso8601String(),
        email,
        hashedPassword,
      ]);

      print("User inserted with id: ${result.insertId}");
    } catch (e) {
      print("Error inserting data: $e");
    }
  }

  Future<User?> login({
    required String email,
    required String hashedPassword,
  }) async {
    try {
      // Ensure connection is established before querying
      await getInstance();

      const String query =
          "SELECT id_usuario, nombre, apellido1, apellido2, rol, email, telefono, fecha_incorporacion FROM Usuarios WHERE email = ? AND password_hash = ?";

      var result = await conn.query(query, [email, hashedPassword]);

      // Check if any results were returned
      if (result.isEmpty) {
        return null;
      }

      var user = result.first;
      return User(
        id: user['id_usuario'],
        firstName: user['nombre'],
        lastName: user['apellido1'],
        secondLastName: user['apellido2'],
        role: user['rol'],
        email: user['email'],
        phone: user['telefono'],
        registrationDate: user['fecha_incorporacion'],
      );
    } catch (e) {
      print('Error logging in: $e');
      return null;
    }
  }

  // Insert method to add a new record into the users table
  Future<void> insert(String name) async {
    try {
      await getInstance(); // Ensure connection is initialized before use

      var result = await conn.query('INSERT INTO users (name) VALUES (?)', [
        name,
      ]);

      print('Inserted row id: ${result.insertId}');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  // Method to get all users
  Future<List<User>> getAllUsers() async {
    List<User> users = [];

    try {
      await getInstance(); // Ensure the connection is initialized

      const String query =
          "SELECT id_usuario, nombre, apellido1, apellido2, rol, email, telefono, fecha_incorporacion FROM Usuarios";
      var results = await conn.query(query);

      for (var row in results) {
        users.add(
          User(
            id: row['id_usuario'],
            firstName: row['nombre'],
            lastName: row['apellido1'],
            secondLastName: row['apellido2'],
            role: row['rol'],
            email: row['email'],
            phone: row['telefono'],
            registrationDate: row['fecha_incorporacion'],
          ),
        );
      }
    } catch (e) {
      print("Error fetching users: $e");
    }

    return users;
  }

  // Fetch user by id
  Future<User?> getUserById(int id) async {
    try {
      await getInstance(); // Ensure connection is initialized

      const String query =
          "SELECT id_usuario, nombre, apellido1, apellido2, rol, email, telefono, fecha_incorporacion FROM Usuarios WHERE id_usuario = ?";

      var result = await conn.query(query, [id]);

      // If no user found, return null
      if (result.isEmpty) {
        print("No user found with id: $id");
        return null;
      }

      var user = result.first;

      return User(
        id: user['id_usuario'],
        firstName: user['nombre'],
        lastName: user['apellido1'],
        secondLastName: user['apellido2'],
        role: user['rol'],
        email: user['email'],
        phone: user['telefono'],
        registrationDate: user['fecha_incorporacion'],
      );
    } catch (e) {
      print("Error getting user with id: $id, : $e");
      return null;
    }
  }

  // Update user details by id (including password, which is mandatory)
  Future<bool> updateUserById(
    int id,
    User updatedUser,
    String hashedPassword,
  ) async {
    try {
      await getInstance(); // Ensure connection is initialized

      // Query to update user details, including the password
      const String query = '''
    UPDATE Usuarios
    SET nombre = ?, apellido1 = ?, apellido2 = ?, rol = ?, email = ?, telefono = ?, password_hash = ?
    WHERE id_usuario = ?
    ''';

      // Pass all necessary parameters to the query, including the hashed password
      var result = await conn.query(query, [
        updatedUser.firstName,
        updatedUser.lastName,
        updatedUser.secondLastName,
        updatedUser.role,
        updatedUser.email,
        updatedUser.phone,
        hashedPassword, // Include hashed password here
        id, // The user id for the record we are updating
      ]);

      if (result.affectedRows == 1) {
        print("User with id: $id updated successfully.");
        return true;
      } else {
        print("User with id: $id was not updated.");
        return false;
      }
    } catch (e) {
      print("Error updating user with id: $id, : $e");
      return false;
    }
  }

  Future<bool> updateUserByIdWithoutPassword(int id, User updatedUser) async {
    try {
      if (conn == null) {
        print("Error: DB connection is not initialized.");
        return false;
      }

      // Query to update user details by id (excluding password)
      const String query = '''
    UPDATE Usuarios
    SET nombre = ?, apellido1 = ?, apellido2 = ?, rol = ?, email = ?, telefono = ?,
    WHERE id_usuario = ?
  ''';

      var result = await conn.query(query, [
        updatedUser.firstName,
        updatedUser.lastName,
        updatedUser.secondLastName,
        updatedUser.role,
        updatedUser.email,
        updatedUser.phone,
        id, // The user id for the record we are updating
      ]);

      if (result.affectedRows == 1) {
        print("User with id: $id updated successfully.");
        return true;
      } else {
        print("User with id: $id was not updated.");
        return false;
      }
    } catch (e) {
      print("Error updating user with id: $id, : $e");
      return false;
    }
  }

  // Method to delete user by id
  Future<void> deleteUserById(int id) async {
    try {
      await getInstance(); // Ensure connection is initialized

      const String query = "DELETE FROM Usuarios WHERE id_usuario = ?";

      var result = await conn.query(query, [id]);

      print("Deleted user with id: $id");
    } catch (e) {
      print("Error deleting user with id: $id, : $e");
    }
  }

  // Close the database connection
  Future<void> closeConnection() async {
    await conn.close();
  }
}
