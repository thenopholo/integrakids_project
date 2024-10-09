// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$restClientHash() => r'0ee58f1fd102b2016ed621885f1e8d52ed00da66';

/// See also [restClient].
@ProviderFor(restClient)
final restClientProvider = Provider<RestClient>.internal(
  restClient,
  name: r'restClientProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$restClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RestClientRef = ProviderRef<RestClient>;
String _$userRepositorieHash() => r'abf4cd67dff5f28dafd24c2bd7535354ee3959e6';

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
String _$userLoginServiceHash() => r'c5c59fadeea48493a7c6ad96a13fa2e0821ce9dd';

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
String _$clinicaRepositoryHash() => r'ab077dfab954b33f1c6e671b915fbbb93e4fc53a';

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
String _$getMyClinicaHash() => r'b1d7ab4d957ea48e53bf1bca261b16ff2f00b641';

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
String _$logoutHash() => r'12afdaa89bedc9b7ffb1df963220919aa88ff076';

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
    r'd8bb90e09ddffd4926259e9e2ec796a76739a37d';

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
