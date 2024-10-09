import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_font.dart';

class IntegrakidsTheme {
  static const OutlineInputBorder _defaultBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: AppColors.bgFormInput),
  );

  static ThemeData themeData = ThemeData(
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.integraOrange),
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontFamily: AppFont.primaryFont,
          fontWeight: FontWeight.w500,
          fontSize: 18,
          color: AppColors.integraBrown,
        )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgFormInput,
      labelStyle: const TextStyle(
        color: AppColors.integraOrange,
        fontFamily: AppFont.primaryFont,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      border: _defaultBorder,
      enabledBorder: _defaultBorder,
      focusedBorder: _defaultBorder,
      errorBorder: _defaultBorder.copyWith(
        borderSide: const BorderSide(color: AppColors.erroRed),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.integraOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.black,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.integraOrange,
        backgroundColor: Colors.white,
        side: const BorderSide(
          color: AppColors.integraOrange,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        shadowColor: Colors.black,
      ),
    ),
    fontFamily: AppFont.primaryFont,
  );
}
