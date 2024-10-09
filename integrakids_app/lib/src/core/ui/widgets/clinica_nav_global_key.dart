import 'package:flutter/material.dart';

class ClinicaNavGlobalKey {
  static ClinicaNavGlobalKey? _instance;
  final navKey = GlobalKey<NavigatorState>();
  ClinicaNavGlobalKey._();

  static ClinicaNavGlobalKey get instance =>
      _instance ??= ClinicaNavGlobalKey._();
}
