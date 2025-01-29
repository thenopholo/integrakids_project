import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/ui/helpers/form_helper.dart';
import '../../../core/ui/helpers/messages.dart';
import '../../../core/ui/utils/app_colors.dart';
import '../../../core/ui/utils/app_font.dart';
import '../../../core/ui/widgets/avatar_widget.dart';
import '../../../core/ui/widgets/hours_panel.dart';
import '../../../core/ui/widgets/integrakids_loader.dart';
import '../../../core/ui/widgets/weekdays_panel.dart';
import '../../../model/clinica_model.dart';
import '../../../model/user_model.dart';
import '../../home/adm/widgets/home_adm_vm.dart';
import 'employee_register_state.dart';
import 'employee_register_vm.dart';

class EmployeeResgisterPage extends ConsumerStatefulWidget {
  final UserModel? employee;
  const EmployeeResgisterPage({super.key, this.employee});

  @override
  ConsumerState<EmployeeResgisterPage> createState() =>
      _EmployeeResgisterPageState();
}

class _EmployeeResgisterPageState extends ConsumerState<EmployeeResgisterPage> {
  var registerADM = false;
  var isEditing = false;
  final formKey = GlobalKey<FormState>();
  final nameEC = TextEditingController();
  final especialidadeEC = TextEditingController();
  final emailEC = TextEditingController();
  final passwordEC = TextEditingController();
  final adminPasswordEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      nameEC.text = widget.employee!.name;
      especialidadeEC.text = widget.employee!.especialidade;
      emailEC.text = widget.employee!.email;

