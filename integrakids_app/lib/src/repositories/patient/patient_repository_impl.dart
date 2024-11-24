import 'package:firebase_database/firebase_database.dart';

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
      DatabaseReference patientsRef =
          FirebaseDatabase.instance.ref().child('patients');
      String newPatientKey = patientsRef.push().key!;
      await patientsRef.child(newPatientKey).set({
        'patientName': patientData.patientName,
        'tutorsName': patientData.tutorsName,
        'tutorsPhone': patientData.tutorsPhone,
        'tutorsComplaint': patientData.tutorsComplaint,
      });
      return Success(Nil());
    } catch (e) {
      return Failure(
          RepositoryException(message: 'Erro ao registrar paciente'));
    }
  }
}
