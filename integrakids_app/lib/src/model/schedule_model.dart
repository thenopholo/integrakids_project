import 'patient_model.dart';
import 'tutor_model.dart';

class ScheduleModel {
  final String id;
  final String clinicaId;
  final String userId;
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
    final timeParts = (json['time'] as String).split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts.length > 1 ? timeParts[1] : '0');

    return ScheduleModel(
      id: json['id'] ?? '',
      clinicaId: json['clinicaId'] ?? '',
      userId: json['userId'] ?? '',
      patient: PatientModel(
        id: json['patientId'] ?? '',
        name: json['patientName'] ?? 'Desconhecido',
        tutor: TutorModel(
          name: json['tutorName'] ?? 'Sem Tutor',
          phone: json['tutorPhone'] ?? 'Sem Telefone',
        ),
      ),
      tutor: TutorModel(
        name: json['tutorName'] ?? 'Sem Tutor',
        phone: json['tutorPhone'] ?? 'Sem Telefone',
      ),
      appointmentRoom: json['appointmentRoom'] ?? '',
      dates: [DateTime.parse(json['date'])],
      hour: hour,
      minute: minute,
    );
  } catch (e) {
    throw ArgumentError('Erro ao converter JSON para ScheduleModel: $e');
  }
}

}
