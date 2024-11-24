import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/fp/either.dart';
import '../../../core/providers/app_providers.dart';

part 'home_employee_provider.g.dart';

@riverpod
Future<int> getTotalSchedulesToday(
    GetTotalSchedulesTodayRef ref, String userId) async {
  final DateTime now = DateTime.now();
  final filter = (dates: [now], userId: userId);  // Passa uma lista com a data atual

  final schedulerepository = ref.read(scheduleRepositoryProvider);
  final scheduleResult = await schedulerepository.findScheduleByDate(filter);

  return switch (scheduleResult) {
    Success(value: List(length: final totalSchedules)) => totalSchedules,
    Failure(:final exception) => throw exception,
  };
}
