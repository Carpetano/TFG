import 'package:codigo/logged_in_user.dart';
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
  Future<LoggedInUser?> login(String email, String password) async {
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
  Future<LoggedInUser?> register(String email, String password) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
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
                  'nombre': null, // NULL values allowed
                  'apellido1': null,
                  'apellido2': null,
                  'telefono': null,
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
  Future<LoggedInUser?> mapUser(User user) async {
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

      return LoggedInUser(
        id: response['id_usuario'],
        authId: user.id,
        firstName: response['nombre'] ?? '',
        lastName: response['apellido1'] ?? '',
        secondLastName: response['apellido2'] ?? '',
        role: response['rol'] ?? 'Inactivo',
        email: response['email'] ?? user.email ?? '',
        phone: response['telefono'] ?? '',
        registrationDate: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );
    } catch (e) {
      print("❌ Error mapping user: $e");
      return null;
    }
  }
}
