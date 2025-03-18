class AulaObject {
  final String classcode, floor, wing, group;
  AulaObject({
    required this.classcode,
    required this.floor,
    required this.wing,
    required this.group,
  });

  @override
  String toString() {
    return 'AulaObject(classcode: $classcode, floor: $floor, wing: $wing, group: $group)';
  }
}
