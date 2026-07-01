import 'package:flutter/material.dart';

/// Placeholder until the settings screen is implemented.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Text(
          'Coming soon',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
