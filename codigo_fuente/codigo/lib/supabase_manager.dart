// supabase_manager.dart
import 'package:supabase_flutter/supabase_flutter.dart';

// SupabaseManager class in charge of interacting with supabase
//
// A supabase manager object must be created and use the .login / .register methods to interact easily with supabase
class SupabaseManager {
  // Supabase client instance
  final _client = Supabase.instance.client;

  // Perform a login request given an email and password
  //
  // Returns the supabase response if successfull, returns null otherwise
  Future<User?> login(String email, String password) async {
    // If there's any errors during login it will throw an exception
    try {
      // Send a login request with the parsed in email and password
      final AuthResponse response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Return the response, if it reached this point it's very likely it was successful
      return response.user;
    } catch (e) {
      // Print through the console the caught exception for debugging purposes
      print('Login error: $e');
      return null;
    }
  }

  // Register method
  //
  // Returns the supabase response if successfull, returns null otherwise
  Future<User?> register(String email, String password) async {
    try {
      // Register the user in Supabase Auth.
      final AuthResponse response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id; // The auth system's UUID.
        final userEmail = response.user!.email;
        final passwordHash = '12345678'; // Replace with real hash logic.

        // Get the last id_usuario from the Usuarios table.
        final selectResponse =
            await _client
                .from('Usuarios')
                .select('id_usuario')
                .order('id_usuario', ascending: false)
                .limit(1)
                .maybeSingle();

        if (selectResponse.error != null) {
          print(
            'Error fetching last id_usuario: ${selectResponse.error?.message}',
          );
          return null;
        }

        int newUserId = 1; // Default id_usuario value if table is empty.
        final lastRecord = selectResponse.data;
        if (lastRecord != null &&
            lastRecord is Map &&
            lastRecord['id_usuario'] != null) {
          newUserId = (lastRecord['id_usuario'] as int) + 1;
        }

        // Insert the new user into the Usuarios table.
        final insertResponse = await _client.from('Usuarios').insert([
          {
            'id_usuario': newUserId,
            'estado': 'inactivo',
            'hash_contrasenia': passwordHash,
            'creado_en': 'now()', // SQL function for current timestamp.
            'mail': userEmail,
            'id_auth': userId,
          },
        ]);

        if (insertResponse.error != null) {
          print(
            'Error inserting into Usuarios table: ${insertResponse.error?.message}',
          );
          return null;
        }
      }

      return response.user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }
}
