import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'ads/ads_service.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'firebase_ready.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (isFirebaseConfigured()) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  unawaited(adsService.initialize());
  runApp(const TaskLApp());
}
