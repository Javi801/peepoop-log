import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Shown while the database opens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'PeePoop\nLog',
              textAlign: TextAlign.center,
              style: AppTypography.splashTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Your health, your log 💜', style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.splashEmojiGap),
            const Text('🐼🚽', style: AppTypography.splashEmoji),
            const SizedBox(height: AppSpacing.splashLoaderGap),
            SizedBox(
              width: AppSizes.loaderWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                // Static fill like the design reference; drift reports no
                // real progress while opening the file.
                child: const LinearProgressIndicator(
                  value: AppEffects.splashLoaderValue,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Loading your data...', style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
