class AusenciaObject {
  final int id;
  final int missingTeacherId;
  final String classCode;

  AusenciaObject({
    required this.id,
    required this.missingTeacherId,
    required this.classCode,
  });

  /// Factory constructor to create an `AusenciaObject` from a Supabase query result.
  factory AusenciaObject.fromMap(Map<String, dynamic> data) {
    return AusenciaObject(
      id: data['id_ausencia'] as int,
      missingTeacherId: data['profesor_ausente'] as int,
      classCode: data['aula'] as String,
    );
  }

  /// Converts the object into a map for inserting/updating in Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id_ausencia': id,
      'profesor_ausente': missingTeacherId,
      'aula': classCode,
    };
  }

  @override
  String toString() {
    return 'AusenciaObject(id: $id, missingTeacherId: $missingTeacherId, classCode: $classCode)';
  }
}
