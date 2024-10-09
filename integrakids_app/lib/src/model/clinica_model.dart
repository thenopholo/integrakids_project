class ClinicaModel {
  final int id;
  final String name;
  final String email;
  final List<String> openingDays;
  final List<int> openingHours;

  ClinicaModel({
    required this.id,
    required this.name,
    required this.email,
    required this.openingDays,
    required this.openingHours,
  });

  factory ClinicaModel.fromMap(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'email': String email,
        'opening_days': final List openingDays,
        'opening_hours': final List openingHours,
      } =>
        ClinicaModel(
          id: id,
          name: name,
          email: email,
          openingDays: openingDays.cast<String>(),
          openingHours: openingHours.cast<int>(),
        ),
      _ => throw ArgumentError('Invalid Json'),
    };
  }
}
