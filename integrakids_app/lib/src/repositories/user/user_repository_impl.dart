import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../../core/exceptions/auth_exception.dart';
import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../model/user_model.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

    UserRepositoryImpl({
    required this.firebaseAuth,
    required this.firestore
  });


  @override
  Future<Either<AuthException, String>> login(
      String email, String password) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final String uid = userCredential.user!.uid;
      return Success(uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        return Failure(AuthUnauthorazedException());
      } else {
        return Failure(AuthError(message: 'Erro ao realizar o login'));
      }
    } catch (e) {
      return Failure(AuthError(message: 'Erro ao realizar o login'));
    }
  }

  @override
  Future<Either<RepositoryException, UserModel>> me() async {
    try {
      final User? user = firebaseAuth.currentUser;
      if (user != null) {
        final DocumentSnapshot doc =
            await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = user.uid; // Certifique-se de definir o 'id'
          return Success(UserModel.fromMap(data));
        } else {
          return Failure(
              RepositoryException(message: 'Dados do usuário não encontrados'));
        }
      } else {
        return Failure(
            RepositoryException(message: 'Usuário não está logado'));
      }
    } catch (e, s) {
      log('Erro ao buscar o usuário logado', error: e, stackTrace: s);
      return Failure(
          RepositoryException(message: 'Erro ao buscar o usuário logado'));
    }
  }

  Future<Either<RepositoryException, Nil>> registerAdmin({
  required String name,
  required String especialidade,
  required String email,
  required String password,
}) async {
  try {
    final UserCredential userCredential = await firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    final User user = userCredential.user!;
    await user.updateDisplayName(name);
    // Salve dados adicionais no Firestore
    await firestore.collection('users').doc(user.uid).set({
      'name': name,
      'especialidade': especialidade,
      'email': email,
      'profile': 'ADM',
    });
    return Success(nil);
  } on FirebaseAuthException catch (e) {
    log('Erro ao registrar o usuário', error: e);
    return Failure(
      RepositoryException(message: 'Erro ao registrar o usuário Admin'),
    );
  } catch (e, s) {
    log('Erro ao registrar o usuário', error: e, stackTrace: s);
    return Failure(
      RepositoryException(message: 'Erro ao registrar o usuário Admin'),
    );
  }
}


  @override
  Future<Either<RepositoryException, List<UserModel>>> getEmployees(
      int clinicaId) async {
    try {
      final QuerySnapshot snapshot = await firestore
          .collection('users')
          .where('clinica_id', isEqualTo: clinicaId)
          .where('profile', isEqualTo: 'EMPLOYEE')
          .get();
      final employees = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return UserModelEmployee.fromMap(data);
      }).toList();
      return Success(employees);
    } catch (e, s) {
      log('Erro ao buscar terapeutas', error: e, stackTrace: s);
      return Failure(
        RepositoryException(message: 'Erro ao buscar terapeutas'),
      );
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerADMAsEmployee({
    required List<String> workDays,
    required List<int> workHours,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Failure(
            RepositoryException(message: 'Usuário não está logado'));
      }
      await firestore.collection('users').doc(user.uid).update({
        'work_days': workDays,
        'work_hours': workHours,
      });
      return Success(nil);
    } catch (e, s) {
      log('Erro ao inserir administrador como terapeuta',
          error: e, stackTrace: s);
      return Failure(RepositoryException(
          message: 'Erro ao inserir administrador como terapeuta'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> registerEmployee({
    required int clinicaId,
    required String name,
    required String especialidade,
    required String email,
    required String password,
    required List<String> workDays,
    required List<int> workHours,
  }) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User user = userCredential.user!;
      await user.updateDisplayName(name);
      await firestore.collection('users').doc(user.uid).set({
        'name': name,
        'especialidade': especialidade,
        'email': email,
        'profile': 'EMPLOYEE',
        'clinica_id': clinicaId,
        'work_days': workDays,
        'work_hours': workHours,
      });
      return Success(nil);
    } on FirebaseAuthException catch (e) {
      log('Erro ao inserir terapeuta', error: e);
      return Failure(RepositoryException(message: 'Erro ao inserir terapeuta'));
    } catch (e, s) {
      log('Erro ao inserir terapeuta', error: e, stackTrace: s);
      return Failure(RepositoryException(message: 'Erro ao inserir terapeuta'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> editEmployee({
    required String id,
    required int clinicaId,
    required String name,
    required String especialidade,
    required String email,
    required List<String> workDays,
    required List<int> workHours,
  }) async {
    try {
      // Atualize os dados no Firestore
      final data = {
        'name': name,
        'especialidade': especialidade,
        'email': email,
        'profile': 'EMPLOYEE',
        'clinica_id': clinicaId,
        'work_days': workDays,
        'work_hours': workHours,
      };
      await firestore.collection('users').doc(id).update(data);
      // Não é possível atualizar o email no FirebaseAuth a menos que esteja autenticado como o usuário
      return Success(nil);
    } catch (e, s) {
      log('Erro ao editar terapeuta', error: e, stackTrace: s);
      return Failure(RepositoryException(message: 'Erro ao editar terapeuta'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> deleteEmployee(String id) async {
    try {
      // Exclua os dados do usuário no Firestore
      await firestore.collection('users').doc(id).delete();
      // Não é possível excluir a conta do usuário no FirebaseAuth a partir do SDK do cliente
      return Success(nil);
    } catch (e, s) {
      log('Erro ao deletar terapeuta', error: e, stackTrace: s);
      return Failure(RepositoryException(message: 'Erro ao deletar terapeuta'));
    }
  }
}
