import 'dart:developer';

import 'package:dio/dio.dart';

import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../core/restClient/rest_client.dart';
import 'patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  final RestClient restClient;

  PatientRepositoryImpl({required this.restClient});

  @override
  Future<Either<RepositoryException, Nil>> registerPatient( 
    ({
      int? patientId,
      String? patientName,
      String? tutorsName,
      String? tutorsPhone,
      String? tutorsComplaint,
    }) patientData) async {
      try {
        await restClient.auth.post('/patients', data: {
          'patient_id': patientData.patientId,
          'patient_name': patientData.patientName,
          'tutors_name': patientData.tutorsName,
          'tutors_phone': patientData.tutorsPhone,
          'tutors_complaint': patientData.tutorsComplaint,
        });
        return Success(Nil());
      } on DioException catch (e, s) {
        log('Erro ao registrar paciente', error: e, stackTrace: s);
        return Failure(RepositoryException(message: 'Erro ao registrar paciente'));
      }
    }
  }
