import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/ui/helpers/form_helper.dart';
import '../../../core/ui/utils/app_colors.dart';
import '../../../core/ui/utils/app_font.dart';
import '../../../core/ui/widgets/integrakids_icons.dart';
import '../../../core/ui/widgets/integrakids_loader.dart';
import '../adm/widgets/home_adm_vm.dart';

class HomeHeader extends ConsumerWidget {
  final bool hideFilter;
  const HomeHeader({
    super.key,
    this.hideFilter = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clinica = ref.watch(getMyClinicaProvider);

    return Container(
      padding: const EdgeInsets.all(32),
      margin: const EdgeInsets.only(bottom: 16),
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        color: AppColors.integraBrown,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(5, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 24,
          ),
          clinica.maybeWhen(
            data: (clinicaData) {
              log('Daddos recebidos da clínica: ${clinicaData.name}');
              return Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(
                      0xFFBDBDBD,
                    ),
                    child: SizedBox.shrink(),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Flexible(
                    child: Text(
                      clinicaData.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.integraOffWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: AppFont.primaryFont,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  const Expanded(
                    child: Text(
                      'editar',
                      style: TextStyle(
                        color: AppColors.integraOffWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFont.primaryFont,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(homeAdmVmProvider.notifier).logout();
                    },
                    icon: const Icon(IntegrakidsIcons.exit),
                    color: AppColors.integraOffWhite,
                    iconSize: 32,
                  ),
                ],
              );
            },
            orElse: () {
              return const Center(
                child: IntegrakidsLoader(),
              );
            },
          ),
          const SizedBox(
            height: 24,
          ),
          const Text(
            'Bem-vindo!',
            style: TextStyle(
              color: AppColors.integraOffWhite,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              fontFamily: AppFont.primaryFont,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          const Text(
            'Agende um Paciente',
            style: TextStyle(
              color: AppColors.integraOffWhite,
              fontSize: 40,
              fontWeight: FontWeight.w700,
              fontFamily: AppFont.primaryFont,
            ),
          ),
          Offstage(
            offstage: hideFilter,
            child: const SizedBox(
              height: 24,
            ),
          ),
          Offstage(
            offstage: hideFilter,
            child: TextFormField(
              onTapOutside: (_) => context.unFocus(),
              decoration: InputDecoration(
                label: const Text('Buscar Terapeuta'),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 24.0),
                  child: IconButton(
                    onPressed: () {},
                    icon: const Icon(IntegrakidsIcons.search),
                    color: AppColors.integraOrange,
                    iconSize: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
