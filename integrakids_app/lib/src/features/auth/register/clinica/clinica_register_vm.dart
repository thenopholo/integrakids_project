import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/fp/either.dart';
import '../../../../core/providers/app_providers.dart';
import 'clinica_register_state.dart';
part 'clinica_register_vm.g.dart';

@riverpod
class ClinicaRegisterVm extends _$ClinicaRegisterVm {
  @override
  ClinicaRegisterState build() => ClinicaRegisterState.initial();

  void addOrRemoveOpenDay(String weekDay) {
    final openDays = state.openDays;
    if (openDays.contains(weekDay)) {
      openDays.remove(weekDay);
    } else {
      openDays.add(weekDay);
    }

    state = state.copyWith(openDays: openDays);
  }

  void addOrRemoveOpenHours(int hours) {
    final openHours = state.openHours;
    if (openHours.contains(hours)) {
      openHours.remove(hours);
    } else {
      openHours.add(hours);
    }

    state = state.copyWith(openHours: openHours);
  }

  Future<void> register(String name, String email) async {
  try {
    final repository = ref.watch(clinicaRepositoryProvider);
    final ClinicaRegisterState(:openDays, :openHours) = state;

    final dto = (
      name: name,
      email: email,
      openDays: openDays,
      openHours: openHours,
    );

    log('Salvando clínica com dados: $dto'); // Debug log

    final registerResult = await repository.save(dto);

    switch (registerResult) {
      case Success():
        log('Clínica salva com sucesso'); // Debug log
        await Future.delayed(Duration(milliseconds: 500)); // Pequeno delay
        ref.invalidate(getMyClinicaProvider);
        state = state.copyWith(status: ClinicaRegisterStatus.success);
      case Failure():
        log('Erro ao salvar clínica'); // Debug log
        state = state.copyWith(status: ClinicaRegisterStatus.error);
    }
  } catch (e) {
    log('Erro no registro: $e'); // Debug log
    state = state.copyWith(status: ClinicaRegisterStatus.error);
  }
}
}
