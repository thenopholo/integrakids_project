import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../model/patient_model.dart';
import '../../model/schedule_model.dart';
import '../../model/tutor_model.dart';

abstract interface class ScheduleRepository {
  Future<Either<RepositoryException, Nil>> schedulePatient(
      ({
        int clinicaId,
        String userId,
        PatientModel patient,
        TutorModel tutor,
        String appointmentRoom,
        List<DateTime> dates,
        int time,
      }) scheduleData);

  Future<Either<RepositoryException, List<ScheduleModel>>> findScheduleByDate(
      ({
        List<DateTime> dates,
        String? userId,
      }) filter);
}
