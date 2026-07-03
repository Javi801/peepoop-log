import 'package:flutter/widgets.dart';

import '../../data/repositories/record_repository.dart';
import '../../data/repositories/tag_repository.dart';

/// Exposes the app-wide repositories to the widget tree.
///
/// A plain [InheritedWidget] keeps state management lightweight: screens
/// read repositories from here and own their local state.
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.recordRepository,
    required this.tagRepository,
    required super.child,
  });

  final RecordRepository recordRepository;
  final TagRepository tagRepository;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found above this context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      recordRepository != oldWidget.recordRepository ||
      tagRepository != oldWidget.tagRepository;
}
