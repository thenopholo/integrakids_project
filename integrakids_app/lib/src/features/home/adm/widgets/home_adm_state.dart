import '../../../../model/user_model.dart';

enum HomeAdmStatus {
  loaded,
  error,
}

class HomeAdmState {
  final HomeAdmStatus status;
  final List<UserModel> employees;

  HomeAdmState({required this.status, required this.employees});

  HomeAdmState copyWith({HomeAdmStatus? status, List<UserModel>? employees}) {
    return HomeAdmState(
        status: status ?? this.status, employees: employees ?? this.employees);
  }
}
