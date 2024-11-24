
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../model/clinica_model.dart';
import '../../model/user_model.dart';
import 'clinica_reposiotry.dart';

class ClinicaRepositoryImpl implements ClinicaRepository {

  @override
  Future<Either<RepositoryException, ClinicaModel>> getMyClinica(
      UserModel userModel) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference clinicaRef =
          FirebaseDatabase.instance.ref().child('clinics').child(uid);
      DataSnapshot snapshot = await clinicaRef.get();
      if (snapshot.exists) {
        Map<String, dynamic> data =
            Map<String, dynamic>.from(snapshot.value as Map);
        ClinicaModel clinica = ClinicaModel.fromMap(data);
        return Success(clinica);
      } else {
        return Failure(RepositoryException(message: 'Clínica não encontrada'));
      }
    } catch (e) {
      return Failure(RepositoryException(message: 'Erro ao obter clínica'));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> save(
      ({
        String email,
        String name,
        List<String> openDays,
        List<int> openHours,
      }) data) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String uid = currentUser.uid;
        DatabaseReference clinicaRef =
            FirebaseDatabase.instance.ref().child('clinics').child(uid);

        await clinicaRef.set({
          'name': data.name,
          'email': data.email,
          'openDays': data.openDays,
          'openHours': data.openHours,
        });

        return Success(nil);
      } else {
        return Failure(RepositoryException(message: 'Usuário não autenticado'));
      }
    } catch (e) {
      return Failure(RepositoryException(message: 'Erro ao salvar clínica'));
    }
  }
}
