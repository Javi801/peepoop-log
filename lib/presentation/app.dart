import 'package:flutter/material.dart';

import '../data/db/app_database.dart';
import '../data/repositories/record_repository.dart';
import '../data/repositories/tag_repository.dart';
import 'localization/app_strings.dart';
import 'navigation/home_shell.dart';
import 'scope/app_scope.dart';
import 'screens/splash/splash_screen.dart';
import 'theme/theme.dart';

/// Root widget of the app.
///
/// The app is fully offline: no login, no cloud services, no analytics.
/// All user data stays on the device.
class PeepoopLogApp extends StatefulWidget {
  const PeepoopLogApp({super.key, required this.database});

  final AppDatabase database;

  @override
  State<PeepoopLogApp> createState() => _PeepoopLogAppState();
}

class _PeepoopLogAppState extends State<PeepoopLogApp> {
  late final RecordRepository _recordRepository;
  late final TagRepository _tagRepository;
  late final Future<void> _databaseReady;

  @override
  void initState() {
    super.initState();
    _recordRepository = RecordRepository(widget.database);
    _tagRepository = TagRepository(widget.database);
    // Drift opens the file and runs migrations on the first statement, so
    // the splash stays up until the database is actually usable.
    _databaseReady = widget.database.customSelect('SELECT 1').get();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      recordRepository: _recordRepository,
      tagRepository: _tagRepository,
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        home: FutureBuilder<void>(
          future: _databaseReady,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _StartupErrorScreen(error: snapshot.error!);
            }
            if (snapshot.connectionState != ConnectionState.done) {
              return const SplashScreen();
            }
            return const HomeShell();
          },
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: AppInsets.screen,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.startupErrorTitle,
                style: textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
