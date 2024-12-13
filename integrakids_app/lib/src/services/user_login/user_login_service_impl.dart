import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import '../../core/exceptions/service_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import './user_login_service.dart';

class UserLoginServiceImpl implements UserLoginService {
  @override
  Future<Either<ServiceException, Nil>> execute(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Success(nil);
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code} - ${e.message}');
      return Failure(ServiceException(message: 'Login ou senha inválidos'));
    } catch (e) {
      log('Erro ao realizar o login: $e');
      return Failure(ServiceException(message: 'Erro ao realizar o login'));
    }
  }
}