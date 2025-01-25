import 'package:asyncstate/asyncstate.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/fp/either.dart';
import '../../core/providers/app_providers.dart';
import '../../model/clinica_model.dart';
import '../../model/patient_model.dart';
import '../../model/schedule_model.dart';
import '../../model/user_model.dart';
import 'schedule_state.dart';

part 'schedule_vm.g.dart';

@riverpod
class ScheduleVm extends _$ScheduleVm {
  @override
  ScheduleState build() => ScheduleState.initial();

  void timeSelect(TimeOfDay time) {
    if (time == state.scheduleTime) {
      state = state.copyWith(scheduleTime: () => null);
    } else {
      state = state.copyWith(scheduleTime: () => time);
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
  final scheduleTime = state.scheduleTime;
  final recurrenceType = state.recurrenceType;
  final recurrenceEndDate = state.recurrenceEndDate;

  if (scheduleTime == null ||
      scheduleDates == null ||
      scheduleDates.isEmpty) {
    state = state.copyWith(
      status: ScheduleStateStatus.error,
      errorMessage: 'Por favor, selecione data e hora para o agendamento.',
    );
    asyncLoaderHandler.close();
    return;
  }

  // Atualiza a variável dates diretamente com as datas combinadas
  List<DateTime> dates = scheduleDates.map((dates) {
    return DateTime(
      dates.year,
      dates.month,
      dates.day,
      scheduleTime.hour,
      scheduleTime.minute,
    );
  }).toList();

  if (recurrenceType != RecurrenceType.none) {
    if (recurrenceEndDate == null) {
      state = state.copyWith(
        status: ScheduleStateStatus.error,
        errorMessage: 'Selecione a data final da recorrência',
      );
      asyncLoaderHandler.close();
      return;
    }
    dates = _generateRecurrenceDates(
        dates.first, recurrenceEndDate, recurrenceType);
  }

  // Passo adicional: Verificar conflitos
  final scheduleRepository = ref.read(scheduleRepositoryProvider);
  final ClinicaModel clinica = await ref.watch(getMyClinicaProvider.future);
  final String clinicaId = clinica.id;

  final scheduleResult = await scheduleRepository
      .findScheduleByDate((dates: dates, userId: null));

  if (scheduleResult is Failure) {
    state = state.copyWith(
      status: ScheduleStateStatus.error,
      errorMessage: 'Erro ao verificar disponibilidade',
    );
    asyncLoaderHandler.close();
    return;
  }

  final existingSchedules = (scheduleResult as Success).value;

// Converte o horário selecionado em minutos totais
  final selectedTimeMinutes = (state.scheduleTime?.hour ?? 0) * 60 +
      (state.scheduleTime?.minute ?? 0);

  for (DateTime date in dates) {
    // Verifica se a sala está ocupada no mesmo horário
    final roomOccupied = _isRoomOccupied(
      existingSchedules,
      date,
      selectedTimeMinutes,
      appointmentRoom,
    );

    if (roomOccupied) {
      state = state.copyWith(
        status: ScheduleStateStatus.error,
        errorMessage: 'Sala já ocupada neste horário',
      );
      asyncLoaderHandler.close();
      return;
    }

    // Verifica se o profissional já tem um agendamento no mesmo horário
    final therapistBusy = _isTherapistBusy(
      existingSchedules,
      date,
      selectedTimeMinutes,
      userModel.id,
    );

    if (therapistBusy) {
      state = state.copyWith(
        status: ScheduleStateStatus.error,
        errorMessage: '${userModel.name} já tem um agendamento neste horário',
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
    time: scheduleTime, // Agora é do tipo TimeOfDay
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




  bool _isRoomOccupied(
    List<ScheduleModel> schedules,
    DateTime date,
    int selectedTimeMinutes,
    String appointmentRoom,
  ) {
    for (var schedule in schedules) {
      final scheduleDate = schedule.dates.firstWhere(
          (d) => _isSameDate(d, date),
          orElse: () => DateTime.now());
      final scheduleTimeMinutes = schedule.hour * 60 + schedule.minute;

      if (_isSameDate(scheduleDate, date) &&
          scheduleTimeMinutes == selectedTimeMinutes &&
          schedule.appointmentRoom == appointmentRoom) {
        return true;
      }
    }
    return false;
  }

  bool _isTherapistBusy(
    List<ScheduleModel> schedules,
    DateTime date,
    int selectedTimeMinutes,
    String userId,
  ) {
    for (var schedule in schedules) {
      final scheduleDate = schedule.dates.firstWhere(
          (d) => _isSameDate(d, date),
          orElse: () => DateTime.now());
      final scheduleTimeMinutes = schedule.hour * 60 + schedule.minute;

      if (_isSameDate(scheduleDate, date) &&
          scheduleTimeMinutes == selectedTimeMinutes &&
          schedule.userId == userId) {
        return true;
      }
    }
    return false;
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
