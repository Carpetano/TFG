class AusenciaObject {
  final int id;
  final int missingTeacherId;
  final int?
  assignedTeacherId; // Nullable if a substitute is not always assigned
  final String classCode;
  final String tasks;
  final String status;
  final DateTime startTime;
  final DateTime endTime;

  AusenciaObject({
    required this.id,
    required this.missingTeacherId,
    this.assignedTeacherId,
    required this.classCode,
    required this.tasks,
    required this.status,
    required this.startTime,
    required this.endTime,
  });

  /// Factory constructor to create an `AusenciaObject` from a Supabase query result.
  factory AusenciaObject.fromMap(Map<String, dynamic> data) {
    return AusenciaObject(
      id: data['id_ausencia'] as int,
      missingTeacherId: data['profesor_ausente'] as int,
      assignedTeacherId: data['profesor_asignado'] as int?, // Nullable
      classCode: data['aula'] as String,
      tasks: data['tarea'] as String,
      status: data['estado'] as String,
      startTime: DateTime.parse(data['hora_inicio'] as String),
      endTime: DateTime.parse(data['hora_fin'] as String),
    );
  }

  /// Converts the object into a map for inserting/updating in Supabase.
  Map<String, dynamic> toMap() {
    return {
      'id_ausencia': id,
      'profesor_ausente': missingTeacherId,
      'profesor_asignado': assignedTeacherId,
      'aula': classCode,
      'tarea': tasks,
      'estado': status,
      'hora_inicio': startTime.toIso8601String(),
      'hora_fin': endTime.toIso8601String(),
    };
  }
}
