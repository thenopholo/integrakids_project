import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../restClient/rest_client.dart';
import '../ui/widgets/clinica_nav_global_key.dart';

part 'app_providers.g.dart';

@Riverpod(keepAlive: true)
RestClient restClient(RestClientRef ref) => RestClient();

@Riverpod(keepAlive: true)
UserRepositoryImpl userRepositorie(UserRepositorieRef ref) =>
    UserRepositoryImpl(restClient: ref.read(restClientProvider));

@Riverpod(keepAlive: true)
UserLoginService userLoginService(UserLoginServiceRef ref) =>
    UserLoginServiceImpl(userRepositorie: ref.read(userRepositorieProvider));

@Riverpod(keepAlive: true)
Future<UserModel> getMe(GetMeRef ref) async {
  final result = await ref.watch(userRepositorieProvider).me();

  return switch (result) {
    Success(value: final userModel) => userModel,
    Failure(:final exception) => throw exception,
  };
}

@Riverpod(keepAlive: true)
ClinicaRepository clinicaRepository(ClinicaRepositoryRef ref) =>
    ClinicaRepositoryImpl(
      restClient: ref.watch(restClientProvider),
    );

@Riverpod(keepAlive: true)
Future<ClinicaModel> getMyClinica(GetMyClinicaRef ref) async {
  final userModel = await ref.watch(getMeProvider.future);
  final clinicaRepository = ref.watch(clinicaRepositoryProvider);
  final result = await clinicaRepository.getMyClinica(userModel);

  return switch (result) {
    Success(value: final clinica) => clinica,
    Failure(:final exception) => throw exception,
  };
}

@riverpod
Future<void> logout(LogoutRef ref) async {
  final sp = await SharedPreferences.getInstance();
  sp.clear();

  ref.invalidate(getMeProvider);
  ref.invalidate(getMyClinicaProvider);

  Navigator.of(ClinicaNavGlobalKey.instance.navKey.currentContext!)
      .pushNamedAndRemoveUntil('/auth/login', (route) => false);
}

@riverpod
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) =>
    ScheduleRepositoryImpl(
      restClient: ref.read(restClientProvider),
    );
