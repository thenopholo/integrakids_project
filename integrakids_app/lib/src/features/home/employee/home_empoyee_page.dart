import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/ui/utils/app_colors.dart';
import '../../../core/ui/widgets/avatar_widget.dart';
import '../../../core/ui/widgets/integrakids_loader.dart';
import '../../../model/user_model.dart';
import '../widgets/home_header.dart';
import 'home_employee_provider.dart';

class HomeEmpoyeePage extends ConsumerWidget {
  const HomeEmpoyeePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(getMeProvider);
    return Scaffold(
        body: userModelAsync.when(
      error: (error, stackTrace) {
        return const Center(
          child: Text('Erro ao carregar página'),
        );
      },
      loading: () => const IntegrakidsLoader(),
      data: (user) {
        final UserModel(:id, :name) = user;
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: HomeHeader(
                hideFilter: true,
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const AvatarWidget(
                      hideUploadButton: true,
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Container(
                      width: MediaQuery.sizeOf(context).width * .9,
                      height: 108,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.integraGreen,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Consumer(builder: (context, ref, child) {
                            final totalAsync =
                                ref.watch(getTotalSchedulesTodayProvider(id));
                            return totalAsync.when(
                              error: (error, stackTrace) {
                                return const Text(
                                    'Erro ao carregar atendimentos');
                              },
                              loading: () => const IntegrakidsLoader(),
                              skipLoadingOnRefresh: false,
                              data: (totalSchedule) {
                                return Text(
                                  totalSchedule.toString(),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: AppColors.integraGreen,
                                    fontWeight: FontWeight.w700,
                                  ),
                                );
                              },
                            );
                          }),
                          const Text(
                            'Atendimentos hoje',
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.integraLightBrown,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 28,
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.of(context)
                            .pushNamed('/schedule', arguments: user);
                        ref.invalidate(getTotalSchedulesTodayProvider);
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
                        'Agendar Paciente',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pushNamed('/employee/schedule', arguments: user);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        shadowColor: Colors.black,
                      ),
                      child: const Text('Ver Agenda'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    ));
  }
}
