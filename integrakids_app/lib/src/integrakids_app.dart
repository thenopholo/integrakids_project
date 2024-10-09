import 'package:asyncstate/asyncstate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/ui/utils/integrakids_theme.dart';
import 'core/ui/widgets/clinica_nav_global_key.dart';
import 'core/ui/widgets/integrakids_loader.dart';
import 'features/auth/login/login_page.dart';
import 'features/auth/register/clinica/clinica_register_page.dart';
import 'features/auth/register/user/user_resgister_page.dart';
import 'features/employee/register/employee_resgister_page.dart';
import 'features/employee/schedule/employee_schedule_page.dart';
import 'features/home/adm/home_adm_page.dart';
import 'features/home/employee/home_empoyee_page.dart';
import 'features/schedule/schedule_page.dart';
import 'features/splash/slpash_page.dart';
import 'model/user_model.dart';

class IntegrakidsApp extends StatelessWidget {
  const IntegrakidsApp({super.key});
  @override
  Widget build(BuildContext context) {
    return AsyncStateBuilder(
      customLoader: const IntegrakidsLoader(),
      builder: (asyncNavigatorObserver) {
        return MaterialApp(
          title: 'Integrakids',
          debugShowCheckedModeBanner: false,
          theme: IntegrakidsTheme.themeData,
          navigatorObservers: [asyncNavigatorObserver],
          navigatorKey: ClinicaNavGlobalKey.instance.navKey,
          onGenerateRoute: (RouteSettings settings) {
            switch (settings.name) {
              case '/employee/register':
                final employee = settings.arguments as UserModel?;
                return MaterialPageRoute(
                  builder: (_) => EmployeeResgisterPage(employee: employee),
                );
              // Você pode adicionar outros casos para outras rotas que precisam de argumentos
              default:
                return MaterialPageRoute(
                  builder: (_) =>
                      const HomeAdmPage(), // Uma página de erro para rotas desconhecidas
                );
            }
          },
          routes: {
            '/': (_) => const SlpashPage(),
            '/auth/login': (_) => const LoginPage(),
            '/auth/register/user': (_) => const UserResgisterPage(),
            '/auth/register/create_clinica': (_) => const ClinicaRegisterPage(),
            '/home/adm': (_) => const HomeAdmPage(),
            '/home/employee': (_) => const HomeEmpoyeePage(),
            '/employee/schedule': (_) => const EmployeeSchedulePage(),
            '/schedule': (_) => const SchedulePage(),
          },
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt', 'BR')],
          locale: const Locale('pt', 'BR'),
        );
      },
    );
  }
}
