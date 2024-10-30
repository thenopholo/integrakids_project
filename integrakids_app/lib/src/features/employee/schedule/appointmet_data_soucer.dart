// appontment_data_souce.dart

import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../core/ui/utils/app_colors.dart';
import '../../../model/schedule_model.dart';

class AppointmetDataSoucer extends CalendarDataSource {
  final List<ScheduleModel> schedules;

  AppointmetDataSoucer({
    required this.schedules,
  });

  @override
  List<dynamic>? get appointments {
    return schedules.expand((e) {
      // Itera sobre as múltiplas datas em e.dates
      return e.dates.map((dateTime) {
        final startTime = dateTime;
        final endTime =
            startTime.add(const Duration(hours: 1)); // Duração de 1 hora

        final color = e.appointmentRoom == 'Sala 1'
            ? AppColors.integraBrown
            : AppColors.integraOrange;

        return Appointment(
          color: color,
          startTime: startTime,
          endTime: endTime,
          subject:
              '${e.patient.name} - Sala: ${e.appointmentRoom}\nTutor: ${e.tutor.name}',
        );
      }).toList();
    }).toList();
  }
}
