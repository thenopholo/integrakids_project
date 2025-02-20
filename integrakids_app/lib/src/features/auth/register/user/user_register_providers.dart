import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../services/user_register/user_register_adm_service.dart';
import '../../../../services/user_register/user_register_adm_service_impl.dart';

part 'user_register_providers.g.dart';

@riverpod
UserRegisterAdmService userRegisterAdmService(UserRegisterAdmServiceRef ref) =>
    UserRegisterAdmServiceImpl(
      userRepository: ref.read(userRepositorieProvider),
    );
