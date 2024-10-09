import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../model/clinica_model.dart';
import '../../model/user_model.dart';

abstract interface class ClinicaRepository {

  Future<Either<RepositoryException, Nil>> save(({
    String name,
    String email,
    List<String> openDays,
    List<int> openHours,
  }) data);

  Future<Either<RepositoryException, ClinicaModel>> getMyClinica(UserModel userModel);

}
