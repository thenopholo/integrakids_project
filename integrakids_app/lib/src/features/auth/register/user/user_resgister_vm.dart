import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/fp/either.dart';
import '../../../../core/providers/app_providers.dart';
import 'user_register_providers.dart';

part 'user_resgister_vm.g.dart';

enum UserRegisterStateStatus {
  initial,
  success,
  error,
}

@riverpod
class UserResgisterVm extends _$UserResgisterVm {
  @override
  UserRegisterStateStatus build() => UserRegisterStateStatus.initial;

  Future<void> register({
    required String name,
    required String especialidade,
    required String email,
    required String password,
  }) async {
    final userRegisterAdmService = ref.watch(userRegisterAdmServiceProvider);

    final userDTO = (
      name: name,
      especialidade: especialidade,
      email: email,
      password: password,
    );

    final registerResult = await userRegisterAdmService.execute(userDTO);
    switch (registerResult) {
      case Success():
        ref.invalidate(getMeProvider);
        state = UserRegisterStateStatus.success;
      case Failure():
        state = UserRegisterStateStatus.error;
    }
  }
}
