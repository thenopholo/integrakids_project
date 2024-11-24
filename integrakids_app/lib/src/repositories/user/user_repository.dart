import '../../core/exceptions/auth_exception.dart';
import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../model/user_model.dart';

abstract interface class UserRepository {
  Future<Either<AuthException, String>> login(String email, String password);

  Future<Either<RepositoryException, UserModel>> me();

  Future<Either<RepositoryException, Nil>> registerAdmin(
      ({
        String name,
        String especialidade,
        String email,
        String password,
      }) userData);

  Future<Either<RepositoryException, List<UserModel>>> getEmployees(
      String clinicaId);

  Future<Either<RepositoryException, Nil>> registerADMAsEmployee(
      ({
        List<String> workDays,
        List<int> workHours,
      }) userModel, String clinicaId);

  Future<Either<RepositoryException, Nil>> registerEmployee(
      ({
        String clinicaId,
        String name,
        String especialidade,
        String email,
        String password,
        List<String> workDays,
        List<int> workHours,
      }) userModel);

Future<Either<RepositoryException, Nil>> editEmployee(
  ({
        String id,
        String clinicaId,
        String name,
        String especialidade,
        String email,
        String? password,
        List<String> workDays,
        List<int> workHours,
  }) userModel);


  Future<Either<RepositoryException, Nil>> deleteEmployee(String id, String clinicaId);
}
