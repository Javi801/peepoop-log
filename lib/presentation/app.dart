import 'package:flutter/material.dart';

/// Root widget of the app.
///
/// The app is fully offline: no login, no cloud services, no analytics.
/// All user data stays on the device.
class PeepoopLogApp extends StatelessWidget {
  const PeepoopLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PeePoop Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('PeePoop Log'),
        ),
      ),
    );
  }
}
