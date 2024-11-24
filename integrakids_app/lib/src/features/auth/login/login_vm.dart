import 'package:asyncstate/asyncstate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/exceptions/service_exception.dart';
import '../../../core/fp/either.dart';
import '../../../core/providers/app_providers.dart';
import '../../../model/user_model.dart';
import 'login_state.dart';

part 'login_vm.g.dart';

@riverpod
class LoginVm extends _$LoginVm {
  @override
  LoginState build() => LoginState.initial();

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(status: LoginStateStatus.initial);
      final loaderHandle = AsyncLoaderHandler()..start();
      
      final loginService = ref.watch(userLoginServiceProvider);
      final result = await loginService.execute(email, password);

      switch (result) {
        case Success():
          // Limpar cache
          ref.invalidate(getMeProvider);
          ref.invalidate(getMyClinicaProvider);

          // Verificar se o usuário está autenticado
          final currentUser = FirebaseAuth.instance.currentUser;
          if (currentUser != null) {
            try {
              final userModel = await ref.read(getMeProvider.future);
              switch (userModel) {
                case UserModelADM():
                  state = state.copyWith(status: LoginStateStatus.admLogin);
                case UserModelEmployee():
                  state = state.copyWith(status: LoginStateStatus.employeeLogin);
              }
            } catch (e) {
              state = state.copyWith(
                status: LoginStateStatus.error,
                errorMessage: () => 'Erro ao obter dados do usuário',
              );
            }
          } else {
            state = state.copyWith(
              status: LoginStateStatus.error,
              errorMessage: () => 'Usuário não autenticado',
            );
          }

        case Failure(exception: ServiceException(:final message)):
          state = state.copyWith(
            status: LoginStateStatus.error,
            errorMessage: () => message,
          );
      }
      loaderHandle.close();
    } catch (e) {
      state = state.copyWith(
        status: LoginStateStatus.error,
        errorMessage: () => 'Erro ao realizar login',
      );
    }
  }
}