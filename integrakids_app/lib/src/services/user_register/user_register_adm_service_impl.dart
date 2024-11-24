import 'package:firebase_auth/firebase_auth.dart';

import '../../core/exceptions/service_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../repositories/user/user_repository.dart';
import 'user_register_adm_service.dart';

class UserRegisterAdmServiceImpl implements UserRegisterAdmService {
  final UserRepository userRepository;

  UserRegisterAdmServiceImpl({
    required this.userRepository,
  });

  @override
  Future<Either<ServiceException, Nil>> execute(
      ({
        String email,
        String name,
        String especialidade,
        String password,
      }) userData) async {
    final registerResult = await userRepository.registerAdmin(userData);

    switch (registerResult) {
      case Success():
        // Verifique se o usuário está autenticado
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Usuário autenticado, prossiga para salvar a clínica
          return Success(nil);
        } else {
          // O usuário não está autenticado
          return Failure(ServiceException(message: 'Usuário não autenticado após o registro'));
        }
      case Failure(:final exception):
        return Failure(ServiceException(message: exception.message));
    }
  }
}