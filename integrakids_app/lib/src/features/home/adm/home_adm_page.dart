import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/ui/utils/app_colors.dart';
import '../../../core/ui/widgets/integrakids_icons.dart';
import '../../../core/ui/widgets/integrakids_loader.dart';
import '../widgets/home_header.dart';
import 'widgets/home_adm_state.dart';
import 'widgets/home_adm_vm.dart';
import 'widgets/home_employee_tile.dart';

class HomeAdmPage extends ConsumerWidget {
  const HomeAdmPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(getMeProvider, (previous, next) {
      ref.invalidate(homeAdmVmProvider);
    });
    final homeState = ref.watch(homeAdmVmProvider);
    final clinicaState = ref.watch(getMyClinicaProvider);

    // Debug log para monitorar mudanças
    clinicaState.whenData((clinica) {
      log('Estado atual da clínica: ${clinica.name}');
    });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).pushNamed('/employee/register');
          ref.invalidate(getMeProvider);
          ref.invalidate(homeAdmVmProvider);
        },
        shape: const CircleBorder(),
        backgroundColor: AppColors.integraOrange,
        child: const CircleAvatar(
          backgroundColor: AppColors.integraOrange,
          maxRadius: 20,
          child: Icon(
            IntegrakidsIcons.addEmployee,
            color: Colors.white,
          ),
        ),
      ),
      body: homeState.when(
        data: (HomeAdmState data) {
          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: HomeHeader(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      HomeEmployeeTile(employee: data.employees[index]),
                  childCount: data.employees.length,
                ),
              ),
            ],
          );
        },
        error: (Object error, StackTrace stackTrace) {
          log('Erro ao carregar terapuetas',
              error: error, stackTrace: stackTrace);
          return const Center(
            child: Text('Erro ao carregar página'),
          );
        },
        loading: () {
          return const IntegrakidsLoader();
        },
      ),
    );
  }
}
