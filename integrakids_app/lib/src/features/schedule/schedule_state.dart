import 'package:flutter/material.dart';

enum ScheduleStateStatus { initial, success, error }
enum RecurrenceType { none, daily, weekly, monthly }

class ScheduleState {
  final ScheduleStateStatus status;
  final TimeOfDay? scheduleTime;  // Hora e minuto do agendamento
  final List<DateTime>? scheduleDate; // Datas selecionadas para o agendamento
  final DateTime? recurrenceEndDate; // Data final da recorrência
  final RecurrenceType recurrenceType; // Tipo de recorrência
  final String? errorMessage; // Mensagem de erro para o estado

  // Construtor inicial
  ScheduleState.initial()
      : this(
          status: ScheduleStateStatus.initial,
          recurrenceType: RecurrenceType.none,
        );

  ScheduleState({
    required this.status,
    this.scheduleTime,
    this.scheduleDate,
    this.recurrenceEndDate,
    this.recurrenceType = RecurrenceType.none,
    this.errorMessage,
  });

  // Método copyWith para atualizar o estado com valores novos
  ScheduleState copyWith({
    ScheduleStateStatus? status,
    ValueGetter<TimeOfDay?>? scheduleTime,
    ValueGetter<List<DateTime>?>? scheduleDate,
    ValueGetter<DateTime?>? recurrenceEndDate,
    RecurrenceType? recurrenceType,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      scheduleTime: scheduleTime != null ? scheduleTime() : this.scheduleTime,
      scheduleDate: scheduleDate != null ? scheduleDate() : this.scheduleDate,
      recurrenceEndDate:
          recurrenceEndDate != null ? recurrenceEndDate() : this.recurrenceEndDate,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
