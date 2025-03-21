/// Guardia object representing a supervision to be done in the database
class GuardiaObject {
  final int id;
  final int? missingTeacherId;
  final int? ausenciaId;
  final int? tramoHorario;
  final int? substituteTeacherId;
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

  factory GuardiaObject.fromMap(Map<String, dynamic> data) {
    return GuardiaObject(
      id: data['id_guardia'] as int,
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

  static List<GuardiaObject> mapFromResponse(List<dynamic> response) {
    return response
        .map((data) => GuardiaObject.fromMap(data as Map<String, dynamic>))
        .toList();
  }
}
