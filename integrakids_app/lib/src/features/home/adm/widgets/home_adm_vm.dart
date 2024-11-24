import 'dart:developer';

import 'package:asyncstate/asyncstate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/fp/either.dart';
import '../../../../core/providers/app_providers.dart';
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

      // Determinar o ID da clínica corretamente
      late final String clinicId;
      if (me is UserModelADM) {
        clinicId = me.id;
      } else if (me is UserModelEmployee) {
        clinicId = me.clinicaId;
      } else {
        throw Exception('Tipo de usuário desconhecido');
      }

      log('Usuário atual: ${me.name}, UID: ${me.id}, Tipo: ${me.runtimeType}');
      log('ID da clínica usado: $clinicId');

      // Obter os funcionários da clínica
      final employeesResult = await repository.getEmployees(clinicId);

      switch (employeesResult) {
        case Success(value: final employeesData):
          // Filtrar possíveis funcionários duplicados
          final employees =
              employeesData.where((employee) => employee.id != me.id).toList();

          // Adicionar o ADM à lista de funcionários se não estiver presente
          if (me is UserModelADM) {
            employees.insert(0, me); // Adiciona o ADM no início da lista
          }

          return HomeAdmState(
            status: HomeAdmStatus.loaded,
            employees: employees,
          );
        case Failure():
          // Em caso de falha, apenas o ADM será exibido
          return HomeAdmState(
            status: HomeAdmStatus.loaded,
            employees: [me],
          );
      }
    } catch (e, s) {
      log('Erro no HomeAdmVm: $e');
      log('StackTrace: $s');
      return HomeAdmState(
        status: HomeAdmStatus.error,
        employees: [],
      );
    }
  }

  Future<void> logout() => ref.read(logoutProvider.future).asyncLoader();
}
