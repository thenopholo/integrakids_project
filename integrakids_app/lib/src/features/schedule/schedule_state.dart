import 'package:flutter/material.dart';

enum ScheduleStateStatus { initial, success, error }

enum RecurrenceType { none, daily, weekly, monthly }

class ScheduleState {
  final ScheduleStateStatus status;
  final int? scheduleHour;
  final List<DateTime>? scheduleDate;
  final DateTime? recurrenceEndDate;
  final RecurrenceType recurrenceType;
  final String? errorMessage;


  ScheduleState.initial()
      : this(
          status: ScheduleStateStatus.initial,
          recurrenceType: RecurrenceType.none,
        );
  ScheduleState({
    required this.status,
    this.scheduleHour,
    this.scheduleDate,
    this.recurrenceEndDate,
    this.recurrenceType = RecurrenceType.none,
    this.errorMessage,
  });

  
  ScheduleState copyWith({
    ScheduleStateStatus? status,
    ValueGetter<int?>? scheduleHour,
    ValueGetter<List<DateTime>?>? scheduleDate,
    ValueGetter<DateTime?>? recurrenceEndDate,
    RecurrenceType? recurrenceType,
    String? errorMessage,
  }) {
    return ScheduleState(
      status: status ?? this.status,
      scheduleHour: scheduleHour != null ? scheduleHour() : this.scheduleHour,
      scheduleDate: scheduleDate != null ? scheduleDate() : this.scheduleDate,
      recurrenceEndDate: recurrenceEndDate != null
          ? recurrenceEndDate()
          : this.recurrenceEndDate,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
