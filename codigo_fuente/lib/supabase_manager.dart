// ignore_for_file: avoid_print

import 'package:codigo/Objetos/Guardia_object.dart';
import 'package:codigo/Objetos/aula_object.dart';
import 'package:codigo/Objetos/ausencia_object.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Class in charge of performing actions against the supabase database,utilize the initialize method once
/// then access it statically using .instance to share the same instance across the entire app
class SupabaseManager {
  // Static Supabase object
  static final SupabaseManager _instance = SupabaseManager._();
  // Static supabse client accesible from other classes
  static SupabaseClient? _client;

  // Private constructor to prevent direct instantiation
  SupabaseManager._();

  // Public static method to access the instance
  static SupabaseManager get instance => _instance;

  /// Initialize Supabase client
  Future<void> initialize() async {
    if (_client == null) {
      // Initialize Supabase
      await Supabase.initialize(
        url: 'https://gykqibexlzwxpliezelo.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5a3FpYmV4bHp3eHBsaWV6ZWxvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDE5MDUzMDEsImV4cCI6MjA1NzQ4MTMwMX0.MRfnjfhl5A7ZbK_ien8G1OPUmlF-3eqzOmx_EFTQHZk',
        debug: true,
      );
    }
  }

  /// Attempt to log-in into Supabase with the provided email and password
  ///
  /// If the login fails or an error occurs, it will return null
  ///
  /// - [email]: The user's email address for login
  /// - [password]: The user's password for login
  ///
  /// Returns: A UserObject if login is successful, null otherwise
  Future<UserObject?> login(String email, String password) async {
    try {
      // Attempt to sign in with Supabase using the provided email and password
      final AuthResponse response = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      // Check if the response contains a valid user object
      if (response.user != null) {
        // If user is valid, map the Supabase user to the custom UserObject
        return await mapUser(response.user!);
      }

      // If user is null, log a debug message and return null
      print("[DEBUG]: Login failed, user is null");
      return null;
    } catch (e) {
      // If an error occurs during login, log the error for debugging purposes
      print("[DEBUG]: Error during login: $e");
      return null;
    }
  }

  /// Register function to create a new user and return a LoggedInUser object
  ///
  /// If registration fails or an error occurs, it returns null
  ///
  /// - [email]: The user's email address for registration
  /// - [password]: The user's password for registration
  /// - [name]: The user's first name
  /// - [lastName]: The user's last name
  /// - [secondLastName]: The user's second last name
  /// - [phone]: The user's phone number
  ///
  /// Returns: A UserObject if registration is successful, null otherwise
  Future<UserObject?> register(
    String email,
    String password,
    String name,
    String lastName,
    String secondLastName,
    String phone,
  ) async {
    try {
      // Attempt to sign up the user with Supabase using the provided email and password
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      // Check if the response contains a valid user object
      if (response.user != null) {
        // Log a debug message indicating that the registration email was sent
        print("[DEBUG]: Registration mail Sent to: $email");

        // Retrieve user details
        final userId = response.user!.id;
        final userEmail = response.user!.email;

        // Insert the user's data into the 'usuarios' table in Supabase
        final insertResponse =
            await Supabase.instance.client
                .from('usuarios')
                .insert({
                  'id_auth': userId,
                  'rol': 'Sala_de_Profesores', // Default role
                  'estado': 'Inactivo', // Default status
                  'nombre': name, // NULL values allowed
                  'apellido1': lastName,
                  'apellido2': secondLastName,
                  'telefono': phone,
                  'email': userEmail,
                })
                .select()
                .single();

        // Check if the user data was inserted successfully
        if (insertResponse.isEmpty) {
          // Log a debug message if no data was inserted into the 'usuarios' table
          print("[DEBUG]: No data inserted into 'usuarios'");
          return null;
        }

        // Log the inserted user data for debugging purposes
        print("[DEBUG]:  User inserted into 'usuarios': $insertResponse");

        // Return the mapped UserObject if the registration was successful
        return await mapUser(response.user!);
      }

      // If user is null, log a debug message indicating registration failure
      print("[DEBUG]: Error: Registration failed, user is null");
      return null;
    } catch (e) {
      // If an error occurs during registration, log the error for debugging purposes
      print("[DEBUG]: Error during registration: $e");
      return null;
    }
  }

