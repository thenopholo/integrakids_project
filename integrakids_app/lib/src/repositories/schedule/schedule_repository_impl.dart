import 'dart:developer';

import 'package:dio/dio.dart';
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
      for (DateTime date in scheduleData.dates) {
        String scheduleKey = schedulesRef.push().key!;
        await schedulesRef.child(scheduleKey).set({
          'clinicaId': scheduleData.clinicaId,
          'userId': scheduleData.userId,
          'patientName': scheduleData.patient.name,
          'tutorName': scheduleData.tutor.name,
          'tutorPhone': scheduleData.tutor.phone,
          'appointmentRoom': scheduleData.appointmentRoom,
          'date': date.toIso8601String(),
          'time': '${scheduleData.time.hour}:${scheduleData.time.minute}',
        });
      }

      return Success(nil);
    } catch (e) {
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
      // Referência ao nó de agendamentos
      DatabaseReference schedulesRef =
          FirebaseDatabase.instance.ref().child('schedules');

      List<ScheduleModel> schedules = [];

      // Itera pelas datas do filtro
      for (DateTime date in filter.dates) {
        Query query =
            schedulesRef.orderByChild('date').equalTo(date.toIso8601String());

        // Adiciona um filtro por userId, caso necessário
        if (filter.userId != null) {
          query = query.orderByChild('userId').equalTo(filter.userId);
        }

        DataSnapshot snapshot = await query.get();

        if (snapshot.exists) {
          // Itera pelos resultados da consulta
          Map<String, dynamic> data =
              Map<String, dynamic>.from(snapshot.value as Map);
          data.forEach((key, value) {
            schedules
                .add(ScheduleModel.fromMap(Map<String, dynamic>.from(value)));
          });
        }
      }

      return Success(schedules);
    } catch (e) {
      return Failure(
        RepositoryException(
            message: 'Erro ao buscar agendamentos para as datas fornecidas'),
      );
    }
  }
}
