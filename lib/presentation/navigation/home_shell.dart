import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../screens/add_record/add_record_screen.dart';
import '../screens/export/export_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/tags/tags_screen.dart';
import '../theme/theme.dart';

/// Root destinations reachable from the bottom navigation bar.
enum HomeDestination {
  addRecord(AppStrings.navAddRecord, AppSymbols.navAdd),
  history(AppStrings.navHistory, AppSymbols.navHistory),
  tags(AppStrings.navTags, AppSymbols.navTags),
  export(AppStrings.navExport, AppSymbols.navExport),
  settings(AppStrings.navSettings, AppSymbols.navSettings);

  const HomeDestination(this.title, this.icon);

  final String title;

  /// Glyph shown in the bottom bar: an emoji, or "+" for [addRecord].
  final String icon;

  /// Root screen hosted in the shell for this destination.
  Widget get screen => switch (this) {
    HomeDestination.addRecord => const AddRecordScreen(),
    HomeDestination.history => const HistoryScreen(),
    HomeDestination.tags => const TagsScreen(),
    HomeDestination.export => const ExportScreen(),
    HomeDestination.settings => const SettingsScreen(),
  };
}

/// Hosts the five root screens behind a shared bottom navigation bar.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  HomeDestination _destination = HomeDestination.addRecord;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _destination.index,
        children: [
          for (final destination in HomeDestination.values) destination.screen,
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        current: _destination,
        onSelect: (destination) => setState(() => _destination = destination),
      ),
    );
  }
}

/// Four emoji destinations around a central "+" button that overhangs the
/// bar by [AppSizes.fabOverhang].
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.current, required this.onSelect});

  final HomeDestination current;
  final ValueChanged<HomeDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: AppSizes.fabOverhang + AppSizes.bottomNavHeight + bottomInset,
      child: Stack(
        children: [
          Positioned.fill(
            top: AppSizes.fabOverhang,
            child: Container(
              // Flat surface for now; the translucent blurred bar ships
              // together with the decorative backgrounds.
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              padding: EdgeInsets.only(bottom: bottomInset),
              child: Row(
                children: [
                  for (final destination in const [
                    HomeDestination.history,
                    HomeDestination.tags,
                  ])
                    _NavItem(
                      destination: destination,
                      selected: current == destination,
                      onSelect: onSelect,
                    ),
                  const SizedBox(width: AppSizes.navPlusSlot),
                  for (final destination in const [
                    HomeDestination.export,
                    HomeDestination.settings,
                  ])
                    _NavItem(
                      destination: destination,
                      selected: current == destination,
                      onSelect: onSelect,
                    ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _PlusButton(
              onTap: () => onSelect(HomeDestination.addRecord),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onSelect,
  });

  final HomeDestination destination;
  final bool selected;
  final ValueChanged<HomeDestination> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Expanded(
      child: InkWell(
        onTap: () => onSelect(destination),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(destination.icon, style: AppTypography.emojiIcon),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              destination.title,
              style: AppTypography.navLabel.copyWith(
                color: selected ? colors.primaryDark : colors.textMuted,
                fontWeight: selected ? AppTypography.bold : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlusButton extends StatelessWidget {
  const _PlusButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final decorations = context.appDecorations;
    final radius = BorderRadius.circular(AppRadii.fab);

    return Semantics(
      button: true,
      label: HomeDestination.addRecord.title,
      child: Container(
        width: AppSizes.fabSize,
        height: AppSizes.fabSize,
        decoration: BoxDecoration(
          gradient: decorations.primaryAction,
          borderRadius: radius,
          boxShadow: decorations.fabShadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            onTap: onTap,
            child: Center(
              child: Text(
                HomeDestination.addRecord.icon,
                style: AppTypography.navPlus.copyWith(color: colors.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
