import 'dart:io';

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:validatorless/validatorless.dart';

import '../../core/ui/helpers/messages.dart';
import '../../core/ui/utils/app_colors.dart';
import '../../core/ui/utils/app_font.dart';
import '../../core/ui/widgets/avatar_widget.dart';

import '../../core/ui/widgets/integrakids_icons.dart';
import '../../model/patient_model.dart';

import '../../model/user_model.dart';
import 'schedule_state.dart';
import 'schedule_vm.dart';


class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});
  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  var dateFormat = DateFormat('dd/MM/yyyy');
  var showCalendar = false;
  final formKey = GlobalKey<FormState>();
  final patientEC = TextEditingController();
  final tutorsNameEC = TextEditingController();
  final tutorsPhoneEC = TextEditingController();
  final appointmentRoomEC = TextEditingController();
  final dateEC = TextEditingController();
  final recurrenceEndDateEC = TextEditingController();
  RecurrenceType recurrenceType = RecurrenceType.none;
  TimeOfDay? _selectedTime; // For Android
  DateTime? _selectedTimeIOS;

  @override
  void dispose() {
    patientEC.dispose();
    tutorsNameEC.dispose();
    tutorsPhoneEC.dispose();
    appointmentRoomEC.dispose();
    dateEC.dispose();
    recurrenceEndDateEC.dispose();
    super.dispose();
  }

  String _getFormattedTime() {
    if (Platform.isIOS) {
      if (_selectedTimeIOS != null) {
        final hours = _selectedTimeIOS!.hour.toString().padLeft(2, '0');
        final minutes = _selectedTimeIOS!.minute.toString().padLeft(2, '0');
        return '$hours:$minutes';
      } else {
        return 'Horário de atendimento';
      }
    } else {
      if (_selectedTime != null) {
        final hours = _selectedTime!.hour.toString().padLeft(2, '0');
        final minutes = _selectedTime!.minute.toString().padLeft(2, '0');
        return '$hours:$minutes';
      } else {
        return 'Horário de atendimento';
      }
    }
  }

  int _getSelectedHour() {
    if (Platform.isIOS) {
      return _selectedTimeIOS?.hour ?? DateTime.now().hour;
    } else {
      return _selectedTime?.hour ?? TimeOfDay.now().hour;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userModel = ModalRoute.of(context)!.settings.arguments as UserModel;
    final scheduleVM = ref.watch(scheduleVmProvider.notifier);
    final employeeData = switch (userModel) {
      UserModelADM(:final workDays, :final workHours) => (
          workDays: workDays!,
          workHours: workHours!,
        ),
      UserModelEmployee(:final workDays, :final workHours) => (
          workDays: workDays,
          workHours: workHours,
        ),
    };

    ref.listen<ScheduleState>(
      scheduleVmProvider,
      (_, state) {
        switch (state.status) {
          case ScheduleStateStatus.initial:
            break;
          case ScheduleStateStatus.success:
            Messages.showSuccess('Agendamento realizado com sucesso', context);
            Navigator.of(context).pop();
            break;
          case ScheduleStateStatus.error:
            if (state.errorMessage != null) {
              Messages.showError(state.errorMessage!, context);
            } else {
              Messages.showError('Erro ao registrar agendamento', context);
            }
            break;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Paciente'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Form(
            key: formKey,
            child: Center(
              child: Column(
                children: [
                  const AvatarWidget(hideUploadButton: true),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    userModel.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: patientEC,
                    validator:
                        Validatorless.required('Nome do paciente obrigatório'),
                    decoration:
                        const InputDecoration(label: Text('Nome do Paciente')),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: tutorsNameEC,
                    validator:
                        Validatorless.required('Nome do turo é obrigatório'),
                    decoration:
                        const InputDecoration(label: Text('Nome do Tutor')),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter(),
                    ],
                    controller: tutorsPhoneEC,
                    validator: Validatorless.required('Contato é obrigatório'),
                    decoration:
                        const InputDecoration(label: Text('Contato do Tutor')),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  DropdownButtonFormField<String>(
                    value: appointmentRoomEC.text.isNotEmpty
                        ? appointmentRoomEC.text
                        : null, // Valor inicial do dropdown
                    validator: Validatorless.required(
                        'Selecione uma sala de atendimento'),
                    decoration: const InputDecoration(
                      labelText: 'Sala de Atendimento',
                    ),
                    items: ['Sala 1', 'Sala 2'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        appointmentRoomEC.text = newValue!;
                      });
                    },
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    readOnly: true,
                    controller: dateEC,
                    validator: Validatorless.required(
                        'Selecione a data do agendamento'),
                    onTap: () async {
                      if (recurrenceType == RecurrenceType.none) {
                        // Permitir seleção múltipla de datas
                        List<DateTime> selectedDates =
                            ref.read(scheduleVmProvider).scheduleDate ?? [];
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Selecione as datas'),
                              content: SizedBox(
                                height: 400,
                                width: 300,
                                child: SfDateRangePicker(
                                  view: DateRangePickerView.month,
                                  selectionMode:
                                      DateRangePickerSelectionMode.multiple,
                                  initialSelectedDates: selectedDates,
                                  onSelectionChanged:
                                      (DateRangePickerSelectionChangedArgs
                                          args) {
                                    if (args.value is List<DateTime>) {
                                      selectedDates = args.value;
                                    }
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('CANCELAR'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('CONFIRMAR'),
                                  onPressed: () {
                                    setState(() {
                                      dateEC.text = selectedDates
                                          .map(
                                              (date) => dateFormat.format(date))
                                          .join(', ');
                                      scheduleVM.dateSelect(selectedDates);
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        // Permitir seleção de uma única data inicial
                        DateTime? selectedDate =
                            ref.read(scheduleVmProvider).scheduleDate?.first;
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Selecione a data inicial'),
                              content: SizedBox(
                                height: 400,
                                width: 300,
                                child: SfDateRangePicker(
                                  view: DateRangePickerView.month,
                                  selectionMode:
                                      DateRangePickerSelectionMode.single,
                                  initialSelectedDate:
                                      selectedDate ?? DateTime.now(),
                                  onSelectionChanged:
                                      (DateRangePickerSelectionChangedArgs
                                          args) {
                                    if (args.value is DateTime) {
                                      selectedDate = args.value;
                                    }
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('CANCELAR'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('CONFIRMAR'),
                                  onPressed: () {
                                    if (selectedDate != null) {
                                      setState(() {
                                        dateEC.text =
                                            dateFormat.format(selectedDate!);
                                        scheduleVM.dateSelect([selectedDate!]);
                                      });
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    decoration: const InputDecoration(
                      label: Text('Selecione a data'),
                      hintText: 'Selecione a data',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      suffixIcon: Icon(
                        IntegrakidsIcons.calendar,
                        color: AppColors.integraBrown,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  DropdownButtonFormField<RecurrenceType>(
                    value: recurrenceType,
                    onChanged: (RecurrenceType? newValue) {
                      setState(() {
                        recurrenceType = newValue!;
                        scheduleVM.recurrenceTypeSelect(newValue);
                      });
                    },
                    items: RecurrenceType.values.map((RecurrenceType type) {
                      String text;
                      switch (type) {
                        case RecurrenceType.none:
                          text = 'Nenhuma';
                          break;
                        case RecurrenceType.daily:
                          text = 'Diária';
                          break;
                        case RecurrenceType.weekly:
                          text = 'Semanal';
                          break;
                        case RecurrenceType.monthly:
                          text = 'Mensal';
                          break;
                      }
                      return DropdownMenuItem<RecurrenceType>(
                        value: type,
                        child: Text(text),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: 'Recorrência',
                    ),
                  ),
                  if (recurrenceType != RecurrenceType.none) ...[
                    const SizedBox(height: 24),
                    TextFormField(
                      readOnly: true,
                      controller: recurrenceEndDateEC,
                      validator: Validatorless.required(
                          'Selecione a data final da recorrência'),
                      onTap: () async {
                        DateTime? selectedEndDate =
                            ref.read(scheduleVmProvider).recurrenceEndDate;
                        await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text(
                                  'Selecione a data final da recorrência'),
                              content: SizedBox(
                                height: 400,
                                width: 300,
                                child: SfDateRangePicker(
                                  selectionMode:
                                      DateRangePickerSelectionMode.single,
                                  initialSelectedDate:
                                      selectedEndDate ?? DateTime.now(),
                                  minDate: ref
                                          .read(scheduleVmProvider)
                                          .scheduleDate
                                          ?.first ??
                                      DateTime.now(),
                                  onSelectionChanged:
                                      (DateRangePickerSelectionChangedArgs
                                          args) {
                                    if (args.value is DateTime) {
                                      selectedEndDate = args.value as DateTime;
                                    }
                                  },
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('CANCELAR'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text('CONFIRMAR'),
                                  onPressed: () {
                                    if (selectedEndDate != null) {
                                      setState(() {
                                        recurrenceEndDateEC.text =
                                            dateFormat.format(selectedEndDate!);
                                        scheduleVM.recurrenceEndDateSelect(
                                            selectedEndDate!);
                                      });
                                    }
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      decoration: const InputDecoration(
                        label: Text('Data Final da Recorrência'),
                        hintText: 'Selecione a data final',
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        suffixIcon: Icon(
                          Icons.calendar_today,
                          color: AppColors.integraBrown,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(
                    height: 24,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.bgFormInput,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        if (Platform.isIOS) {
                          DateTime tempPickedDate =
                              _selectedTimeIOS ?? DateTime.now();
                          await showModalBottomSheet(
                            backgroundColor: Colors.transparent,
                            context: context,
                            builder: (context) {
                              return CupertinoActionSheet(
                                actions: [
                                  SizedBox(
                                    height: 180,
                                    child: CupertinoDatePicker(
                                      mode: CupertinoDatePickerMode.time,
                                      initialDateTime:
                                          _selectedTimeIOS ?? DateTime.now(),
                                      onDateTimeChanged:
                                          (DateTime newDateTime) {
                                        tempPickedDate = newDateTime;
                                      },
                                    ),
                                  ),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () {
                                    setState(() {
                                      _selectedTimeIOS = tempPickedDate;
                                      scheduleVM.timeSelect(
                                        TimeOfDay(
                                          hour: _selectedTimeIOS!.hour,
                                          minute: _selectedTimeIOS!.minute,
                                        ),
                                      );
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Confirmar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppColors.integraOrange,
                                      fontFamily: AppFont.primaryFont,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          final selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            initialEntryMode: TimePickerEntryMode.input,
                            cancelText: 'Cancelar',
                            confirmText: 'Confirmar',
                          );
                          if (selectedTime != null) {
                            setState(() {
                              _selectedTime = selectedTime;
                              scheduleVM.timeSelect(selectedTime);
                            });
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getFormattedTime(),
                              style: const TextStyle(
                                color: AppColors.integraOrange,
                                fontFamily: AppFont.primaryFont,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Icon(
                              Icons.watch_later_outlined,
                              color: AppColors.integraBrown,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // HoursPanel.singleSelection(
                  //   startTime: 6,
                  //   endTime: 23,
                  //   onTimePressed: scheduleVM.hourSelect,
                  //   enableHours: employeeData.workHours,
                  // ),
                  const SizedBox(
                    height: 24,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Validação do formulário
                      if (formKey.currentState?.validate() != true) {
                        Messages.showError('Dados incompletos', context);
                        return;
                      }

                      final scheduleVmState = ref.read(scheduleVmProvider);

                      // Verifica se um horário foi selecionado
                      if (scheduleVmState.scheduleTime == null) {
                        Messages.showError(
                            'Selecione um horário de atendimento', context);
                        return;
                      }

                      // Verifica se pelo menos uma data foi selecionada
                      if (scheduleVmState.scheduleDate == null ||
                          scheduleVmState.scheduleDate!.isEmpty) {
                        Messages.showError(
                            'Selecione pelo menos uma data de agendamento',
                            context);
                        return;
                      }

                      // Se uma recorrência foi selecionada, verifica se a data final foi fornecida
                      if (recurrenceType != RecurrenceType.none &&
                          scheduleVmState.recurrenceEndDate == null) {
                        Messages.showError(
                            'Selecione a data final da recorrência', context);
                        return;
                      }

                      // Chama o método para registrar o agendamento
                      scheduleVM.register(
                        userModel: userModel,
                        patient: PatientModel.fromMap({
                          'patientName': patientEC.text,
                          'tutorsName': tutorsNameEC.text,
                          'tutorsPhone': tutorsPhoneEC.text,
                        }),
                        appointmentRoom: appointmentRoomEC.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      backgroundColor: AppColors.integraOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                      shadowColor: Colors.black,
                    ),
                    child: const Text('Agendar'),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
