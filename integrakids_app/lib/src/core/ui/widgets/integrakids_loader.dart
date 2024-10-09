import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../utils/app_colors.dart';

class IntegrakidsLoader extends StatelessWidget {
  const IntegrakidsLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.threeArchedCircle(
        color: AppColors.integraBrown,
        size: 60,
      ),
    );
  }
}
