class GuardiaObject {
  final int id;
  final int? missingTeacherId; // Nullable field
  final int? ausenciaId; // Nullable field
  final int? tramoHorario; // Nullable field
  final int? substituteTeacherId; // Nullable field
  final String observations;
  final String status;
  final DateTime day;

  GuardiaObject({
    required this.id,
    this.missingTeacherId,
    this.ausenciaId,
    this.tramoHorario,
    this.substituteTeacherId,
    required this.observations,
    required this.status,
    required this.day,
  });

  // Factory constructor to create a GuardiaObject from a map
  factory GuardiaObject.fromMap(Map<String, dynamic> data) {
    return GuardiaObject(
      id: data['id_guardia'] as int, // Assuming 'id_guardia' is always present
      missingTeacherId:
          data['id_profesor_ausente'] != null
              ? data['id_profesor_ausente'] as int
              : null,
      ausenciaId:
          data['id_ausencia'] != null ? data['id_ausencia'] as int : null,
      tramoHorario:
          data['tramo_horario'] != null ? data['tramo_horario'] as int : null,
      substituteTeacherId:
          data['id_profesor_sustituto'] != null
              ? data['id_profesor_sustituto'] as int
              : null,
      observations: data['observaciones'] as String,
      status: data['estado'] as String,
      day: DateTime.parse(data['dia'] as String),
    );
  }

  @override
  String toString() {
    return 'GuardiaObject(id: $id, missingTeacherId: $missingTeacherId, ausenciaId: $ausenciaId, tramoHorario: $tramoHorario, substituteTeacherId: $substituteTeacherId, observations: $observations, status: $status, day: $day)';
  }

  // This method maps the response from Supabase to a list of GuardiaObject
  static List<GuardiaObject> mapFromResponse(List<dynamic> response) {
    return response
        .map((data) => GuardiaObject.fromMap(data as Map<String, dynamic>))
        .toList();
  }
}