  /// Maps Supabase User to LoggedInUser object
  ///
  /// This function fetches additional user details from the 'usuarios' table using the user ID,
  /// then maps it to a custom UserObject with the necessary fields
  ///
  /// - [user]: The Supabase User object to map
  ///
  /// Returns: A UserObject with user details, or null if an error occurs
  Future<UserObject?> mapUser(User user) async {
    try {
      // Fetch user details from the 'usuarios' table based on the user ID
      final response =
          await Supabase.instance.client
              .from('usuarios')
              .select()
              .eq('id_auth', user.id)
              .single();

      // Return the mapped UserObject
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
      // Log error if mapping fails
      print("[DEBUG]:  Error mapping user: $e");
      return null;
    }
  }

  /// Sets a user as inactive in the 'usuarios' table
  ///
  /// This function updates the 'estado' field of the user to 'Inactivo' based on the user ID
  /// If an error occurs or the user update fails, an exception is thrown
  ///
  /// - [userId]: The ID of the user to update
  Future<void> setUserAsInactive(int userId) async {
    try {
      // Update the 'estado' field to 'Inactivo' for the specified user
      final response = await Supabase.instance.client
          .from('usuarios')
          .update({'estado': 'Inactivo'}) // Update the 'estado' field
          .eq('id_usuario', userId); // Apply filter to select the specific user

      // Check if there's an error or if the response data is empty
      if (response.error != null ||
          response.data == null ||
          response.data.isEmpty) {
        print(
          " Error marking user as inactive: ${response.error?.message ?? 'Unknown error'}",
        );
        throw Exception("Error marking user as inactive");
      }

      // Log success if user is marked as inactive
      print("[DEBUG]: User MARKED AS INACTIVE successfully: $userId");
    } catch (e) {
      // Log error if update fails
      print("[DEBUG]:  Error during user update: $e");
      throw Exception("Error marking user as inactive");
    }
    print("[DEBUG]: Salta una exception, pero lo cambia sin problemas");
  }

  /// Retrieves all users from the 'usuarios' table
  ///
  /// This function fetches all users from the 'usuarios' table and maps them to a list of UserObject
  /// If an error occurs or no users are found, an empty list is returned.
  ///
  /// Returns: A list of UserObject containing all users
  Future<List<UserObject>> getAllUsers() async {
    try {
      // Fetch all users from the 'usuarios' table
      final response = await Supabase.instance.client.from('usuarios').select();

      // Check if the response is empty
      if ((response.isEmpty)) {
        print("[DEBUG]: No users found in the 'usuarios' table");
        return []; // Return an empty list if no data is found
      }

      // Map each entry in the response list to a UserObject
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
                  registrationDate:
                      DateTime.tryParse(userData['created_at'] ?? '') ??
                      DateTime.now(),
                ),
              )
              .toList();

