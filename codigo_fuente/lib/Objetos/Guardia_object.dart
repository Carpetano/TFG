class GuardiaObject {
  final int id;
  final int? missingTeacherId; // Nullable if the field can be null
  final int? ausenciaId; // Nullable if the field can be null
  final int? tramoHorario; // Nullable if the field can be null
  final int? substituteTeacherId; // Nullable if the field can be null
  final String observations;
  final String status;
  final DateTime day; // Changed from String to DateTime

  GuardiaObject({
    required this.id,
    this.missingTeacherId, // Nullable field
    this.ausenciaId, // Nullable field
    this.tramoHorario, // Nullable field
    this.substituteTeacherId, // Nullable field
    required this.observations,
    required this.status,
    required this.day,
  });

  // Factory constructor to create a GuardiaObject from a map (e.g., Supabase response)
  factory GuardiaObject.fromMap(Map<String, dynamic> data) {
    return GuardiaObject(
      id: data['id'] as int, // Assuming 'id' field is always present
      missingTeacherId:
          data['id_profesor_ausente'] != null
              ? data['id_profesor_ausente'] as int
              : null,
      ausenciaId:
          data['id_ausencia'] != null ? data['id_ausencia'] as int : null,
      tramoHorario:
          data['tramo_horario'] != null ? data['tramo_horario'] as int : null,
      substituteTeacherId:
          data['id_substituto'] != null ? data['id_substituto'] as int : null,
      observations: data['observaciones'] as String,
      status: data['estado'] as String,
      day: DateTime.parse(
        data['dia'] as String,
      ), // Assuming 'dia' is a valid date string
    );
  }

  @override
  String toString() {
    return 'GuardiaObject(id: $id, missingTeacherId: $missingTeacherId, ausenciaId: $ausenciaId, tramoHorario: $tramoHorario, substituteTeacherId: $substituteTeacherId, observations: $observations, status: $status, day: $day)';
  }
}
