import 'package:flutter/material.dart';

import '../theme/theme.dart';
import 'app_buttons.dart';
import 'app_modal.dart';

/// Centered confirmation dialog for destructive actions.
///
/// Resolves to true only when the user confirms; dismissing the barrier
/// counts as cancel.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String? emoji,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: AppInsets.modal,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null)
              Padding(
                padding: AppInsets.dialogEmoji,
                child: Text(emoji, style: AppTypography.dialogEmoji),
              ),
            ModalTitle(title),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            ModalActions(
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                DangerButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return confirmed ?? false;
}
