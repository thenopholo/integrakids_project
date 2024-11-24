// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRepositorieHash() => r'811739e8e991586ed2c99c417930968430d85dfe';

/// See also [userRepositorie].
@ProviderFor(userRepositorie)
final userRepositorieProvider = Provider<UserRepositoryImpl>.internal(
  userRepositorie,
  name: r'userRepositorieProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositorieHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserRepositorieRef = ProviderRef<UserRepositoryImpl>;
String _$userLoginServiceHash() => r'93554e8906ea88c2d45a77b10000f4a4ed1da74a';

/// See also [userLoginService].
@ProviderFor(userLoginService)
final userLoginServiceProvider = Provider<UserLoginService>.internal(
  userLoginService,
  name: r'userLoginServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userLoginServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserLoginServiceRef = ProviderRef<UserLoginService>;
String _$getMeHash() => r'91a8a4c1b76ce0a764300eceb540a5d9990c4bf1';

/// See also [getMe].
@ProviderFor(getMe)
final getMeProvider = FutureProvider<UserModel>.internal(
  getMe,
  name: r'getMeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getMeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetMeRef = FutureProviderRef<UserModel>;
String _$clinicaRepositoryHash() => r'b2d209bad840b20997f8a3cac8beee815ccc3aa7';

/// See also [clinicaRepository].
@ProviderFor(clinicaRepository)
final clinicaRepositoryProvider = Provider<ClinicaRepository>.internal(
  clinicaRepository,
  name: r'clinicaRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clinicaRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ClinicaRepositoryRef = ProviderRef<ClinicaRepository>;
String _$getMyClinicaHash() => r'31cdd6351e708c6aa0611c6e94b7bdbfada6b82d';

/// See also [getMyClinica].
@ProviderFor(getMyClinica)
final getMyClinicaProvider = FutureProvider<ClinicaModel>.internal(
  getMyClinica,
  name: r'getMyClinicaProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getMyClinicaHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetMyClinicaRef = FutureProviderRef<ClinicaModel>;
String _$logoutHash() => r'21c379fefc96a014c61cbfde202f5ba789228af1';

/// See also [logout].
@ProviderFor(logout)
final logoutProvider = AutoDisposeFutureProvider<void>.internal(
  logout,
  name: r'logoutProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$logoutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef LogoutRef = AutoDisposeFutureProviderRef<void>;
String _$scheduleRepositoryHash() =>
    r'f0fcaaf172f95dd446ca5b625b7897899e75ce8a';

/// See also [scheduleRepository].
@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider =
    AutoDisposeProvider<ScheduleRepository>.internal(
  scheduleRepository,
  name: r'scheduleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ScheduleRepositoryRef = AutoDisposeProviderRef<ScheduleRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
