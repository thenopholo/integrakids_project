enum ClinicaRegisterStatus {
  initial,
  success,
  error,
}

class ClinicaRegisterState {
  final ClinicaRegisterStatus status;
  final List<String> openDays;
  final List<int> openHours;

  ClinicaRegisterState.initial()
      : this(
          status: ClinicaRegisterStatus.initial,
          openDays: <String>[],
          openHours: <int>[],
        );

  ClinicaRegisterState({
    required this.status,
    required this.openDays,
    required this.openHours,
  });

  ClinicaRegisterState copyWith(
      {ClinicaRegisterStatus? status,
      List<String>? openDays,
      List<int>? openHours}) {
    return ClinicaRegisterState(
        status: status ?? this.status,
        openDays: openDays ?? this.openDays,
        openHours: openHours ?? this.openHours);
  }
}