      // Return the list of UserObject
      return users;
    } catch (e) {
      // Log error if fetching users fails
      print("[DEBUG]:  Error fetching users: $e");
      return []; // Return empty list if an error occurs
    }
  }

  /// TODO COMMENT
  Future<AusenciaObject?> insertAusencia(
    int missingTeacherId,
    String classCode,
  ) async {
    try {
      // Execute the insert and retrieve the inserted data, including 'id_ausencia', 'profesor_ausente', and 'aula'
      final response = await Supabase.instance.client
          .from('ausencias')
          .insert({'profesor_ausente': missingTeacherId, 'aula': classCode})
          .select(
            'id_ausencia, profesor_ausente, aula',
          ); // Select the fields you need

      // Print the response for debugging
      print(response);

      // If data exists in the response, map it to an AusenciaObject
      if (response.isNotEmpty) {
        final data =
            response[0]; // Since it's an insert, we expect only one row
        return AusenciaObject.fromMap(data);
      } else {
        print("No data returned after insertion.");
        return null;
      }
    } catch (e) {
      // Log any error that occurs during the insertion process
      print("Error inserting ausencia: $e");
      return null;
    }
  }

  /// Retrieves all active users from the 'usuarios' table
  ///
  /// This function fetches all active users from the 'usuarios' table, based on the 'estado' field
  /// The status field is checked using a case-insensitive match for 'activo'
  ///
  /// Returns: A list of active UserObject
  Future<List<UserObject>> getActiveUsers() async {
    try {
      // Fetch active users from the 'usuarios' table
      final response = await Supabase.instance.client
          .from('usuarios')
          .select()
          .ilike('estado', 'activo'); // Case-insensitive match

      // Debugging: Print raw response for inspection
      print("[DEBUG]: Raw Supabase Response: $response");

      // Check if response is empty
      if (response.isEmpty) {
        print("[DEBUG]: No active users found");
        return [];
      }

      // Map the response to a list of UserObject
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
      // Log error if fetching active users fails
      print("[DEBUG]: Error getting active users: $e");
      return [];
    }
  }

  /// Retrieves all aulas (classrooms) from the 'aulas' table
  ///
  /// This function fetches all classrooms from the 'aulas' table and maps them to a list of AulaObject
  ///
  /// Returns: A list of AulaObject representing all classrooms
  Future<List<AulaObject>> getAllAulas() async {
    try {
      // Fetch all classrooms from the 'aulas' table
      final response = await Supabase.instance.client.from('aulas').select();

      // Map the response to a list of AulaObject
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
      // Log error if fetching aulas fails
      print("[DEBUG]: Error getting aulas: $e");
      return [];
    }
  }

  /// Retrieves all unassigned ausencias with a pending status
  ///
  /// This function fetches all unassigned absence records from the 'ausencias' table where the status is 'Pendiente'
  /// It maps the fetched data to a list of AusenciaObject
  ///
  /// Returns: A list of AusenciaObject representing unassigned absences
  Future<List<AusenciaObject>> getAllUnasignedAusencias() async {
    try {
      // Fetch all unassigned absences from the 'ausencias' table
      final response = await Supabase.instance.client
          .from('ausencias')
          .select()
          .like('estado', 'Pendiente'); // Filter for pending ausencias

      // Map the response to a list of AusenciaObject
      List<AusenciaObject> ausencias =
          (response as List).map((ausenciaData) {
            return AusenciaObject(
              id: ausenciaData['id_ausencia'] ?? 0,
              missingTeacherId: ausenciaData['profesor_ausente'] ?? 0,
              classCode: ausenciaData['aula'] ?? '',
            );
          }).toList();

      return ausencias;
    } catch (e) {
      // Log error if fetching unassigned absences fails
      print("[DEBUG]: Error getting all unassigned ausencias: $e");
      return []; // Return empty list in case of error
    }
  }

  /// Retrieves a UserObject by its ID from the 'usuarios' table
  ///
  /// This function fetches user details based on the provided user ID and maps it to a UserObject
  ///
  /// - [id]: The ID of the user to fetch
  ///
  /// Returns: A UserObject representing the user
  Future<UserObject> getUserObjectById(int id) async {
    try {
      // Fetch user data from the 'usuarios' table based on user ID
      final response =
          await Supabase.instance.client
              .from('usuarios')
              .select()
              .eq('id_usuario', id)
              .single(); // This assumes that the query returns a single result

      // Map the response to a UserObject
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
    } catch (e) {
      // Log error if fetching user object fails
      print("[DEBUG]: Error getting user object: $e");
      rethrow; // Re-throw the exception so you can handle it higher up
    }
  }

  Future<List<GuardiaObject>> getAllUnasignedGuardias() async {
    final response = await Supabase.instance.client
        .from('guardias')
        .select()
        .like('estado', 'pendiente');

    print("RESPONSE: $response");

    if (response == null || response.isEmpty) {
      return [];
    }

    return response
        .map(
          (data) => GuardiaObject(
            id: data['id_guardia'],
            missingTeacherId: data['id_profesor_ausente'],
            ausenciaId: data['id_ausencia'],
            tramoHorario: data['tramo_horario'],
            substituteTeacherId: data['id_profesor_sustituto'] ?? 0,
            observations: data['observaciones'] ?? '',
            status: data['estado'],
          ),
        )
        .toList();
  }
}
