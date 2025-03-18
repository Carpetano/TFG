class GuardiaObject {
  final int id;
  final int missingTeacherId;
  final int ausenciaId;
  final int tramoHorario;
  final int substituteTeacherId;
  final String observations;
  final String status;

  GuardiaObject({
    required this.id,
    required this.missingTeacherId,
    required this.ausenciaId,
    required this.tramoHorario,
    required this.substituteTeacherId,
    required this.observations,
    required this.status,
  });

  // Factory constructor to create a GuardiaObject from a map (e.g., Supabase response)
  factory GuardiaObject.fromMap(Map<String, dynamic> data) {
    return GuardiaObject(
      id: data['id'] as int, // Assuming the 'id' field is returned by Supabase
      missingTeacherId: data['id_profesor_ausente'] as int,
      ausenciaId: data['id_ausencia'] as int,
      tramoHorario: data['tramo_horario'] as int,
      substituteTeacherId: data['id_substituto'] as int,
      observations: data['observaciones'] as String,
      status: data['estado'] as String,
    );
  }

  @override
  String toString() {
    return 'GuardiaObject(id: $id, missingTeacherId: $missingTeacherId, ausenciaId: $ausenciaId, tramoHorario: $tramoHorario, substituteTeacherId: $substituteTeacherId, observations: $observations, status: $status)';
  }
}
