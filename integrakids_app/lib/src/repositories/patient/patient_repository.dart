import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';


abstract interface class PatientRepository {

  Future<Either<RepositoryException, String>> registerPatient(
      ({
        String patientId,
        String patientName,
        String tutorsName,
        String tutorsPhone,
        String tutorsComplaint,
      }) patientData);
  

  
}