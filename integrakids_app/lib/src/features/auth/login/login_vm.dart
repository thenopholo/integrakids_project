import 'package:asyncstate/asyncstate.dart';
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
    final loaderHandle = AsyncLoaderHandler()..start();
    final loginServive = ref.watch(userLoginServiceProvider);
    final result = await loginServive.execute(email, password);

    switch (result) {
      case Success():
      //! Invalidando os caches para evitar o login com o usuário errado
        ref.invalidate(getMeProvider);
        ref.invalidate(getMyClinicaProvider);
      //! --------------------------------------------------------------//
        final userModel = await ref.read(getMeProvider.future);
        switch (userModel) {
          case UserModelADM():
            state = state.copyWith(status: LoginStateStatus.admLogin);
          case UserModelEmployee():
            state = state.copyWith(status: LoginStateStatus.employeeLogin);
        }
        break;
      case Failure(exception: ServiceException(:final message)):
        state = state.copyWith(
          status: LoginStateStatus.error,
          errorMessage: () => message,
        );
    }
    loaderHandle.close();
  }
}
