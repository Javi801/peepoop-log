import 'package:flutter/material.dart';

import 'data/db/app_database.dart';
import 'presentation/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PeepoopLogApp(database: AppDatabase.open()));
}
