import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../model/clinica_model.dart';
import '../../model/user_model.dart';
import '../../repositories/clicina/clinica_reposiotry.dart';
import '../../repositories/clicina/clinica_repository_impl.dart';
import '../../repositories/schedule/schedule_repository.dart';
import '../../repositories/schedule/schedule_repository_impl.dart';
import '../../repositories/user/user_repository_impl.dart';
import '../../services/user_login/user_login_service.dart';
import '../../services/user_login/user_login_service_impl.dart';
import '../fp/either.dart';
import '../ui/widgets/clinica_nav_global_key.dart';

part 'app_providers.g.dart';



@Riverpod(keepAlive: true)
UserRepositoryImpl userRepositorie(UserRepositorieRef ref) => UserRepositoryImpl();

@Riverpod(keepAlive: true)
UserLoginService userLoginService(UserLoginServiceRef ref) =>
    UserLoginServiceImpl();

@Riverpod(keepAlive: true)
Future<UserModel> getMe(GetMeRef ref) async {
  final result = await ref.watch(userRepositorieProvider).me();

  return switch (result) {
    Success(value: final userModel) => userModel,
    Failure(:final exception) => throw exception,
  };
}

@Riverpod(keepAlive: true)
ClinicaRepository clinicaRepository(ClinicaRepositoryRef ref) => ClinicaRepositoryImpl();

@Riverpod(keepAlive: true)
Future<ClinicaModel> getMyClinica(GetMyClinicaRef ref) async {
  try {
    final userModel = await ref.watch(getMeProvider.future);
    final clinicaRepository = ref.watch(clinicaRepositoryProvider);
    final result = await clinicaRepository.getMyClinica(userModel);

    return switch (result) {
      Success(value: final clinica) => clinica,
      Failure(:final exception) => throw exception,
    };
  } catch (e) {
    // Se não encontrar a clínica, retorna uma clínica vazia com o ID do usuário
    final userModel = await ref.watch(getMeProvider.future);
    return ClinicaModel(
      id: userModel.id,
      name: '',
      email: '',
      openDays: [],
      openHours: [],
    );
  }
}

@riverpod
Future<void> logout(LogoutRef ref) async {
  await FirebaseAuth.instance.signOut();

  ref.invalidate(getMeProvider);
  ref.invalidate(getMyClinicaProvider);

  Navigator.of(ClinicaNavGlobalKey.instance.navKey.currentContext!)
      .pushNamedAndRemoveUntil('/auth/login', (route) => false);
}

@riverpod
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) => ScheduleRepositoryImpl();
