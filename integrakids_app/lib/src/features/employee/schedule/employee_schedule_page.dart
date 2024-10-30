import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../core/ui/utils/app_colors.dart';
import '../../../core/ui/utils/app_font.dart';
import '../../../core/ui/widgets/integrakids_loader.dart';
import '../../../model/user_model.dart';
import 'appointmet_data_soucer.dart';
import 'employee_schedule_vm.dart';

class EmployeeSchedulePage extends ConsumerStatefulWidget {
  const EmployeeSchedulePage({super.key});

  @override
  ConsumerState<EmployeeSchedulePage> createState() =>
      _EmployeeSchedulePageState();
}

class _EmployeeSchedulePageState extends ConsumerState<EmployeeSchedulePage> {
  late DateTime selectedDate;
  var ignoreFirstLoad = true;

  @override
  void initState() {
    final DateTime(:year, :month, :day) = DateTime.now();
    selectedDate = DateTime(year, month, day, 0, 0, 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final UserModel(id: userId, :name) =
        ModalRoute.of(context)!.settings.arguments as UserModel;

    final scheduleAsync =
        ref.watch(employeeScheduleVmProvider(userId, selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      body: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 34,
          ),
          scheduleAsync.when(
            loading: () => const IntegrakidsLoader(),
            error: (error, stackTrace) {
              log('Erro ao carregar agendamentos',
                  error: error, stackTrace: stackTrace);
              return const Center(child: Text('Erro ao carregar agendamentos'));
            },
            data: (schedules) {
              return Expanded(
                child: SfCalendar(
                  view: CalendarView.workWeek,
                  allowAppointmentResize: true,
                  allowViewNavigation: true,
                  showNavigationArrow: true,
                  todayHighlightColor: AppColors.integraOrange,
                  showDatePickerButton: true,
                  showTodayButton: true,
                  dataSource: AppointmetDataSoucer(schedules: schedules),
                  onViewChanged: (viewChangedDetails) {
                    if (ignoreFirstLoad) {
                      ignoreFirstLoad = false;
                      return;
                    }
                    ref
                        .read(employeeScheduleVmProvider(userId, selectedDate)
                            .notifier)
                        .changeDate(
                          userId,
                          viewChangedDetails.visibleDates.first,
                        );
                  },
                  onTap: (calendarTapDetails) {
                    if (calendarTapDetails.appointments != null &&
                        calendarTapDetails.appointments!.isNotEmpty) {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
                            return SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor:
                                              AppColors.integraBrown,
                                          child: Text(
                                            calendarTapDetails
                                                .appointments?.first.subject[0],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 16,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Paciente: ${calendarTapDetails.appointments?.first.subject}',
                                              style: const TextStyle(
                                                fontFamily: AppFont.primaryFont,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              'Horario: ${dateFormat.format(calendarTapDetails.date ?? DateTime.now())}',
                                              style: const TextStyle(
                                                fontFamily: AppFont.primaryFont,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {},
                                      child: const Text(
                                          'Enviar confirmação da consulta'),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
