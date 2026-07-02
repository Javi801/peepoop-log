import 'package:flutter/material.dart';

import '../../localization/app_strings.dart';
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
              AppStrings.splashTitle,
              textAlign: TextAlign.center,
              style: AppTypography.splashTitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(AppStrings.splashSubtitle, style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.splashEmojiGap),
            const Text(AppSymbols.splashHero, style: AppTypography.splashEmoji),
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
            Text(AppStrings.splashLoading, style: textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
