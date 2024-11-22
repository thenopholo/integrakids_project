import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../core/exceptions/auth_exception.dart';
import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../core/restClient/rest_client.dart';
import '../../model/user_model.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final RestClient restClient;

  UserRepositoryImpl({required this.restClient});

  @override
  Future<Either<AuthException, String>> login(
      String email, String password) async {
    try {
      final Response(:data) = await restClient.unauth.post('/auth', data: {
        'email': email,
        'password': password,
      });

      return Success(data['access_token']);
    } on DioException catch (e, s) {
      if (e.response != null) {
        final Response(:statusCode) = e.response!;
        if (statusCode == HttpStatus.forbidden) {
          log('Login ou senha inválidos', error: e, stackTrace: s);
          return Failure(AuthUnauthorazedException());
        }
      }
      log('Erro ao realizar o login', error: e, stackTrace: s);
      return Failure(AuthError(message: 'Erro ao realizar o login'));
    }
  }

  @override
  Future<Either<RepositoryException, UserModel>> me() async {
    try {
      final Response(:data) = await restClient.auth.get('/me');
      return Success(UserModel.fromMap(data));
    } on DioException catch (e, s) {
      log('Erro ao buscar o usuário logado', error: e, stackTrace: s);
      return Failure(
          RepositoryException(message: 'Erro ao buscar o usuário logado'));
    } on ArgumentError catch (e, s) {
      log('Invalid Json', error: e, stackTrace: s);
      return Failure(
        RepositoryException(message: e.message),
      );
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerAdmin(
      ({
        String email,
        String name,
        String password,
        String especialidade
      }) userData) async {
    try {
      final String email = userData.email;
      final String name = userData.name;
      final String password = userData.password;
      final String especialidade = userData.especialidade;

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users').child(uid);

      Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'especialidade': especialidade,
        'profile': 'ADM',
      };

      await userRef.child(uid).set(data);

      return Success(nil);
    } on FirebaseAuthException catch (e) {
      return Failure(
        RepositoryException(message: e.message ?? 'Erro ao registrar usuário'),
      );
    } catch (e, s) {
      log('Erro ao registrar o usuário', error: e, stackTrace: s);
      return Failure(
        RepositoryException(message: 'Erro desconhecido ao registrar usuário'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, List<UserModel>>> getEmployees(
      int clinicaId) async {
    try {
      final Response(:List data) = await restClient.auth.get(
        '/users',
        queryParameters: {'clinica_id': clinicaId},
      );
      final employees = data.map((e) => UserModelEmployee.fromMap(e)).toList();
      return Success(employees);
    } on DioException catch (e, s) {
      log('Erro ao buscar terapuetas', error: e, stackTrace: s);
      return Failure(
        RepositoryException(message: 'Erro ao buscar terapuetas'),
      );
    } on ArgumentError catch (e, s) {
      log('Erro ao converter terapuetas (Ivalid Json)',
          error: e, stackTrace: s);
      return Failure(
        RepositoryException(message: 'Erro ao buscar terapuetas'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerADMAsEmployee(
      ({List<String> workDays, List<int> workHours}) userModel) async {
    try {
      final userModelResult = await me();

      final int userId;

      switch (userModelResult) {
        case Success(value: UserModel(:var id)):
          userId = id;
        case Failure(:var exception):
          return Failure(exception);
      }

      await restClient.auth.put('/users/$userId', data: {
        'work_days': userModel.workDays,
        'work_hours': userModel.workHours,
      });

      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao inserir administrador como terapeuta',
          error: e, stackTrace: s);
      return Failure(RepositoryException(
          message: 'Erro ao inserir administrador como terapeuta'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerEmployee(
      ({
        int clinicaId,
        String email,
        String name,
        String especialidade,
        String password,
        List<String> workDays,
        List<int> workHours
      }) userModel) async {
    try {
      await restClient.auth.post('/users/', data: {
        'name': userModel.name,
        'especialidade': userModel.especialidade,
        'email': userModel.email,
        'password': userModel.password,
        'profile': 'EMPLOYEE',
        'clinica_id': userModel.clinicaId,
        'work_days': userModel.workDays,
        'work_hours': userModel.workHours,
      });

      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao inserir terapeuta', error: e, stackTrace: s);
      return Failure(RepositoryException(message: 'Erro ao inserir terapeuta'));
    }
  }

  @override
  @override
  Future<Either<RepositoryException, Nil>> editEmployee(
      ({
        int id,
        int clinicaId,
        String name,
        String especialidade,
        String email,
        String? password,
        List<String> workDays,
        List<int> workHours,
      }) userModel) async {
    try {
      final data = {
        'name': userModel.name,
        'especialidade': userModel.especialidade,
        'email': userModel.email,
        'profile': 'EMPLOYEE',
        'clinica_id': userModel.clinicaId,
        'work_days': userModel.workDays,
        'work_hours': userModel.workHours,
      };
      if (userModel.password != null && userModel.password!.isNotEmpty) {
        data['password'] = userModel.password as String;
      }

      await restClient.auth.put('/users/${userModel.id}', data: data);

      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao editar terapeuta', error: e, stackTrace: s);
      return Failure(RepositoryException(message: 'Erro ao editar terapeuta'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> deleteEmployee(int id) async {
    try {
      await restClient.auth.delete('/users/$id');
      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao deletar terapeuta', error: e, stackTrace: s);
      return Failure(RepositoryException(message: 'Erro ao deletar terapeuta'));
    }
  }
}
