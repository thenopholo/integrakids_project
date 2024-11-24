import 'package:asyncstate/asyncstate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/exceptions/repository_exception.dart';
import '../../../core/fp/either.dart';
import '../../../core/fp/nil.dart';
import '../../../core/providers/app_providers.dart';
import '../../../model/clinica_model.dart';
import '../../../repositories/user/user_repository.dart';
import 'employee_register_state.dart';

part 'employee_register_vm.g.dart';

@riverpod
class EmployeeRegisterVm extends _$EmployeeRegisterVm {
  @override
  EmployeeRegisterState build() => EmployeeRegisterState.initial();

  void setRegisterADM(bool isRegisterADM) {
    state = state.copyWith(registerADM: isRegisterADM);
  }

  void addOrRemoveWorkDays(String weekDay) {
    final EmployeeRegisterState(:workDays) = state;

    if (workDays.contains(weekDay)) {
      workDays.remove(weekDay);
    } else {
      workDays.add(weekDay);
    }

    state = state.copyWith(workDays: workDays);
  }

  void addOrRemoveWorkHours(int hours) {
    final EmployeeRegisterState(:workHours) = state;

    if (workHours.contains(hours)) {
      workHours.remove(hours);
    } else {
      workHours.add(hours);
    }

    state = state.copyWith(workHours: workHours);
  }

  Future<void> register(
      {String? name,
      String? email,
      String? password,
      String? especialidade}) async {
    final EmployeeRegisterState(:registerADM, :workDays, :workHours) = state;
    final asyncLoaderHandler = AsyncLoaderHandler()..start();

    final UserRepository(:registerADMAsEmployee, :registerEmployee) =
        ref.read(userRepositorieProvider);

    final Either<RepositoryException, Nil> resultRegister;

    if (registerADM) {
      final dto = (
        workDays: workDays,
        workHours: workHours,
      );
      resultRegister = await registerADMAsEmployee(dto);
    } else {
      final ClinicaModel(:id) = await ref.watch(getMyClinicaProvider.future);
      final dto = (
        clinicaId: id,
        name: name!,
        especialidade: especialidade!,
        email: email!,
        password: password!,
        workDays: workDays,
        workHours: workHours,
      );

      resultRegister = await registerEmployee(dto);
    }

    switch (resultRegister) {
      case Success():
        state = state.copyWith(status: EmployeeRegisterStateStatus.success);
      case Failure():
        state = state.copyWith(status: EmployeeRegisterStateStatus.error);
    }
    asyncLoaderHandler.close();
  }

  void setWorkDays(List<String> workDays) {
  state = state.copyWith(workDays: List.from(workDays));
}

void setWorkHours(List<int> workHours) {
  state = state.copyWith(workHours: List.from(workHours));
}


  Future<void> edit(
      {required String id,
      String? name,
      String? email,
      String? password,
      String? especialidade}) async {
    state = state.copyWith(status: EmployeeRegisterStateStatus.loading);
    final asyncLoaderHandler = AsyncLoaderHandler()..start();

    final EmployeeRegisterState(:workDays, :workHours) = state;
    final clinicaModel = await ref.watch(getMyClinicaProvider.future);
    final clinicaId = clinicaModel.id;

    final dto = (
      id: id,
      clinicaId: clinicaId,
      name: name!,
      especialidade: especialidade!,
      email: email!,
      password: password,
      workDays: workDays,
      workHours: workHours,
    );

    final result = await ref.read(userRepositorieProvider).editEmployee(dto);

    switch (result) {
      case Success():
        state = state.copyWith(status: EmployeeRegisterStateStatus.success);
      case Failure():
        state = state.copyWith(status: EmployeeRegisterStateStatus.error);
    }
    asyncLoaderHandler.close();
  }
}
