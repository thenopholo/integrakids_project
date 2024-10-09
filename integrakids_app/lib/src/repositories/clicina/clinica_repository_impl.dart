import 'dart:developer';

import 'package:dio/dio.dart';

import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../core/restClient/rest_client.dart';
import '../../model/clinica_model.dart';
import '../../model/user_model.dart';
import 'clinica_reposiotry.dart';

class ClinicaRepositoryImpl implements ClinicaRepository {
  final RestClient restClient;
  ClinicaRepositoryImpl({
    required this.restClient,
  });

  @override
  Future<Either<RepositoryException, ClinicaModel>> getMyClinica(
      UserModel userModel) async {
    switch (userModel) {
      case UserModelADM():
        final Response(data: List(first: data)) = await restClient.auth.get(
          '/clinica',
          queryParameters: {'user_id': '#userAuthRef'},
        );
        return Success(ClinicaModel.fromMap(data));

      case UserModelEmployee():
        final Response(:data) = await restClient.auth.get(
          '/clinica/${userModel.clinicaId}',
        );
        return Success(ClinicaModel.fromMap(data));
    }
  }

  @override
  Future<Either<RepositoryException, Nil>> save(
      ({
        String email,
        String name,
        List<String> openDays,
        List<int> openHours,
      }) data) async {
    try {
      await restClient.auth.post(
        '/clinica',
        data: {
          'user_id': '#userAuthRef',
          'name': data.name,
          'email': data.email,
          'opening_days': data.openDays,
          'opening_hours': data.openHours,
        },
      );
      return Success(nil);
    } on DioException catch (e, s) {
      log('Erro ao registrar Cliníca', error: e, stackTrace: s);
      return Failure(
        RepositoryException(
          message: 'Erro ao registrar Cliníca',
        ),
      );
    }
  }
}
