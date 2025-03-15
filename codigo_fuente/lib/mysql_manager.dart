import 'dart:async';
import 'package:mysql1/mysql1.dart';

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

      var result = await conn.query(
        'INSERT INTO Usuarios (email, password_hash, nombre, apellido1, apellido2, rol, telefono, fecha_incorporacion) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
        [
          email,
          hashedPassword,
          firstName,
          lastName,
          secondLastName,
          role,
          phone,
          fechaUTC,
        ],
      );

      print("User registered successfully with ID: ${result.insertId}");
    } catch (e) {
      print('Error inserting data: $e');
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
