import 'package:asyncstate/asyncstate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/fp/either.dart';
import '../../core/providers/app_providers.dart';
import '../../model/clinica_model.dart';
import '../../model/patient_model.dart';
import '../../model/user_model.dart';
import 'schedule_state.dart';

part 'schedule_vm.g.dart';

@riverpod
class ScheduleVm extends _$ScheduleVm {
  @override
  ScheduleState build() => ScheduleState.initial();

  void hourSelect(int hour) {
    if (hour == state.scheduleHour) {
      state = state.copyWith(scheduleHour: () => null);
    } else {
      state = state.copyWith(scheduleHour: () => hour);
    }
  }

  void dateSelect(List<DateTime> dates) {
    state = state.copyWith(scheduleDate: () => dates);
  }

  void recurrenceTypeSelect(RecurrenceType type) {
    state = state.copyWith(recurrenceType: type);
  }

  void recurrenceEndDateSelect(DateTime date) {
    state = state.copyWith(recurrenceEndDate: () => date);
  }

  Future<void> register({
    required UserModel userModel,
    required PatientModel patient,
    required String appointmentRoom,
  }) async {
    final asyncLoaderHandler = AsyncLoaderHandler()..start();

    final scheduleDates = state.scheduleDate;
    final scheduleHour = state.scheduleHour;
    final recurrenceType = state.recurrenceType;
    final recurrenceEndDate = state.recurrenceEndDate;

    final scheduleRepository = ref.read(scheduleRepositoryProvider);
    final ClinicaModel clinica = await ref.watch(getMyClinicaProvider.future);
    final int clinicaId = clinica.id;

    List<DateTime> dates = [];

    if (recurrenceType == RecurrenceType.none) {
      if (scheduleDates == null || scheduleDates.isEmpty) {
        state = state.copyWith(
          status: ScheduleStateStatus.error,
          errorMessage: 'Selecione pelo menos uma data de agendamento',
        );
        asyncLoaderHandler.close();
        return;
      }
      dates = scheduleDates;
    } else {
      if (scheduleDates == null || scheduleDates.isEmpty) {
        state = state.copyWith(
          status: ScheduleStateStatus.error,
          errorMessage: 'Selecione a data inicial do agendamento',
        );
        asyncLoaderHandler.close();
        return;
      }
      if (recurrenceEndDate == null) {
        state = state.copyWith(
          status: ScheduleStateStatus.error,
          errorMessage: 'Selecione a data final da recorrência',
        );
        asyncLoaderHandler.close();
        return;
      }
      dates = _generateRecurrenceDates(
          scheduleDates.first, recurrenceEndDate, recurrenceType);
    }

    // Passo adicional: Verificar conflitos
    final scheduleResult =
        await scheduleRepository.findScheduleByDate((dates: dates, userId: null));

    if (scheduleResult is Failure) {
      state = state.copyWith(
        status: ScheduleStateStatus.error,
        errorMessage: 'Erro ao verificar disponibilidade',
      );
      asyncLoaderHandler.close();
      return;
    }

    final existingSchedules = (scheduleResult as Success).value;

    for (DateTime date in dates) {
      // Verifica se a sala está ocupada no mesmo horário
      final roomOccupied = existingSchedules.any((schedule) =>
          schedule.dates.contains(date) &&
          schedule.hour == scheduleHour &&
          schedule.appointmentRoom == appointmentRoom);

      if (roomOccupied) {
        // Sala já está ocupada neste horário
        state = state.copyWith(
          status: ScheduleStateStatus.error,
          errorMessage: 'Sala já ocupada neste horário',
        );
        asyncLoaderHandler.close();
        return;
      }

      // Verifica se o profissional já tem um agendamento no mesmo horário
      final therapistBusy = existingSchedules.any((schedule) =>
          schedule.dates.contains(date) &&
          schedule.hour == scheduleHour &&
          schedule.userId == userModel.id);

      if (therapistBusy) {
        // Profissional já tem um agendamento neste horário
        state = state.copyWith(
          status: ScheduleStateStatus.error,
          errorMessage: 'Você já tem um agendamento neste horário',
        );
        asyncLoaderHandler.close();
        return;
      }
    }

    // Se não houver conflitos, prossegue com o agendamento
    final dto = (
      clinicaId: clinicaId,
      userId: userModel.id,
      patient: patient,
      tutor: patient.tutor,
      appointmentRoom: appointmentRoom,
      dates: dates,
      time: scheduleHour!,
    );

    final scheduleCreateResult = await scheduleRepository.schedulePatient(dto);

    if (scheduleCreateResult is Failure) {
      state = state.copyWith(
        status: ScheduleStateStatus.error,
        errorMessage: 'Erro ao registrar agendamento',
      );
      asyncLoaderHandler.close();
      return;
    }

    state = state.copyWith(status: ScheduleStateStatus.success);
    asyncLoaderHandler.close();
  }

  /// Geração de datas recorrentes com base no tipo de recorrência
  List<DateTime> _generateRecurrenceDates(
    DateTime startDate,
    DateTime endDate,
    RecurrenceType recurrenceType,
  ) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;

    while (!currentDate.isAfter(endDate)) {
      dates.add(currentDate);
      switch (recurrenceType) {
        case RecurrenceType.daily:
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case RecurrenceType.weekly:
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case RecurrenceType.monthly:
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
          );
          break;
        case RecurrenceType.none:
          break;
      }
    }
    return dates;
  }
}
