import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';

class TaskLApp extends StatelessWidget {
  const TaskLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task-L',
      theme: buildAppTheme(),
      locale: const Locale('ja'),
      supportedLocales: const [Locale('ja')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AuthGate(),
    );
  }
}
