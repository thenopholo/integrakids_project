import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../core/exceptions/repository_exception.dart';
import '../../core/fp/either.dart';
import '../../core/fp/nil.dart';
import '../../model/patient_model.dart';
import '../../model/schedule_model.dart';
import '../../model/tutor_model.dart';
import './schedule_repository.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  @override
  Future<Either<RepositoryException, Nil>> schedulePatient(
      ({
        String clinicaId,
        List<DateTime> dates,
        PatientModel patient,
        TutorModel tutor,
        String appointmentRoom,
        TimeOfDay time,
        String userId
      }) scheduleData) async {
    try {
      DatabaseReference schedulesRef =
          FirebaseDatabase.instance.ref().child('schedules');

      log('Iniciando registro de agendamentos: ${scheduleData.dates}');

      for (DateTime date in scheduleData.dates) {
        // Validar se a data está no futuro
        if (date.isBefore(DateTime.now())) {
          log('Data inválida (no passado): ${date.toIso8601String()}');
          continue; // Ignorar esta data
        }

        String scheduleKey = schedulesRef.push().key!;
        Map<String, dynamic> schedule = {
          'clinicaId': scheduleData.clinicaId,
          'userId': scheduleData.userId,
          'patientId': scheduleData.patient.id,
          'patientName': scheduleData.patient.name,
          'tutorName': scheduleData.tutor.name,
          'tutorPhone': scheduleData.tutor.phone,
          'appointmentRoom': scheduleData.appointmentRoom,
          'date': date.toIso8601String(),
          'time': '${scheduleData.time.hour.toString().padLeft(2, '0')}:${scheduleData.time.minute.toString().padLeft(2, '0')}',
        };

        log('Salvando agendamento: $schedule');

        try {
          // Salvar agendamento no Firebase
          await schedulesRef.child(scheduleKey).set(schedule);
          log('Agendamento salvo com sucesso: $scheduleKey');
        } catch (e) {
          log('Erro ao salvar agendamento para ${date.toIso8601String()}: $e');
          // Logar o erro, mas não interromper o fluxo
        }
      }

      return Success(nil);
    } catch (e, s) {
      log('Erro ao agendar paciente: $e');
      log('Stacktrace: $s');
      return Failure(RepositoryException(message: 'Erro ao agendar paciente'));
    }
  }

  @override
  Future<Either<RepositoryException, List<ScheduleModel>>> findScheduleByDate(
      ({
        List<DateTime> dates,
        String? userId,
      }) filter) async {
    try {

      if (FirebaseAuth.instance.currentUser == null) {
        await FirebaseAuth.instance.signInAnonymously();
      }
      
      DatabaseReference schedulesRef =
          FirebaseDatabase.instance.ref().child('schedules');

      List<ScheduleModel> schedules = [];

      // Itera pelas datas do filtro
      for (DateTime date in filter.dates) {
        log('Buscando agendamentos para a data: ${date.toIso8601String()}');
        Query query =
            schedulesRef.orderByChild('date').equalTo(date.toIso8601String());

        // Adiciona um filtro por userId, caso necessário
        if (filter.userId != null) {
          query = query.orderByChild('userId').equalTo(filter.userId);
        }

        DataSnapshot snapshot = await query.get();

        if (snapshot.exists) {
          // Converte os dados do snapshot para Map
          Map<String, dynamic> data =
              Map<String, dynamic>.from(snapshot.value as Map);

          // Filtra manualmente pelo userId, se fornecido
          data.forEach((key, value) {
            Map<String, dynamic> scheduleData =
                Map<String, dynamic>.from(value);

            if (filter.userId == null ||
                scheduleData['userId'] == filter.userId) {
              schedules.add(ScheduleModel.fromMap(scheduleData));
            }
          });

          log('Encontrados ${schedules.length} agendamentos para a data: ${date.toIso8601String()}');
        } else {
          log('Nenhum agendamento encontrado para a data: ${date.toIso8601String()}');
        }
      }

      return Success(schedules);
    } catch (e, s) {
      log('Erro ao buscar agendamentos: $e');
      log('Stacktrace: $s');
      return Failure(
        RepositoryException(
            message: 'Erro ao buscar agendamentos para as datas fornecidas'),
      );
    }
  }
}
