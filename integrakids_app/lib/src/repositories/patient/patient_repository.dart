import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';


abstract interface class PatientRepository {

  Future<Either<RepositoryException, Nil>> registerPatient(
      ({
        int patientId,
        String patientName,
        String tutorsName,
        String tutorsPhone,
        String tutorsComplaint,
      }) patientData);
  

  
}