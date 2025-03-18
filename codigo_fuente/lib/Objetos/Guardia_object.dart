class GuardiaObject {
  final int id, missingTeacherId, ausenciaId, tramoHorario, substituteTeacherId;
  final String observations, status;
  GuardiaObject({
    required this.id,
    required this.missingTeacherId,
    required this.ausenciaId,
    required this.tramoHorario,
    required this.substituteTeacherId,
    required this.observations,
    required this.status,
  });

  @override
  String toString() {
    return 'GuardiaObject(id: $id, missingTeacherId: $missingTeacherId, ausenciaId: $ausenciaId, tramoHorario: $tramoHorario, substituteTeacherId: $substituteTeacherId, observations: $observations, status: $status)';
  }
}
