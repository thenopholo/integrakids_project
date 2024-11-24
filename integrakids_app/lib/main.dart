import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'src/integrakids_app.dart';

Future<void> main() async {
  await initializeDateFormatting();
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseDatabase database = FirebaseDatabase.instance;
      database.setPersistenceEnabled(true);
      database.setLoggingEnabled(true);
    }
  } catch (e) {
    debugPrint('Erro ao inicializar o Firebase: $e');
  }
  runApp(
    const ProviderScope(
      child: IntegrakidsApp(),
    ),
  );
}
