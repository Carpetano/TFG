// ignore_for_file: avoid_print

import 'package:codigo/Objetos/guardia_object.dart'; // Correct the file name here
import 'package:codigo/Objetos/aula_object.dart';
import 'package:codigo/Objetos/ausencia_object.dart';
import 'package:codigo/Objetos/user_object.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Class in charge of performing actions against the supabase database,utilize the initialize method once (the core of everything)
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
      /*

====================================================================================== SE QUE ESTO ES MUUUUUUUUUUUY MALA PRACTICA =================================================================================================================================================================================================================================================================================================================
        
        QUE LAS CREDENCIALES NO SE GUARDAN EN TEXTO PLANO, SINO EN UNA VARIABLE DE ENTORNO

      */
      // Initialize Supabase with it's matching url and anonkey
      await Supabase.initialize(
        url: 'xxxxx',
        anonKey:
            'xxxxx',
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

  /// Upload a profile picture to supabase
  ///
  /// - [imageFile] Image to upload
  /// - [userId] user id to tie the image to
  Future<String?> uploadProfilePicture(XFile imageFile, String userId) async {
    try {
      // Define the path for the user image
      final storagePath = 'avatars/$userId.png';

      // Convert the image to a compatible format
      Uint8List fileBytes;
      // Web uses bytes while android and ios use File
      if (kIsWeb) {
        fileBytes = await imageFile.readAsBytes();
      } else {
        fileBytes = await File(imageFile.path).readAsBytes();
      }

      // Upload image to supabase
      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(
            storagePath,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Retreive the public url of the image
      final publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(storagePath);

      // Upade the url in the table's column
      await Supabase.instance.client
          .from('usuarios')
          .update({'profile_image_url': publicUrl})
          .eq('id_auth', userId);

      // Return the public url
      return publicUrl;
    } catch (e) {
      print("Error al subir la imagen: $e");
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
    String role, // 🔹 Agregado para recibir el rol seleccionado
  ) async {
    try {
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final userId = response.user!.id;

        final insertResponse =
            await Supabase.instance.client
                .from('usuarios')
                .insert({
                  'id_auth': userId,
                  'rol': role, // 🔹 Guardamos el rol correctamente
                  'estado': 'Inactivo',
                  'nombre': name,
                  'apellido1': lastName,
                  'apellido2': secondLastName,
                  'telefono': phone,
                  'email': email,
                })
                .select()
                .single();

        if (insertResponse.isEmpty) {
          print("[DEBUG]: No se insertó el usuario");
          return null;
        }

        return await mapUser(response.user!);
      }

      print("[DEBUG]: Error: Registro fallido, usuario es null");
      return null;
    } catch (e) {
      print("[DEBUG]: Error al registrar usuario: $e");
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

      // If the response is empty or null, return null
      if (response.isEmpty) {
        return null;
      }

      // Use the fromMap constructor to map the response into a UserObject
      return UserObject.fromMap({
        'id': response['id_usuario'],
        'auth_id': user.id,
        'first_name': response['nombre'] ?? '',
        'last_name': response['apellido1'] ?? '',
        'second_last_name': response['apellido2'] ?? '',
        'role': response['rol'] ?? 'Inactivo',
        'email': response['email'] ?? user.email ?? '',
        'phone': response['telefono'] ?? '',
        'registration_date':
            user.createdAt, // Assuming createdAt is a valid string
        'status': response['estado'],
        'profile_image_url': response['profile_image_url'],
      });
    } catch (e) {
      // Log error if mapping fails
      print("[DEBUG]:  Error mapping user: $e");
      return null;
    }
  }

  Future<UserObject?> getCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    return await instance.mapUser(user);
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

  /// Insert an ausencia
  ///
  /// - [missingTeacherId] id of the missing teacher
  /// - [classCode] Code of the class where the ausencia is taking place
  /// - [day] which day
  Future<AusenciaObject?> insertAusencia(
    int missingTeacherId,
    String classCode,
    DateTime day,
  ) async {
    try {
      // Perform le insert
      final response =
          await Supabase.instance.client
              .from('ausencias')
              .insert({'profesor_ausente': missingTeacherId, 'aula': classCode})
              .select('id_ausencia, profesor_ausente, aula')
              .single();

      print("---- Inserted Ausencia Response: $response");

      // Map the response to AusenciaObject
      return AusenciaObject(
        id: response['id_ausencia'],
        missingTeacherId: response['profesor_ausente'],
        classCode: response['aula'],
      );
    } catch (e) {
      print("Error inserting ausencia: $e");
      return null;
    }
  }

  /// Insert a list of guardias
  ///
  /// - [guardiasToInsert] list of guardias to insert
  Future<void> insertGuardias(List<GuardiaObject> guardiasToInsert) async {
    try {
      // List of responses, like a Stringbuilder
      List fullResponse = [];

      for (var guardia in guardiasToInsert) {
        final response = await Supabase.instance.client.from('guardias').insert(
          {
            'id_profesor_ausente': guardia.missingTeacherId,
            'id_ausencia': guardia.ausenciaId,
            'observaciones': guardia.observations,
            'estado': 'Pendiente',
            'tramo_horario': guardia.tramoHorario,
            'dia':
                guardia.day.toIso8601String(), // Convert DateTime to ISO format
          },
        );

        // Add the response to the fullResponse list
        fullResponse.add(response);
      }

      print("FULL RESPONSE: $fullResponse");
    } catch (e) {
      print("Error inserting guardias: $e");
    }
  }

  /// Get a list of guardias which state is set to 'pendiente'
  ///
  /// Returns: a list of guardia objects
  Future<List<GuardiaObject>> getUnasignedGuardias() async {
    try {
      // Query Supabase for 'Guardia' objects
      final response = await Supabase.instance.client
          .from('guardias') // Your Supabase table name
          .select()
          .ilike('estado', 'Pendiente');

      // Map the response data into a list of GuardiaObject
      List<GuardiaObject> guardias = [];
      for (var data in response) {
        // Manually handle each field
        int id = data['id_guardia'] as int;
        int? missingTeacherId =
            data['id_profesor_ausente'] != null
                ? data['id_profesor_ausente'] as int
                : null;
        int? ausenciaId =
            data['id_ausencia'] != null ? data['id_ausencia'] as int : null;
        int? tramoHorario =
            data['tramo_horario'] != null ? data['tramo_horario'] as int : null;
        int? substituteTeacherId =
            data['id_profesor_sustituto'] != null
                ? data['id_profesor_sustituto'] as int
                : null;
        String observations = data['observaciones'] as String;
        String status = data['estado'] as String;
        DateTime day = DateTime.parse(data['dia'] as String);

        // Create the GuardiaObject manually
        GuardiaObject guardia = GuardiaObject(
          id: id,
          missingTeacherId: missingTeacherId,
          ausenciaId: ausenciaId,
          tramoHorario: tramoHorario,
          substituteTeacherId: substituteTeacherId,
          observations: observations,
          status: status,
          day: day,
        );

        // Add the guardia to the list
        guardias.add(guardia);
      }

      return guardias;
    } catch (e) {
      // Handle any unexpected errors and return an empty list
      print('Unexpected error: $e');
      return [];
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
          .ilike('estado', 'activo');

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
        authId: response['id_auth'] ?? '',
        role: response['rol'] ?? '',
        firstName: response['nombre'] ?? '',
        lastName: response['apellido1'] ?? '',
        secondLastName: response['apellido2'] ?? '',
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

  /// Get all of the guardias done given a day
  ///
  /// - [day] Day to filter by
  Future<List<GuardiaObject>> getAllGuardiasByDay(DateTime day) async {
    // Perform request with matching day
    final response = await Supabase.instance.client
        .from('guardias')
        .select()
        .eq('dia', day.toIso8601String().split('T')[0]); // Normalize date

    print("RESPONSE: $response");

    // Return an empty list in case of no results
    if (response.isEmpty) {
      return [];
    }

    // Map the responsae
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
            day: DateTime.parse(data['dia']),
          ),
        )
        .toList();
  }

  /// Get a list of guardia objects which state is 'pendiente
  Future<List<GuardiaObject>> getAllUnasignedGuardias() async {
    // Select all pending guardias
    final response = await Supabase.instance.client
        .from('guardias')
        .select()
        .ilike('estado', 'pendiente');

    print("RESPONSE: $response");

    // return an empty list in case of no results
    if (response.isEmpty) {
      return [];
    }

    // Map the response to an object
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
            day: data['dia'],
          ),
        )
        .toList();
  }

  /// Assign a guardia to an user
  ///
  /// - [idGuardia] id of the guardia to update
  /// - [idSubstituteTeacher] id of the teacher to assign it to
  Future<void> assignGuardiaToUser(
    int idGuardia,
    int idSubstituteTeacher,
  ) async {
    final response = await Supabase.instance.client
        .from('guardias')
        .update({
          'id_profesor_sustituto': idSubstituteTeacher,
          'estado': 'Asignada',
        })
        .eq(
          'id_guardia',
          idGuardia,
        ); // Add a filter to select which record to update (you need to specify which "guardia" you're updating)

    if (response.error != null) {
      print("Error assigning guardia: ${response.error!.message}");
    } else {
      print("Guardia assigned successfully");
    }
  }

  /// Get a guardia by its id
  ///
  /// - [id] id of the guardia to retreive
  Future<GuardiaObject?> getGuardiaById(int id) async {
    try {
      final response =
          await Supabase.instance.client
              .from('guardias')
              .select()
              .eq('id_guardia', id)
              .single();

      print(response);

      // Use the mapFromResponse method to map the response into GuardiaObject
      List<GuardiaObject> guardias = GuardiaObject.mapFromResponse([response]);

      print(guardias[0]);

      // Return the first item if it's not empty
      return guardias.isNotEmpty ? guardias[0] : null;
    } catch (e) {
      print("Error getting Guardia: $e");
      return null;
    }
  }

  /// Get all of the guardias done by an user
  ///
  /// - [userId] id of the user to get all of the guardias from
  Future<List<GuardiaObject>> getAllGuardiasByUserId(int userId) async {
    try {
      // Query the 'guardias' table, filtering by 'userId'
      final response = await Supabase.instance.client
          .from('guardias')
          .select()
          .eq(
            'id_profesor_ausente',
            userId,
          ) // Assuming the 'id_profesor_ausente' is the column for userId
          .order('dia', ascending: true); // Optionally order by date ('dia')

      // Check if response is not empty
      if (response.isEmpty) {
        return []; // Return an empty list if no results are found
      }

      // Map the response into a list of GuardiaObject
      List<GuardiaObject> guardias = GuardiaObject.mapFromResponse(response);

      // Return the list of GuardiaObject
      return guardias;
    } catch (e) {
      print("Error getting Guardia by userId: $e");
      return []; // Return an empty list in case of an error
    }
  }

  /// Get all of the guardias done by an user
  ///
  /// - [userId] id of the user to get all of the guardias from
  Future<List<GuardiaObject>> getAllGuardiasDoneByUser(int userId) async {
    try {
      // Fetch all guardias assigned to the user
      final response = await SupabaseManager.instance.getAllGuardiasByUserId(
        userId,
      );

      // Filter the response to include only those guardias where the 'id_profesor_sustituto' matches the userId
      List<GuardiaObject> guardiasDone =
          response
              .where(
                (guardia) => guardia.substituteTeacherId == userId,
              ) // Filter by matching 'id_profesor_sustituto'
              .toList();

      return guardiasDone;
    } catch (e) {
      print("Error fetching guardias done by user: $e");
      return []; // Return an empty list in case of error
    }
  }

  /// Update an user in the database given an object
  ///
  /// - [user] user object to reterive the data from
  Future<bool> updateUser(UserObject user) async {
    try {
      final response =
          await Supabase.instance.client
              .from('usuarios')
              .update({
                'nombre': user.firstName,
                'apellido1': user.lastName,
                'apellido2': user.secondLastName,
                'rol': user.role,
                'email': user.email,
                'telefono': user.phone,
                'estado': user.status,
              })
              .eq('id_usuario', user.id)
              .select()
              .single();

      if (response.isEmpty) {
        print("[DEBUG]: No se pudo actualizar el usuario con ID ${user.id}");
        return false;
      }

      print("[DEBUG]: Usuario actualizado correctamente: ${user.id}");
      return true;
    } catch (e) {
      print("[DEBUG]: Error al actualizar usuario: $e");
      return false;
    }
  }

  /// Change the password given an user id
  ///
  /// - [newPassword] new password to assign
  Future<bool> changeUserPassword(String newPassword) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      print("[DEBUG]: Contraseña actualizada correctamente");
      return true;
    } catch (e) {
      print("[DEBUG]: Error al cambiar la contraseña: $e");
      return false;
    }
  }

  /// Change the password given an user id
  ///
  /// - [userId] id of the user to change the password
  /// - [newPassword] new password to assign
  Future<bool> changeUserPasswordByAdmin(int userId, String newPassword) async {
    try {
      final response = await Supabase.instance.client
          .from('auth.users')
          .update({'password': newPassword})
          .eq('id', userId);

      if (response.error != null) {
        print(
          "[DEBUG]: Error al cambiar contraseña: ${response.error!.message}",
        );
        return false;
      }

      print("[DEBUG]: Contraseña actualizada para el usuario con ID $userId");
      return true;
    } catch (e) {
      print("[DEBUG]: Error al cambiar contraseña: $e");
      return false;
    }
  }

  /// Get a list of unasigned guardias from a specific user only
  ///
  /// - [id] if of the user
  Future<List<GuardiaObject>> getAllUnasignedUserGuardias(int id) async {
    try {
      // Fetch data from Supabase filtering for 'Pendiente' state and matching the provided 'id_profesor_ausente'
      final response = await Supabase.instance.client
          .from('guardias')
          .select()
          .ilike('estado', 'Pendiente')
          .eq('id_profesor_ausente', id);

      // Manually map the response data to a list of GuardiaObject
      List<GuardiaObject> guardias = [];

      if (response.isNotEmpty) {
        for (var data in response) {
          guardias.add(
            GuardiaObject(
              id: data['id_guardia'] as int,
              missingTeacherId:
                  data['id_profesor_ausente'] != null
                      ? data['id_profesor_ausente'] as int
                      : null,
              ausenciaId:
                  data['id_ausencia'] != null
                      ? data['id_ausencia'] as int
                      : null,
              tramoHorario:
                  data['tramo_horario'] != null
                      ? data['tramo_horario'] as int
                      : null,
              substituteTeacherId:
                  data['id_profesor_sustituto'] != null
                      ? data['id_profesor_sustituto'] as int
                      : null,
              observations: data['observaciones'] as String,
              status: data['estado'] as String,
              day: DateTime.parse(data['dia'] as String),
            ),
          );
        }
      } else {
        print("No data found or error occurred.");
      }

      return guardias;
    } catch (e) {
      print("Error getting unassigned user guardias: $e");
      return [];
    }
  }

  /// Delete a guardia given it's id
  ///
  /// - [guardiaId] id of the guardia to delete
  Future<bool> deleteGuardiaById(int guardiaId) async {
    try {
      // Deleting the guardia by its ID
      final response = await Supabase.instance.client
          .from('guardias')
          .delete()
          .eq('id_guardia', guardiaId);

      // Check if the deletion was successful
      if (response.isEmpty) {
        print("Guardia with ID $guardiaId was not found or already deleted.");
        return false;
      }

      print("Guardia with ID $guardiaId was deleted successfully.");
      return true;
    } catch (e) {
      print("Error deleting guardia with ID $guardiaId: $e");
      return false;
    }
  }

  /// Get all of the guardias from today
  Future<List<GuardiaObject>> getTodayGuardias() async {
    try {
      DateTime now = DateTime.now();
      // Format the date as YYYY-MM-DD
      String currentDay =
          "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      // Use eq for an exact match since the database field is of type date
      final response = await Supabase.instance.client
          .from('guardias')
          .select()
          .eq('dia', currentDay);

      final data = response as List<dynamic>;
      return data.map((item) {
        return GuardiaObject(
          id: item['id_guardia'] as int,
          missingTeacherId: item['id_profesor_ausente'] as int?,
          ausenciaId: item['id_ausencia'] as int?,
          tramoHorario: item['tramo_horario'] as int?,
          substituteTeacherId: item['id_profesor_sustituto'] as int?,
          observations: item['observaciones'] as String,
          status: item['estado'] as String,
          // Parse the date string into a DateTime object.
          day: DateTime.parse(item['dia'] as String),
        );
      }).toList();
    } catch (e) {
      print("Error getting guardias from today: $e");
      return [];
    }
  }
}
