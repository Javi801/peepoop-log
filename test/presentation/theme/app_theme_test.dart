import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:peepoop_log/presentation/theme/theme.dart';

void main() {
  group('AppTheme', () {
    test('light theme registers palette and decoration extensions', () {
      final theme = AppTheme.light();

      expect(theme.extension<AppColors>(), AppColors.pastel);
      expect(theme.extension<AppDecorations>(), isNotNull);
      expect(theme.scaffoldBackgroundColor, AppColors.pastel.background);
      expect(theme.colorScheme.primary, AppColors.pastel.primary);
    });

    test('fromColors derives scheme and decorations from the palette', () {
      final custom = AppColors.pastel.copyWith(
        primary: const Color(0xFF008080),
        accent: const Color(0xFFFF0000),
      );

      final theme = AppTheme.fromColors(custom);

      expect(theme.colorScheme.primary, const Color(0xFF008080));
      expect(theme.extension<AppDecorations>()!.primaryAction.colors, [
        const Color(0xFFFF0000),
        const Color(0xFF008080),
      ]);
    });
  });

  group('AppColors', () {
    test('lerp interpolates every color channel', () {
      final other = AppColors.pastel.copyWith(primary: const Color(0xFF000000));

      final mid = AppColors.pastel.lerp(other, 0.5);

      expect(
        mid.primary,
        Color.lerp(AppColors.pastel.primary, const Color(0xFF000000), 0.5),
      );
      expect(mid.background, AppColors.pastel.background);
    });

    test('exposes the tag fallback color', () {
      expect(AppColors.pastel.tagFallback, const Color(0xFFFFE8A3));
    });
  });
}
