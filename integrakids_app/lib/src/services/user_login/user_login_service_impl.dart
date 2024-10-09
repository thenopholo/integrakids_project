import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/local_storage_keys.dart';
import '../../core/exceptions/auth_exception.dart';
import '../../core/exceptions/service_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../repositories/user/user_repository.dart';
import './user_login_service.dart';

class UserLoginServiceImpl implements UserLoginService {
  final UserRepository userRepositorie;

  UserLoginServiceImpl({
    required this.userRepositorie,
  });

  @override
  Future<Either<ServiceException, Nil>> execute(
      String email, String password) async {
    final loginResult = await userRepositorie.login(email, password);

    switch (loginResult) {
      case Success(value: final accessToken):
        final sp = await SharedPreferences.getInstance();
        sp.setString(LocalStorageKeys.accessToken, accessToken);
        return Success(nil);
      case Failure(:final exception):
        switch (exception) {
          case AuthError():
            return Failure(
              ServiceException(message: 'Erro ao realizar o login'),
            );
          case AuthUnauthorazedException():
            return Failure(
              ServiceException(message: 'Login ou senha inválidos'),
            );
        }
    }
  }
}