      // Atualizar o estado do ViewModel com os dias e horários de trabalho
      // final employeeRegisterVm = ref.read(employeeRegisterVmProvider.notifier);
      // employeeRegisterVm.setWorkDays(widget.employee!.workDays);
      // employeeRegisterVm.setWorkHours(widget.employee!.workHours);
    }
  }

  @override
  void dispose() {
    nameEC.dispose();
    especialidadeEC.dispose();
    emailEC.dispose();
    passwordEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeeRegisterVm = ref.watch(employeeRegisterVmProvider.notifier);
    final clinicaAsyncValue = ref.watch(getMyClinicaProvider);
    final isEditing = widget.employee != null;

    ref.listen(employeeRegisterVmProvider.select((state) => state.status),
        (_, status) {
      switch (status) {
        case EmployeeRegisterStateStatus.initial:
          break;
        case EmployeeRegisterStateStatus.success:
          final message = isEditing
              ? 'Terapeuta atualizado com sucesso'
              : 'Terapeuta cadastrado com sucesso';
          Messages.showSuccess(message, context);
          ref.invalidate(homeAdmVmProvider);
          ref.invalidate(getMeProvider);
          Navigator.of(context).pop();
          break;
        case EmployeeRegisterStateStatus.error:
          final message = isEditing
              ? 'Erro ao editar terapeuta'
              : 'Erro ao registrar terapeuta';
          Messages.showError(message, context);
          break;
        case EmployeeRegisterStateStatus.loading:
          const IntegrakidsLoader();
          break;
      }
    });

    return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Editar Terapeuta' : 'Cadastrar Terapeuta'),
        ),
        body: clinicaAsyncValue.when(
          error: (error, stackTrace) {
            log('Erro ao carregar a página',
                error: error, stackTrace: stackTrace);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Erro ao carregar a página'),
                  ElevatedButton(
                    onPressed: () => ref.refresh(getMyClinicaProvider),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          },
          loading: () => const IntegrakidsLoader(),
          data: (clinicaModel) {
            final ClinicaModel(:openDays, :openHours) = clinicaModel;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Form(
                  key: formKey,
                  child: Center(
                    child: Column(
                      children: [
                        const AvatarWidget(),
                        const SizedBox(
                          height: 32,
                        ),
                        Row(
                          children: [
                            Checkbox.adaptive(
                                value: registerADM,
                                onChanged: (value) {
                                  setState(() {
                                    registerADM = !registerADM;
                                    employeeRegisterVm
                                        .setRegisterADM(registerADM);
                                  });
                                }),
                            const Expanded(
                              child: Text(
                                'Sou administrador e quero me cadastrar como terapeuta',
                                style: TextStyle(
                                  fontFamily: AppFont.primaryFont,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Offstage(
                          offstage: registerADM,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 24,
                              ),
                              TextFormField(
                                onTapOutside: (_) => context.unFocus(),
                                controller: nameEC,
                                validator: registerADM
                                    ? null
                                    : Validatorless.required(
                                        'Nome obrigatório'),
                                decoration: const InputDecoration(
                                  labelText: 'Nome',
                                ),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              TextFormField(
                                onTapOutside: (_) => context.unFocus(),
                                controller: especialidadeEC,
                                validator: registerADM
                                    ? null
                                    : Validatorless.required(
                                        'Especialidade obrigatória'),
                                decoration: const InputDecoration(
                                  labelText: 'Especialidade',
                                ),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              TextFormField(
                                onTapOutside: (_) => context.unFocus(),
                                controller: emailEC,
                                validator: registerADM
                                    ? null
                                    : Validatorless.multiple([
                                        Validatorless.required(
                                            'Email obrigatório'),
                                        Validatorless.email('Email inválido'),
                                      ]),
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                ),
                              ),
                              const SizedBox(
                                height: 24,
                              ),
                              Offstage(
                                offstage: isEditing,
                                child: Column(
                                  children: [
                                    TextFormField(
                                      onTapOutside: (_) => context.unFocus(),
                                      controller: passwordEC,
                                      validator: registerADM || isEditing
                                          ? null
                                          : Validatorless.multiple([
                                              Validatorless.required(
                                                  'Senha obrigatória'),
                                              Validatorless.min(6,
                                                  'Senha deve ter no mínimo 6 caracteres'),
                                            ]),
                                      obscureText: true,
                                      decoration: const InputDecoration(
                                        labelText: 'Senha',
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 24,
                                    ),
                                  ],
                                ),
                              ),
                              TextFormField(
                                onTapOutside: (_) => context.unFocus(),
                                controller: adminPasswordEC,
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Senha do administrador obrigatória';
                                  }
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Senha do Administrador',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        WeekdaysPanel(
                          enableDays: openDays,
                          onDayPressed: employeeRegisterVm.addOrRemoveWorkDays,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        HoursPanel(
                          enableHours: openHours,
                          startTime: 6,
                          endTime: 23,
                          onTimePressed:
                              employeeRegisterVm.addOrRemoveWorkHours,
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() ?? false) {
                              final employeeState =
                                  ref.watch(employeeRegisterVmProvider);
                              final hasWorkDays =
                                  employeeState.workDays.isNotEmpty;
                              final hasWorkHours =
                                  employeeState.workHours.isNotEmpty;

                              if (!hasWorkDays || !hasWorkHours) {
                                Messages.showError(
                                  'Selecione pelo menos um dia e um horário de trabalho',
                                  context,
                                );
                                return;
                              }

                              final name = nameEC.text;
                              final especialidade = especialidadeEC.text;
                              final email = emailEC.text;
                              final password = passwordEC.text;
                              final adminPassword = adminPasswordEC.text;

                              if (isEditing) {
                                final id = widget.employee!.id;

                                employeeRegisterVm.edit(
                                  id: id,
                                  name: name,
                                  especialidade: especialidade,
                                  email: email,
                                  password: password,
                                );
                              } else {
                                employeeRegisterVm.register(
                                  name: name,
                                  especialidade: especialidade,
                                  email: email,
                                  password: password,
                                  adminPassword: adminPassword,
                                );
                              }
                            } else {
                              Messages.showError(
                                  'Existem campos inválidos', context);
                            }
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
                          child: Text(isEditing
                              ? 'Salvar Alterações'
                              : 'Cadastrar Terapeuta'),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
