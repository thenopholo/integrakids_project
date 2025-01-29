import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../core/exceptions/auth_exception.dart';
import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../model/user_model.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  @override
  Future<Either<AuthException, String>> login(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      return Success(uid);
    } on FirebaseException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return Failure(AuthUnauthorazedException());
      } else {
        return Failure(
            AuthError(message: e.message ?? 'Erro ao realizer o login'));
      }
    }
  }

  @override
  Future<Either<RepositoryException, UserModel>> me() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      log('Current User: ${currentUser?.uid}'); // Log do usuário atual

      if (currentUser != null) {
        String uid = currentUser.uid;
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child('users').child(uid);

        log('Tentando obter dados do usuário em: users/$uid'); // Log do caminho

        DataSnapshot snapshot = await userRef.get();
        log('Snapshot exists: ${snapshot.exists}'); // Log da existência do snapshot
        if (snapshot.exists) {
          log('Dados do snapshot: ${snapshot.value}'); // Log dos dados
          Map<String, dynamic> data =
              Map<String, dynamic>.from(snapshot.value as Map);
          data['id'] = uid;
          UserModel userModel = UserModel.fromMap(data);
          return Success(userModel);
        } else {
          log('Usuário não encontrado no banco');
          return Failure(
              RepositoryException(message: 'Usuário não encontrado'));
        }
      } else {
        log('Nenhum usuário logado no Firebase Auth');
        return Failure(RepositoryException(message: 'Nenhum usuário logado'));
      }
    } catch (e, stackTrace) {
      log('Erro ao obter dados do usuário: $e');
      log('StackTrace: $stackTrace');
      return Failure(
          RepositoryException(message: 'Erro ao obter dados do usuário'));
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

      log('Iniciando registro de ADM: $email'); // Log

      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;
      log('Usuário criado com UID: $uid'); // Log

      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(uid);

      Map<String, dynamic> data = {
        'id': uid, // Adicionar o ID
        'name': name,
        'email': email,
        'especialidade': especialidade,
        'profile': 'ADM',
      };

      log('Salvando dados: $data'); // Log
      await userRef.set(data);

      return Success(nil);
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuthException: ${e.code} - ${e.message}'); // Log
      return Failure(
        RepositoryException(message: e.message ?? 'Erro ao registrar usuário'),
      );
    } catch (e, s) {
      log('Erro ao registrar o usuário: $e'); // Log
      log('StackTrace: $s'); // Log
      return Failure(
        RepositoryException(message: 'Erro desconhecido ao registrar usuário'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, List<UserModel>>> getEmployees(
      String clinicaId) async {
    try {
      log('Buscando funcionários da clínica: $clinicaId');

      // Referência para o nó de funcionários da clínica
      DatabaseReference employeesRef = FirebaseDatabase.instance
          .ref()
          .child('clinics')
          .child(clinicaId)
          .child('employees');

      DataSnapshot snapshot = await employeesRef.get();

      if (snapshot.exists) {
        final List<UserModel> employees = [];

        // Iterar sobre cada nó de funcionário
        Map<dynamic, dynamic> employeesMap =
            snapshot.value as Map<dynamic, dynamic>;
        employeesMap.forEach((key, value) {
          Map<String, dynamic> employeeData = Map<String, dynamic>.from(value);
          employeeData['id'] = key; // Definir o ID do funcionário

          // Criar instância de UserModelEmployee
          UserModelEmployee employee = UserModelEmployee.fromMap(employeeData);
          employees.add(employee);
        });

        log('Total de funcionários encontrados: ${employees.length}');
        return Success(employees);
      } else {
        log('Nenhum funcionário encontrado na clínica $clinicaId');
        return Success([]);
      }
    } catch (e, s) {
      log('Erro ao obter funcionários: $e');
      log('StackTrace: $s');
      return Failure(
          RepositoryException(message: 'Erro ao obter funcionários'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerADMAsEmployee(
      ({List<String> workDays, List<int> workHours}) userModelData,
      String clinicaId) async {
    try {
      final userModelResult = await me();

      switch (userModelResult) {
        case Success(value: final userModel):
          final uid = userModel.id;

          // Referência para o nó de funcionários da clínica
          DatabaseReference admRef = FirebaseDatabase.instance
              .ref()
              .child('clinics')
              .child(clinicaId)
              .child('employees')
              .child(uid);

          Map<String, dynamic> data = {
            'id': uid,
            'name': userModel.name,
            'email': userModel.email,
            'especialidade': userModel.especialidade,
            'work_days': userModelData.workDays,
            'work_hours': userModelData.workHours,
            'profile': 'ADM_EMPLOYEE',
            'clinica_id': clinicaId,
          };

          log('Salvando ADM como employee: $data');
          await admRef.set(data);

          return Success(nil);

        case Failure(:final exception):
          return Failure(exception);
      }
    } catch (e, s) {
      log('Erro ao cadastrar ADM como terapeuta: $e');
      log('StackTrace: $s');
      return Failure(
          RepositoryException(message: 'Erro ao cadastrar ADM como terapeuta'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerEmployee(
      ({
        String clinicaId,
        String email,
        String name,
        String especialidade,
        String password,
        List<String> workDays,
        List<int> workHours
      }) userModel) async {
    try {
      log('Iniciando registro do funcionário: ${userModel.email}');

      final adminUser = FirebaseAuth.instance.currentUser;
      final adminEmail = adminUser?.email;
      // //! Obter de forma segura
      // TODO: 'Obter a senha do administrador de forma segura';
      const adminPassword = '123123';
      // //! ------------------------- //

      // Cria o usuário no Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userModel.email,
        password: userModel.password,
      );

      String uid = userCredential.user!.uid;
      log('Usuário criado com UID: $uid');

      // Dados do funcionário
      Map<String, dynamic> data = {
        'id': uid,
        'name': userModel.name,
        'email': userModel.email,
        'especialidade': userModel.especialidade,
        'profile': 'EMPLOYEE',
        'work_days': userModel.workDays,
        'work_hours': userModel.workHours,
        'clinica_id': userModel.clinicaId,
      };

      log('Dados do funcionário: $data');

      // Salva os dados em clinics/{clinicaId}/employees/{uid}
      DatabaseReference clinicEmployeeRef = FirebaseDatabase.instance
          .ref()
          .child('clinics')
          .child(userModel.clinicaId)
          .child('employees')
          .child(uid);

      await clinicEmployeeRef.set(data);
      log('Dados salvos em clinics/${userModel.clinicaId}/employees/$uid');

      // Salva os dados também em users/{uid}
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users').child(uid);

      await userRef.set(data);
      log('Dados salvos em users/$uid');

      // Fazer logout do novo usuário
      await FirebaseAuth.instance.signOut();

      // Reautenticar como administrador
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: adminEmail!,
        password: adminPassword,
      );

      return Success(nil);
    } on FirebaseAuthException catch (e) {
      log('Erro ao criar usuário no Firebase Auth: ${e.code} - ${e.message}');
      return Failure(
          RepositoryException(message: 'Erro ao criar usuário: ${e.message}'));
    } on FirebaseException catch (e) {
      log('Erro ao salvar dados no Realtime Database: ${e.code} - ${e.message}');
      return Failure(
          RepositoryException(message: 'Erro ao salvar dados: ${e.message}'));
    } catch (e, stackTrace) {
      log('Erro inesperado ao registrar funcionário: $e');
      log('StackTrace: $stackTrace');
      return Failure(RepositoryException(
          message: 'Erro inesperado ao registrar funcionário'));
    }
  }

  @override
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
      }) userModel) async {
    try {
      DatabaseReference employeeRef = FirebaseDatabase.instance
          .ref()
          .child('clinics')
          .child(userModel.clinicaId.toString())
          .child('employees')
          .child(userModel.id.toString());

      final data = {
        'name': userModel.name,
        'especialidade': userModel.especialidade,
        'email': userModel.email,
        'work_days': userModel.workDays,
        'work_hours': userModel.workHours,
      };

      if (userModel.password != null && userModel.password!.isNotEmpty) {
        data['password'] = userModel.password as String;
      }

      await employeeRef.update(data);

      return Success(nil);
    } catch (e) {
      return Failure(
          RepositoryException(message: 'Erro ao editar funcionário.'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> deleteEmployee(
      String id, String clinicaId) async {
    try {
      DatabaseReference employeeRef = FirebaseDatabase.instance
          .ref()
          .child('clinics')
          .child(clinicaId)
          .child('employees')
          .child(id);

      DatabaseReference userRef = FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(id);

      await employeeRef.remove();

      await userRef.remove();

      return Success(nil);
    } catch (e) {
      return Failure(
          RepositoryException(message: 'Erro ao excluir funcionário.'));
    }
  }
}
