import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Shown while the database opens.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _titleStyle = TextStyle(
    fontSize: 32,
    fontWeight: AppTypography.bold,
    letterSpacing: -0.64,
    height: 1.15,
  );

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
              style: _titleStyle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Your health, your log 💜', style: textTheme.bodySmall),
            const SizedBox(height: 42),
            const Text('🐼🚽', style: TextStyle(fontSize: 94)),
            const SizedBox(height: 26),
            SizedBox(
              width: AppSizes.loaderWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                // Static fill like the design reference; drift reports no
                // real progress while opening the file.
                child: const LinearProgressIndicator(value: 0.68),
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
