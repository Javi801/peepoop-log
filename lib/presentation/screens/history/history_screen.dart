import 'package:flutter/material.dart';

/// Placeholder until the record history list is implemented.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: Center(
        child: Text(
          'Coming soon',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
