class UserObject {
  final int id;
  final String authId;
  final String role;
  final String firstName;
  final String lastName;
  final String secondLastName;
  final String phone;
  final String email;
  final DateTime registrationDate;
  final String status;
  final String? profileImageUrl; // 🔹 Ahora sí está bien integrada

  UserObject({
    required this.id,
    required this.authId,
    required this.firstName,
    required this.lastName,
    required this.secondLastName,
    required this.role,
    required this.email,
    required this.phone,
    required this.registrationDate,
    required this.status,
    this.profileImageUrl,
  });

  // 🔹 Método para copiar y actualizar propiedades específicas del usuario
  UserObject copyWith({
    int? id,
    String? authId,
    String? role,
    String? firstName,
    String? lastName,
    String? secondLastName,
    String? phone,
    String? email,
    DateTime? registrationDate,
    String? status,
    String? profileImageUrl, // 🔹 Se añadió aquí
  }) {
    return UserObject(
      id: id ?? this.id,
      authId: authId ?? this.authId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      secondLastName: secondLastName ?? this.secondLastName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl, // 🔹 Ahora sí se actualiza
    );
  }

  // 🔹 Convertir un Map (desde Supabase) en un UserObject
  factory UserObject.fromMap(Map<String, dynamic> data) {
    return UserObject(
      id: data['id'] as int,
      authId: data['auth_id'] as String,
      firstName: data['first_name'] as String,
      lastName: data['last_name'] as String,
      secondLastName: data['second_last_name'] as String,
      role: data['role'] as String,
      email: data['email'] as String,
      phone: data['phone'] as String,
      registrationDate: DateTime.parse(data['registration_date'] as String),
      status: data['status'] as String,
      profileImageUrl: data['profile_image_url'] as String?, // 🔹 Se añadió aquí
    );
  }

  // 🔹 Convertir una lista de datos de Supabase en una lista de UserObject
  static List<UserObject> mapFromResponse(List<dynamic>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }
    return response.map((data) => UserObject.fromMap(data)).toList();
  }

  @override
  String toString() {
    return 'UserObject(id: $id, firstName: $firstName, lastName: $lastName, secondLastName: $secondLastName, role: $role, email: $email, phone: $phone, registrationDate: $registrationDate, authId: $authId, status: $status, profileImageUrl: $profileImageUrl)';
  }
}