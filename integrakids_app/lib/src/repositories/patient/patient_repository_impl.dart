import 'package:firebase_database/firebase_database.dart';

import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import 'patient_repository.dart';

class PatientRepositoryImpl implements PatientRepository {
  @override
  Future<Either<RepositoryException, String>> registerPatient(
      ({
        String? patientId,
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
        'id': newPatientKey, // Inclua o 'id' nos dados salvos
        'patientName': patientData.patientName,
        'tutorsName': patientData.tutorsName,
        'tutorsPhone': patientData.tutorsPhone,
        'tutorsComplaint': patientData.tutorsComplaint,
      });

      return Success(newPatientKey); // Retorne o novo ID do paciente
    } catch (e) {
      return Failure(
          RepositoryException(message: 'Erro ao registrar paciente'));
    }
  }
}
