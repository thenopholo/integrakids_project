
class TutorModel {
  final String name;
  final String phone;

  TutorModel({
    required this.name,
    required this.phone,
  });

  factory TutorModel.fromMap(Map<String, dynamic> json) {
    switch (json) {
      case {
        'name': String name,
        'phone': String phone,
      }:
        return TutorModel(
          name: name,
          phone: phone,
        );
      default:
        throw ArgumentError('Invalid Json');
    }
  }
}
