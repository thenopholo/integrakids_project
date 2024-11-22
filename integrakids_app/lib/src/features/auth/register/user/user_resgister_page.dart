import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:validatorless/validatorless.dart';

import '../../../../core/ui/helpers/messages.dart';
import '../../../../core/ui/utils/app_colors.dart';
import '../../../../core/ui/utils/app_font.dart';
import '../../../../core/ui/helpers/form_helper.dart';
import 'user_resgister_vm.dart';

class UserResgisterPage extends ConsumerStatefulWidget {
  const UserResgisterPage({super.key});

  @override
  ConsumerState<UserResgisterPage> createState() => _UserResgisterPageState();
}

class _UserResgisterPageState extends ConsumerState<UserResgisterPage> {
  final formKey = GlobalKey<FormState>();
  final nameEC = TextEditingController();
  final especialidadeEC = TextEditingController();
  final emailEC = TextEditingController();
  final passwordEC = TextEditingController();

  @override
  void dispose() {
    nameEC.dispose();
    emailEC.dispose();
    passwordEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  final userRegisterVm = ref.read(userResgisterVmProvider.notifier);

  ref.listen<UserRegisterStateStatus>(userResgisterVmProvider, (_, state) {
    switch (state) {
      case UserRegisterStateStatus.initial:
        break;
      case UserRegisterStateStatus.loading:
        // Opcional: Mostrar um indicador de carregamento
        break;
      case UserRegisterStateStatus.success:
        Navigator.of(context).pushNamed('/auth/register/create_clinica');
        break;
      case UserRegisterStateStatus.error:
        // Exibir mensagem de erro
        final errorMessage = userRegisterVm.errorMessage;
        Messages.showError(errorMessage ?? 'Erro ao criar conta ADM', context);
        break;
    }
  });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar conta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  onTapOutside: (_) => context.unFocus(),
                  controller: nameEC,
                  validator: Validatorless.required('Nome obrigatório'),
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
                  validator:
                      Validatorless.required('Coloque sua especialidade'),
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
                  validator: Validatorless.multiple([
                    Validatorless.required('Email obrigatório'),
                    Validatorless.email('Email inválido'),
                  ]),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  onTapOutside: (_) => context.unFocus(),
                  controller: passwordEC,
                  validator: Validatorless.multiple([
                    Validatorless.required('Senha obrigatória'),
                    Validatorless.min(
                        6, 'Senha deve ter no mínimo 6 caracteres'),
                  ]),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  onTapOutside: (_) => context.unFocus(),
                  validator: Validatorless.multiple([
                    Validatorless.required('Confirmar senha obrigatória'),
                    Validatorless.compare(
                        passwordEC, 'Senhas não são identicas'),
                  ]),
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                ElevatedButton(
                  onPressed: () {
                    switch (formKey.currentState?.validate()) {
                      case null || false:
                        Messages.showError('Formulário inválido', context);
                      case true:
                        userRegisterVm.register(
                          name: nameEC.text,
                          especialidade: especialidadeEC.text,
                          email: emailEC.text,
                          password: passwordEC.text,
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
                    'Criar conta',
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
