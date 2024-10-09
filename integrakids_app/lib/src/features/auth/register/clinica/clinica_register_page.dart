import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../core/ui/helpers/form_helper.dart';
import '../../../../core/ui/helpers/messages.dart';
import '../../../../core/ui/utils/app_colors.dart';
import '../../../../core/ui/utils/app_font.dart';
import '../../../../core/ui/widgets/hours_panel.dart';
import '../../../../core/ui/widgets/weekdays_panel.dart';
import 'clinica_register_state.dart';
import 'clinica_register_vm.dart';

class ClinicaRegisterPage extends ConsumerStatefulWidget {
  const ClinicaRegisterPage({super.key});

  @override
  ConsumerState<ClinicaRegisterPage> createState() =>
      _ClinicaRegisterPageState();
}

class _ClinicaRegisterPageState extends ConsumerState<ClinicaRegisterPage> {
  final formKey = GlobalKey<FormState>();
  final nameEC = TextEditingController();
  final emailEC = TextEditingController();

  @override
  void dispose() {
    nameEC.dispose();
    emailEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clinicaRegisterVm = ref.watch(clinicaRegisterVmProvider.notifier);

    ref.listen(clinicaRegisterVmProvider, (_, state) {
      switch (state.status) {
        case ClinicaRegisterStatus.initial:
          break;
        case ClinicaRegisterStatus.error:
          Messages.showError('Erro ao cadastrar Cliníca', context);
          break;
        case ClinicaRegisterStatus.success:
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home/adm', (route) => false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Cliníca'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  onTapOutside: (_) => context.unFocus(),
                  controller: nameEC,
                  validator:
                      Validatorless.required('Nome da Cliníca é obrigatório'),
                  decoration: const InputDecoration(
                    label: Text('Nome da Cliníca'),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  onTapOutside: (_) => context.unFocus(),
                  controller: emailEC,
                  validator: Validatorless.multiple([
                    Validatorless.required('Email é obrigatório'),
                    Validatorless.email('Email inválido'),
                  ]),
                  decoration: const InputDecoration(
                    label: Text('Email corporativo'),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                WeekdaysPanel(
                  onDayPressed: (value) {
                    clinicaRegisterVm.addOrRemoveOpenDay(value);
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                HoursPanel(
                  startTime: 6,
                  endTime: 23,
                  onTimePressed: (int value) {
                    clinicaRegisterVm.addOrRemoveOpenHours(value);
                  },
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  onPressed: () {
                    switch (formKey.currentState?.validate()) {
                      case false || null:
                        Messages.showError('Formulário Inválido', context);
                      case true:
                        clinicaRegisterVm.register(
                          nameEC.text,
                          emailEC.text,
                        );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.integraOrange,
                    minimumSize: const Size.fromHeight(56),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black,
                  ),
                  child: const Text(
                    'Cadastrar Cliníca',
                    style: TextStyle(
                      fontFamily: AppFont.primaryFont,
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
