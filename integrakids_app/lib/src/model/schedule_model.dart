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
  final int minute;
  ScheduleModel({
    required this.id,
    required this.clinicaId,
    required this.userId,
    required this.patient,
    required this.tutor,
    required this.appointmentRoom,
    required this.dates,
    required this.hour,
    required this.minute,
  });
  factory ScheduleModel.fromMap(Map<String, dynamic> json) {
    try {
      int hour = json['hour'] ?? 0;
      int minute = json['minute'] ?? 0;

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
          DateTime baseDate = DateTime.parse(dateString as String);
          return DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            hour,
            minute,
          );
        }).toList(),
        hour: hour,
        minute: minute,
      );
    } catch (e) {
      throw ArgumentError('Erro ao converter JSON para ScheduleModel: $e');
    }
  }
}
