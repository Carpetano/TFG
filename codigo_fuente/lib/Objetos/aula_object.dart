/// Aula object representing a class inside a school
class AulaObject {
  final String classcode, floor, wing, group;

  AulaObject({
    required this.classcode,
    required this.floor,
    required this.wing,
    required this.group,
  });

  factory AulaObject.fromMap(Map<String, dynamic> data) {
    return AulaObject(
      classcode: data['classcode'] ?? '',
      floor: data['floor'] ?? '',
      wing: data['wing'] ?? '',
      group: data['group'] ?? '',
    );
  }

  static List<AulaObject> mapFromResponse(List<dynamic>? response) {
    if (response == null || response.isEmpty) {
      return [];
    }
    return response.map((data) => AulaObject.fromMap(data)).toList();
  }

  @override
  String toString() {
    return 'AulaObject(classcode: $classcode, floor: $floor, wing: $wing, group: $group)';
  }
}
