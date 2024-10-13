import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/exceptions/repository_exception.dart';
import '../../../core/fp/either.dart';
import '../../../core/providers/app_providers.dart';
import '../../../model/schedule_model.dart';

part 'employee_schedule_vm.g.dart';

@riverpod
class EmployeeScheduleVm extends _$EmployeeScheduleVm {
  Future<Either<RepositoryException, List<ScheduleModel>>> _getSchedules(
      String userId, List<DateTime> dates) {  // Alterado para aceitar uma lista de datas
    final repository = ref.read(scheduleRepositoryProvider);
    return repository.findScheduleByDate((dates: dates, userId: userId));
  }

  @override
  Future<List<ScheduleModel>> build(String userId, DateTime date) async {
    // Cria uma lista de datas com a única data
    final scheduleListResult = await _getSchedules(userId, [date]);
    return switch (scheduleListResult) {
      Success(value: final schedules) => schedules,
      Failure(:final exception) => throw Exception(exception),
    };
  }

  Future<void> changeDate(String userId, DateTime date) async {
    final scheduleListResult = await _getSchedules(userId, [date]);  // Enviando a lista com a única data
    state = switch (scheduleListResult) {
      Success(value: final schedules) => AsyncData(schedules),
      Failure(:final exception) =>
        AsyncError(Exception(exception), StackTrace.current),
    };
  }
}
