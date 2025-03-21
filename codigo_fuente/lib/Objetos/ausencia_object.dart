/// Ausencia object representing that a teacher is not coming on a specified date
class AusenciaObject {
  final int id;
  final int missingTeacherId;
  final String classCode;

  AusenciaObject({
    required this.id,
    required this.missingTeacherId,
    required this.classCode,
  });

  factory AusenciaObject.fromMap(Map<String, dynamic> data) {
    return AusenciaObject(
      id: data['id'] ?? 0,
      missingTeacherId: data['missing_teacher_id'] ?? 0,
      classCode: data['class_code'] ?? '',
    );
  }

  static List<AusenciaObject> mapFromResponse(List<dynamic>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }
    return response.map((data) => AusenciaObject.fromMap(data)).toList();
  }

  @override
  String toString() {
    return 'AusenciaObject(id: $id, missingTeacherId: $missingTeacherId, classCode: $classCode)';
  }
}
