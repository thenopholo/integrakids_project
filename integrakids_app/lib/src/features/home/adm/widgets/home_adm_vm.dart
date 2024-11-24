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
    try {
      final repository = ref.read(userRepositorieProvider);
      final me = await ref.watch(getMeProvider.future);
      
      // Tenta obter a clínica, mas não falha se não encontrar
      final clinicaModel = await ref.read(getMyClinicaProvider.future)
          .catchError((e) => ClinicaModel(
                id: me.id, // Usa o ID do usuário como ID da clínica
                name: '',
                email: '',
                openDays: [],
                openHours: [],
              ));

      final employeesResult = await repository.getEmployees(clinicaModel.id);

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
            status: HomeAdmStatus.loaded, // Mudado para loaded pois ainda queremos mostrar o ADM
            employees: [me], // Inclui apenas o ADM na lista
          );
      }
    } catch (e) {
      return HomeAdmState(
        status: HomeAdmStatus.error,
        employees: [],
      );
    }
  }

  Future<void> logout() => ref.read(logoutProvider.future).asyncLoader();
}
