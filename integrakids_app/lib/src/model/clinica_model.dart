class ClinicaModel {
  final String id;
  final String name;
  final String email;
  final List<String> openDays;
  final List<int> openHours;

  ClinicaModel({
    required this.id,
    required this.name,
    required this.email,
    required this.openDays,
    required this.openHours,
  });

  factory ClinicaModel.fromMap(Map<String, dynamic> map) {
    return ClinicaModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      openDays: List<String>.from(map['openDays'] ?? []),
      openHours: (map['openHours'] as List<dynamic>? ?? [])
          .map((e) => e is int ? e : int.parse(e.toString()))
          .toList(),
    );
  }
}
