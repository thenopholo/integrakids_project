import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/fp/either.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/ui/utils/app_colors.dart';
import '../../../../core/ui/utils/app_font.dart';
import '../../../../core/ui/utils/app_images.dart';
import '../../../../core/ui/widgets/integrakids_icons.dart';
import '../../../../model/user_model.dart';
import 'home_adm_vm.dart';

class HomeEmployeeTile extends ConsumerWidget {
  final UserModel employee;
  const HomeEmployeeTile({super.key, required this.employee});

  void _confirmDelete(
      BuildContext context, WidgetRef ref, UserModelEmployee employee) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tem certeza que deseja excluir esse terapeuta?'),
          content: const Text(
              'Essa ação não pode ser revertida. Todos os dados do terapeuta serão perdidos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Excluir',
                style: TextStyle(color: AppColors.erroRed),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      final userRepository = ref.read(userRepositorieProvider);
      final result = await userRepository.deleteEmployee(employee.id);

      switch (result) {
        case Failure(exception: final exception):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Erro ao excluir funcionário: ${exception.message}'),
            ),
          );
          break;
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Funcionário excluído com sucesso!'),
            ),
          );
          ref.invalidate(homeAdmVmProvider);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      height: 130,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.integraOrange),
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(5, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: switch (employee.avatar) {
                  final avatar? => NetworkImage(avatar),
                  _ => const AssetImage(AppImages.avatar),
                } as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    employee.name,
                    style: const TextStyle(
                      color: AppColors.integraOrange,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFont.primaryFont,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppColors.integraBrown,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      employee.especialidade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFont.primaryFont,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed('/schedule', arguments: employee);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.integraOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black,
                      ),
                      child: const Text(
                        'Agendar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFont.primaryFont,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/employee/schedule',
                            arguments: employee);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                          color: AppColors.integraOrange,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black,
                      ),
                      child: const Text(
                        'Ver Agenda',
                        style: TextStyle(
                          color: AppColors.integraOrange,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppFont.primaryFont,
                        ),
                      ),
                    ),
                    Flexible(
                      child: IconButton(
                        onPressed: () async {
                          await Navigator.of(context).pushNamed(
                            '/employee/register',
                            arguments: employee,
                          );
                          ref.invalidate(getMeProvider);
                          ref.invalidate(homeAdmVmProvider);
                        },
                        icon: const Icon(
                          IntegrakidsIcons.penEdit,
                          size: 16,
                          color: AppColors.integraOrange,
                        ),
                      ),
                    ),
                    Flexible(
                      child: IconButton(
                        onPressed: () {
                          _confirmDelete(
                              context, ref, employee as UserModelEmployee);
                        },
                        icon: const Icon(
                          IntegrakidsIcons.trash,
                          size: 16,
                          color: AppColors.erroRed,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
