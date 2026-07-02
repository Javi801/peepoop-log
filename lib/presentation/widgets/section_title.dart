import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// Purple heading between groups of cards.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        text,
        style: AppTypography.sectionTitle.copyWith(color: colors.primaryDark),
      ),
    );
  }
}
