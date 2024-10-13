import 'dart:developer';

import 'package:dio/dio.dart';

import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../core/restClient/rest_client.dart';
import '../../model/patient_model.dart';
import '../../model/schedule_model.dart';
import '../../model/tutor_model.dart';
import './schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final RestClient restClient;

  ScheduleRepositoryImpl({
    required this.restClient,
  });

  @override
  Future<Either<RepositoryException, Nil>> schedulePatient(
      ({
        int clinicaId,
        List<DateTime> dates,
        PatientModel patient,
        TutorModel tutor,
        String appointmentRoom,
        int time,
        String userId
      }) scheduleData) async {
    try {
      await restClient.auth.post('/schedules', data: {
        'clinica_id': scheduleData.clinicaId,
        'user_id': scheduleData.userId,
        'patient_name': scheduleData.patient.name,
        'tutor_name': scheduleData.tutor.name,
        'tutor_phone': scheduleData.tutor.phone,
        'appointment_room': scheduleData.appointmentRoom,
        'dates':
            scheduleData.dates.map((date) => date.toIso8601String()).toList(),
        'time': scheduleData.time,
      });
      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao registrar agendamento', error: e, stackTrace: s);
      return Failure(RepositoryException(message: 'Erro ao agendar consulta'));
    }
  }

  @override
  Future<Either<RepositoryException, List<ScheduleModel>>> findScheduleByDate(
      ({
        List<DateTime> dates,
        String? userId,
      }) filter) async {
    try {
      final Response response =
          await restClient.auth.get('/schedules', queryParameters: {
        if (filter.userId != null) 'user_id': filter.userId,

        // Aqui você pode enviar as datas no formato ISO para o backend
        'dates': filter.dates.map((date) => date.toIso8601String()).toList(),
      });

      final schedules =
          (response.data as List).map((s) => ScheduleModel.fromMap(s)).toList();
      return Success(schedules);
    } on DioException catch (e, s) {
      log('Erro ao buscar agendamentos de uma data', error: e, stackTrace: s);
      return Failure(
        RepositoryException(message: 'Erro ao buscar agendamentos de uma data'),
      );
    } on ArgumentError catch (e, s) {
      log('Erro ao converter json para ScheduleModel', error: e, stackTrace: s);
      return Failure(
        RepositoryException(
          message: 'Erro ao converter json para ScheduleModel',
        ),
      );
    }
  }
}
