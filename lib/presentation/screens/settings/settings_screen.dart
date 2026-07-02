import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
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
      title: AppStrings.settingsDeleteAllDialogTitle,
      message: AppStrings.settingsDeleteAllDialogMessage,
    );
    if (!confirmed) return;
    await repository.deleteAllData();
    messenger.showSnackBar(
      const SnackBar(content: Text(AppStrings.settingsDeleted)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settingsTitle)),
      body: ListView(
        padding: AppInsets.screen,
        children: [
          _SettingsCard(
            title: AppStrings.settingsDeleteAllTitle,
            body: AppStrings.settingsDeleteAllBody,
            onTap: () => _deleteAllData(context),
          ),
          const _SettingsCard(
            title: AppStrings.settingsPrivacyTitle,
            body: AppStrings.settingsPrivacyBody,
          ),
          const _SettingsCard(
            title: AppStrings.settingsAboutTitle,
            body: AppStrings.settingsAboutBody,
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
