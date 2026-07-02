import 'package:flutter/material.dart';

import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Destructive data actions plus the privacy and about statements.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _deleteAllData(BuildContext context) async {
    final repository = AppScope.of(context).recordRepository;
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showConfirmDialog(
      context,
      emoji: '💩💕',
      title: 'Delete all app data?',
      message:
          'This will permanently delete all records and tags. '
          'This action cannot be undone.',
    );
    if (!confirmed) return;
    await repository.deleteAllData();
    messenger.showSnackBar(
      const SnackBar(content: Text('All app data deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: AppInsets.screen,
        children: [
          _SettingsCard(
            title: 'Delete all app data',
            body: 'Deletes all records and tags after confirmation.',
            onTap: () => _deleteAllData(context),
          ),
          const _SettingsCard(
            title: 'Privacy',
            body:
                'All data is stored only on this device. No login, cloud, '
                'analytics, Firebase, Google services, Meta services, or '
                'tracking.',
          ),
          const _SettingsCard(
            title: 'About',
            body:
                'PeePoop Log\nVersion 0.1.0\n'
                'Developer contact: your.email@example.com',
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.title, required this.body, this.onTap});

  final String title;
  final String body;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.body.copyWith(fontWeight: AppTypography.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
