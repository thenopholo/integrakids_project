sealed class UserModel {
  final String id;
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
    final profile = json['profile'] as String?;

    switch (profile) {
      case 'ADM':
        return UserModelADM.fromMap(json);
      case 'EMPLOYEE':
        return UserModelEmployee.fromMap(json);
      default:
        throw ArgumentError('User Profile Not Found: $profile');
    }
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
        'id': String id,
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
  final String clinicaId;
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

  factory UserModelEmployee.fromMap(Map<String, dynamic> map) {
    return UserModelEmployee(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      especialidade: map['especialidade'] ?? '',
      clinicaId: map['clinica_id'] ?? '',
      workDays: List<String>.from(map['work_days'] ?? []),
      workHours: List<int>.from(map['work_hours'] ?? []),
    );
  }
}
