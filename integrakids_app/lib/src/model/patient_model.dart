import 'tutor_model.dart';

class PatientModel {
  final int id;
  final String name;
  final TutorModel tutor;

  PatientModel({
    required this.id,
    required this.name,
    required this.tutor,
  });

  factory PatientModel.fromMap(Map<String, dynamic> json) {
    return PatientModel(
      id: 0,
      name: json['patientName'],
      tutor: TutorModel(
        name: json['tutorsName'],
        phone: json['tutorsPhone'],
      ),
    );
  }
  
  Map<String, dynamic> tojson() {
    return {
      'id': id,
      'name': name,
      'tutor': {
        'name': tutor.name,
        'phone': tutor.phone,
      },
    };
  }
}
