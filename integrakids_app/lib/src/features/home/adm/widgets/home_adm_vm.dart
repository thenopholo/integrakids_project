import 'package:asyncstate/asyncstate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/fp/either.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../model/clinica_model.dart';
import '../../../../model/user_model.dart';
import 'home_adm_state.dart';

part 'home_adm_vm.g.dart';

@riverpod
class HomeAdmVm extends _$HomeAdmVm {
  @override
  Future<HomeAdmState> build() async {
    final repository = ref.read(userRepositoryProvider);
    final ClinicaModel(id: clinicaId) =
        await ref.read(getMyClinicaProvider.future);
    final me = await ref.watch(getMeProvider.future);

    final employeesResult = await repository.getEmployees(clinicaId);

    switch (employeesResult) {
      case Success(value: final employeesData):
        final employees = <UserModel>[];
        if (me case UserModelADM(workDays: _?, workHours: _?)) {
          employees.add(me);
        }
        employees.addAll(employeesData);
        return HomeAdmState(
          status: HomeAdmStatus.loaded,
          employees: employees,
        );
      case Failure():
        return HomeAdmState(
          status: HomeAdmStatus.error,
          employees: [],
        );
    }
  }

  Future<void> logout() => ref.read(logoutProvider.future).asyncLoader();
}
