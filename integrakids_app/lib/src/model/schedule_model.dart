import 'patient_model.dart';
import 'tutor_model.dart';
class ScheduleModel {
  final int id;
  final int clinicaId;
  final int userId;
  final PatientModel patient;
  final TutorModel tutor;
  final String appointmentRoom;
  final List<DateTime> dates;
  final int hour;
  ScheduleModel({
    required this.id,
    required this.clinicaId,
    required this.userId,
    required this.patient,
    required this.tutor,
    required this.appointmentRoom,
    required this.dates,
    required this.hour,
  });
  factory ScheduleModel.fromMap(Map<String, dynamic> json) {
    try {
      return ScheduleModel(
        id: json['id'] ?? 0,  
        clinicaId: json['clinica_id'] ?? 0,
        userId: json['user_id'] ?? 0,
        patient: PatientModel(
          id: 0,  
          name: json['patient_name'] ?? 'Desconhecido',  
          tutor: TutorModel(
            name: json['tutor_name'] ?? 'Sem Tutor',
            phone: json['tutor_phone'] ?? 'Sem Telefone',
          ),
        ),
        tutor: TutorModel(
          name: json['tutor_name'] ?? 'Sem Tutor',
          phone: json['tutor_phone'] ?? 'Sem Telefone',
        ),
        appointmentRoom: json['appointment_room'] ?? '',
        dates: (json['dates'] as List<dynamic>).map((dateString) {
          return DateTime.parse(dateString as String);
        }).toList(),
        hour: json['time'] ?? 0,
      );
    } catch (e) {
      throw ArgumentError('Erro ao converter JSON para ScheduleModel: $e');
    }
  }
}
