class AulaObject {
  final String classcode, floor, wing, group;

  // Constructor for AulaObject
  AulaObject({
    required this.classcode,
    required this.floor,
    required this.wing,
    required this.group,
  });

  // Factory constructor to create an AulaObject from a map.
  // This cleanses the input data and maps the fields to the object properties.
  factory AulaObject.fromMap(Map<String, dynamic> data) {
    return AulaObject(
      classcode:
          data['classcode'] ?? '', // Providing a default empty string if null
      floor: data['floor'] ?? '', // Providing a default empty string if null
      wing: data['wing'] ?? '', // Providing a default empty string if null
      group: data['group'] ?? '', // Providing a default empty string if null
    );
  }

  // Static method to convert a list of maps (e.g., a database response)
  // into a list of AulaObject instances.
  static List<AulaObject> mapFromResponse(List<dynamic>? response) {
    // Check if the response is null or empty and return an empty list if so.
    if (response == null || response.isEmpty) {
      return [];
    }
    // Map each entry in the response list to an AulaObject using the factory constructor.
    return response.map((data) => AulaObject.fromMap(data)).toList();
  }

  @override
  String toString() {
    return 'AulaObject(classcode: $classcode, floor: $floor, wing: $wing, group: $group)';
  }
}