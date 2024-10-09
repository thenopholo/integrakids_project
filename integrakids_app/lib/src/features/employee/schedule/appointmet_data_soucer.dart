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
      // Itera sobre as múltiplas datas em `e.dates`
      return e.dates.map((date) {
        final startTime =
            DateTime(date.year, date.month, date.day, e.hour, 0, 0);
        final endTime =
            DateTime(date.year, date.month, date.day, e.hour + 1, 0, 0);

        final color = e.appointmentRoom == 'Sala 1'
            ? AppColors.integraBrown
            : AppColors.integraOrange;

        return Appointment(
          color: color,
          startTime: startTime,
          endTime: endTime,
          subject:
              '${e.patient.name} Sala: ${e.appointmentRoom}\nTutor: ${e.tutor.name}',
        );
      }).toList(); // Retorna uma lista de `Appointment` para cada data
    }).toList();
  }
}
