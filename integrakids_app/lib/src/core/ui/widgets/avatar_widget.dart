import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'integrakids_icons.dart';

class AvatarWidget extends StatelessWidget {
  final bool hideUploadButton;
  const AvatarWidget({
    Key? key,
    this.hideUploadButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Offstage(
              offstage: hideUploadButton,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.integraOrange, width: 2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  IntegrakidsIcons.addEmployee,
                  color: AppColors.integraOrange,
                  size: 25,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
