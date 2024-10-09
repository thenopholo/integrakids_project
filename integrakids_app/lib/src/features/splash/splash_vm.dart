import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/local_storage_keys.dart';
import '../../core/providers/app_providers.dart';
import '../../model/user_model.dart';

part 'splash_vm.g.dart';

enum SplashState {
  initial,
  login,
  loggedADM,
  loggedEmployee,
  error;
}

@riverpod
class SplashVm extends _$SplashVm {
  @override
  Future<SplashState> build() async {
    final sp = await SharedPreferences.getInstance();
    if (sp.containsKey(LocalStorageKeys.accessToken)) {
      ref.invalidate(getMeProvider);
      ref.invalidate(getMyClinicaProvider);

      try {
        final userModel = await ref.watch(getMeProvider.future);
        return switch (userModel) {
          UserModelADM() => SplashState.loggedADM,
          UserModelEmployee() => SplashState.loggedEmployee,
        };
      } catch (e) {
        return SplashState.login;
      }
    }

    return SplashState.login;
  }
}
