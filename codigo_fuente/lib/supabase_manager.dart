// ignore_for_file: avoid_print

import 'package:codigo/user_object.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseManager {
  static final SupabaseManager _instance = SupabaseManager._();
  static SupabaseClient? _client;

  // Private constructor to prevent direct instantiation
  SupabaseManager._();

  // Public static method to access the instance
  static SupabaseManager get instance => _instance;

  // Initialize Supabase client with secure storage
  Future<void> initialize() async {
    if (_client == null) {
      // Initialize Supabase
      await Supabase.initialize(
        url: 'https://gykqibexlzwxpliezelo.supabase.co', // Your Supabase URL
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5a3FpYmV4bHp3eHBsaWV6ZWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MDUzMDEsImV4cCI6MjA1NzQ4MTMwMX0.MRfnjfhl5A7ZbK_ien8G1OPUmlF-3eqzOmx_EFTQHZk', // Your Supabase Anon Key
        debug: true,
      );
    }
  }

  // Login function - Now returns a LoggedInUser
  Future<UserObject?> login(String email, String password) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        return await mapUser(response.user!);
      }

      print("❌ Error: Login failed, user is null.");
      return null;
    } catch (e) {
      print("❌ Error during login: $e");
      return null;
    }
  }

  // Register function - Now returns a LoggedInUser
  Future<UserObject?> register(
    String email,
    String password,
    String name,
    String lastName,
    String secondLastName,
    String phone,
  ) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        print("Registration mail Sent to: $email");

        final userId = response.user!.id;
        final userEmail = response.user!.email;

        // Insert user data into 'usuarios' table
        final insertResponse =
            await Supabase.instance.client
                .from('usuarios')
                .insert({
                  'id_auth': userId,
                  'rol': 'Sala_de_Profesores',
                  'estado': 'Inactivo',
                  'nombre': name, // NULL values allowed
                  'apellido1': lastName,
                  'apellido2': secondLastName,
                  'telefono': phone,
                  'email': userEmail,
                })
                .select()
                .single();

        if (insertResponse.isEmpty) {
          print("❌ Error: No data inserted into 'usuarios'.");
          return null;
        }

        print("✅ User inserted into 'usuarios': $insertResponse");

        return await mapUser(response.user!);
      }

      print("❌ Error: Registration failed, user is null.");
      return null;
    } catch (e) {
      print("❌ Error during registration: $e");
      return null;
    }
  }

  // Map Supabase User to LoggedInUser
  Future<UserObject?> mapUser(User user) async {
    try {
      final response =
          await Supabase.instance.client
              .from('usuarios')
              .select()
              .eq('id_auth', user.id)
              .single();

      if (response == null) {
        print("❌ Error: No profile found for user ${user.id}");
        return null;
      }

      return UserObject(
        id: response['id_usuario'],
        authId: user.id,
        firstName: response['nombre'] ?? '',
        lastName: response['apellido1'] ?? '',
        secondLastName: response['apellido2'] ?? '',
        role: response['rol'] ?? 'Inactivo',
        email: response['email'] ?? user.email ?? '',
        phone: response['telefono'] ?? '',
        registrationDate: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        status: response['estado'],
      );
    } catch (e) {
      print("❌ Error mapping user: $e");
      return null;
    }
  }

  Future<void> setUserAsInactive(int userId) async {
    try {
      final response = await Supabase.instance.client
          .from('usuarios')
          .update({'estado': 'Inactivo'}) // Update the 'estado' field
          .eq('id_usuario', userId); // Apply filter to select the specific user

      // Check if there's an error or if the response data is empty
      if (response.error != null ||
          response.data == null ||
          response.data.isEmpty) {
        print(
          "❌ Error marking user as inactive: ${response.error?.message ?? 'Unknown error'}",
        );
        throw Exception("Error marking user as inactive");
      }

      print("✅ User MARKED AS INACTIVE successfully: $userId");
    } catch (e) {
      print("❌ Error during user update: $e");
      throw Exception("Error marking user as inactive");
    }
    print("Salta una exception, pero lo cambia sin problemas");
  }

  Future<List<UserObject>> getAllUsers() async {
    try {
      // Fetch all users from the 'usuarios' table.
      // The call returns a PostgrestList (essentially a List) directly.
      final response = await Supabase.instance.client.from('usuarios').select();

      // Check if the response is null or empty.
      if (response == null || (response is List && response.isEmpty)) {
        print("❌ No users found in the 'usuarios' table.");
        return []; // Return an empty list if no data is found.
      }

      // Map each entry in the response list to a LoggedInUser object.
      List<UserObject> users =
          (response as List)
              .map(
                (userData) => UserObject(
                  id: userData['id_usuario'],
                  authId: userData['id_auth'],
                  firstName: userData['nombre'] ?? '',
                  lastName: userData['apellido1'] ?? '',
                  secondLastName: userData['apellido2'] ?? '',
                  role: userData['rol'] ?? 'Inactivo',
                  email: userData['email'] ?? '',
                  phone: userData['telefono'] ?? '',
                  status: userData['estado'],
                  // Parse the registration date from the 'created_at' field,
                  // fallback to current time if parsing fails.
                  registrationDate:
                      DateTime.tryParse(userData['created_at'] ?? '') ??
                      DateTime.now(),
                ),
              )
              .toList();

      // Return the list of LoggedInUser objects.
      return users;
    } catch (e) {
      // If an error occurs during the query, log the error and return an empty list.
      print("❌ Error fetching users: $e");
      return [];
    }
  }
}
