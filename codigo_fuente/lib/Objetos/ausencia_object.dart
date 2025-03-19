class AusenciaObject {
  final int id;
  final int missingTeacherId;
  final String classCode;

  AusenciaObject({
    required this.id,
    required this.missingTeacherId,
    required this.classCode,
  });

  // Factory constructor to create an AusenciaObject from a map
  factory AusenciaObject.fromMap(Map<String, dynamic> data) {
    return AusenciaObject(
      id: data['id'] ?? 0, // Default to 0 if the ID is missing
      missingTeacherId:
          data['missing_teacher_id'] ?? 0, // Default to 0 if missing
      classCode: data['class_code'] ?? '', // Default to empty string if missing
    );
  }

  // Static method to map a list of maps (e.g., database response) to a list of AusenciaObject instances
  static List<AusenciaObject> mapFromResponse(List<dynamic>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }
    // Map each entry in the response list to an AusenciaObject using the fromMap factory constructor
    return response.map((data) => AusenciaObject.fromMap(data)).toList();
  }

  @override
  String toString() {
    return 'AusenciaObject(id: $id, missingTeacherId: $missingTeacherId, classCode: $classCode)';
  }
}
