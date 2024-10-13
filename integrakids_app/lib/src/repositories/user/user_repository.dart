import '../../core/exceptions/auth_exception.dart';
import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../model/user_model.dart';

abstract class UserRepository {
  Future<Either<AuthException, String>> login(String email, String password);

  Future<Either<RepositoryException, UserModel>> me();

  Future<Either<RepositoryException, Nil>> registerAdmin({
    required String name,
    required String especialidade,
    required String email,
    required String password,
  });

  Future<Either<RepositoryException, List<UserModel>>> getEmployees(
      int clinicaId);

  Future<Either<RepositoryException, Nil>> registerADMAsEmployee({
    required List<String> workDays,
    required List<int> workHours,
  });

  Future<Either<RepositoryException, Nil>> registerEmployee({
    required int clinicaId,
    required String name,
    required String especialidade,
    required String email,
    required String password,
    required List<String> workDays,
    required List<int> workHours,
  });

  Future<Either<RepositoryException, Nil>> editEmployee({
    required String id,
    required int clinicaId,
    required String name,
    required String especialidade,
    required String email,
    required List<String> workDays,
    required List<int> workHours,
  });

  Future<Either<RepositoryException, Nil>> deleteEmployee(String id);
}
