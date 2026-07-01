import 'package:flutter/material.dart';

/// Placeholder until the tag management screen is implemented.
class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      body: Center(
        child: Text(
          'Coming soon',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
