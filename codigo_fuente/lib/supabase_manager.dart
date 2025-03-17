// ignore_for_file: avoid_print

import 'package:codigo/aula_object.dart';
import 'package:codigo/ausencia_object.dart';
import 'package:codigo/user_object.dart';
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

  Future<void> insertAusencia(
    int missingTeacherId,
    String classCode,
    String status,
    String task,
    DateTime horaInicio, // Change to DateTime
    DateTime horaFin, // Change to DateTime
  ) async {
    try {
      final response = await Supabase.instance.client.from('ausencias').insert({
        'profesor_ausente': missingTeacherId,
        'aula': classCode,
        'tarea': task,
        'estado': status,
        'hora_inicio':
            horaInicio.toIso8601String(), // Convert DateTime to string
        'hora_fin': horaFin.toIso8601String(), // Convert DateTime to string
      });

      print("Inserted Ausencia: $response");
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<List<UserObject>> getActiveUsers() async {
    try {
      // Fetch data from Supabase
      final response = await Supabase.instance.client
          .from('usuarios')
          .select()
          .ilike('estado', 'activo'); // Case-insensitive match

      // Debugging: Print raw response
      print("Raw Supabase Response: $response");

      // Check if response is empty
      if (response == null || response.isEmpty) {
        print("No active users found.");
        return [];
      }

      // Map response to UserObject list
      List<UserObject> users =
          response.map<UserObject>((userData) {
            return UserObject(
              id: userData['id_usuario'],
              authId: userData['id_auth'],
              firstName: userData['nombre'] ?? '',
              lastName: userData['apellido1'] ?? '',
              secondLastName: userData['apellido2'] ?? '',
              role: userData['rol'] ?? 'Inactivo',
              email: userData['email'] ?? '',
              phone: userData['telefono'] ?? '',
              status: userData['estado'],
              registrationDate:
                  DateTime.tryParse(userData['created_at'] ?? '') ??
                  DateTime.now(),
            );
          }).toList();

      return users;
    } catch (e) {
      print("Error getting active users: $e");
      return [];
    }
  }

  Future<List<AulaObject>> getAllAulas() async {
    try {
      final response = await Supabase.instance.client.from('aulas').select();

      List<AulaObject> aulas =
          (response as List)
              .map(
                (aulaData) => AulaObject(
                  classcode: aulaData['cod_aula'] ?? '',
                  floor: aulaData['planta'] ?? '',
                  wing: aulaData['ala'] ?? '',
                  group: aulaData['grupo'] ?? '',
                ),
              )
              .toList();

      return aulas;
    } catch (e) {
      print("Error getting aulas: $e");
      return [];
    }
  }

  Future<List<AusenciaObject>> getAllUnasignedAusencias() async {
    try {
      final response = await Supabase.instance.client
          .from('ausencias')
          .select()
          .like('estado', 'Pendiente'); // Execute the query

      List<AusenciaObject> ausencias =
          (response as List)
              .map(
                (ausenciaData) => AusenciaObject(
                  id: ausenciaData['id_ausencia'] ?? 0, // id
                  missingTeacherId:
                      ausenciaData['profesor_ausente'] ?? 0, // profesor_ausente
                  classCode: ausenciaData['aula'] ?? '', // aula
                  tasks: ausenciaData['tarea'] ?? '', // tarea
                  status: ausenciaData['estado'] ?? '', // estado
                ),
              )
              .toList();

      return ausencias;
    } catch (e) {
      print("Error getting all unassigned ausencias: $e");
      return []; // Return empty list in case of exception
    }
  }

  Future<UserObject> getUserObjectById(int id) async {
    try {
      final response =
          await Supabase.instance.client
              .from('usuarios')
              .select()
              .eq('id_usuario', id)
              .single(); // This assumes that the query returns a single result

      // Check if response is not null and map it to UserObject
      if (response != null) {
        return UserObject(
          id: response['id_usuario'] ?? 0,
          authId: response['auth_id'] ?? '',
          role: response['role'] ?? '',
          firstName: response['primer_nombre'] ?? '',
          lastName: response['apellido_paterno'] ?? '',
          secondLastName: response['apellido_materno'] ?? '',
          phone: response['telefono'] ?? '',
          email: response['email'] ?? '',
          registrationDate: DateTime.parse(
            response['fecha_registro'] ?? '2000-01-01',
          ),
          status: response['estado'] ?? '',
        );
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      print("Error getting user object: $e");
      rethrow; // Re-throw the exception so you can handle it higher up
    }
  }
}
