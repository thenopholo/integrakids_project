import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/helpers/messages.dart';
import '../../core/ui/utils/app_images.dart';
import '../auth/login/login_page.dart';
import 'splash_vm.dart';

class SlpashPage extends ConsumerStatefulWidget {
  const SlpashPage({super.key});

  @override
  ConsumerState<SlpashPage> createState() => _SlpashPageState();
}

class _SlpashPageState extends ConsumerState<SlpashPage> {
  var _scale = 10.0;
  var _animationOpacityLogo = 0.0;

  double get _logoAnimationWidth => 100 * _scale;
  double get _logoAnimationHeight => 80 * _scale;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _animationOpacityLogo = 1.0;
        _scale = 2.0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(splashVmProvider, (_, state) {
      state.whenOrNull(
        error: (e, s) {
          log('Erro ao validar o login', error: e, stackTrace: s);
          Messages.showError('Erro ao validar o login', context);
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/auth/login', (route) => false);
        },
        data: (data) {
          switch (data) {
            case SplashState.loggedADM:
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home/adm', (route) => false);
            case SplashState.loggedEmployee:
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/home/employee', (route) => false);
            case _:
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/auth/login', (route) => false);
          }
        },
      );
    });
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.backgroundLogin),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(seconds: 3),
            curve: Curves.easeIn,
            opacity: _animationOpacityLogo,
            onEnd: () {
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  settings: const RouteSettings(name: '/auth/login'),
                  pageBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                  ) {
                    return const LoginPage();
                  },
                  transitionsBuilder: (_, animation, __, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
                (route) => false,
              );
            },
            child: AnimatedContainer(
              duration: const Duration(seconds: 3),
              width: _logoAnimationWidth,
              height: _logoAnimationHeight,
              curve: Curves.linearToEaseOut,
              child: Image.asset(
                AppImages.logo,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
