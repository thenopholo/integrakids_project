sealed class UserModel {
  final int id;
  final String name;
  final String especialidade;
  final String email;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.especialidade,
    required this.email,
    this.avatar,
  });

  factory UserModel.fromMap(Map<String, dynamic> json) {
    return switch (json['profile']) {
      'ADM' => UserModelADM.fromMap(json),
      'EMPLOYEE' => UserModelEmployee.fromMap(json),
      _ => throw ArgumentError('User Profile Not Found')
    };
  }
}

class UserModelADM extends UserModel {
  final List<String>? workDays;
  final List<int>? workHours;

  UserModelADM({
    required super.id,
    required super.name,
    required super.especialidade,
    required super.email,
    super.avatar,
    this.workDays,
    this.workHours,
  });

  factory UserModelADM.fromMap(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int id,
        'name': String name,
        'especialidade': String especialidade,
        'email': String email,
      } =>
        UserModelADM(
          id: id,
          name: name,
          especialidade: especialidade,
          email: email,
          avatar: json['avatar'],
          workDays: json['work_days']?.cast<String>(),
          workHours: json['work_hours']?.cast<int>(),
        ),
      _ => throw ArgumentError('Invalid Json'),
    };
  }
}

class UserModelEmployee extends UserModel {
  final int clinicaId;
  final List<String> workDays;
  final List<int> workHours;

  UserModelEmployee({
    required super.id,
    required super.name,
    required super.especialidade,
    required super.email,
    required this.clinicaId,
    required this.workDays,
    required this.workHours,
    super.avatar,
  });

  factory UserModelEmployee.fromMap(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': final int id,
        'name': final String name,
        'especialidade': final String especialidade,
        'email': final String email,
        'clinica_id': final int clinicaId,
        'work_days': final List workDays,
        'work_hours': final List workHours,
      } =>
        UserModelEmployee(
          id: id,
          name: name,
          especialidade: especialidade,
          email: email,
          avatar: json['avatar'],
          clinicaId: clinicaId,
          workDays: workDays.cast<String>(),
          workHours: workHours.cast<int>(),
        ),
      _ => throw ArgumentError('Invalid Json'),
    };
  }
}