import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../application/csv_exporter.dart';
import '../../scope/app_scope.dart';
import '../../theme/theme.dart';
import '../../widgets/widgets.dart';

/// Builds the CSV from all records and hands it to the system share sheet.
class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key, this.shareCsv});

  /// Overridable in tests; defaults to the system share sheet.
  final Future<void> Function(String csv)? shareCsv;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    final repository = AppScope.of(context).recordRepository;
    setState(() => _exporting = true);
    try {
      final records = await repository.getRecords();
      final csv = const CsvExporter().buildCsv(records);
      await (widget.shareCsv ?? _shareViaSystemSheet)(csv);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _shareViaSystemSheet(String csv) async {
    await SharePlus.instance.share(ShareParams(
      files: [XFile.fromData(utf8.encode(csv), mimeType: 'text/csv')],
      fileNameOverrides: [CsvExporter.fileName],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Export')),
      body: ListView(
        padding: AppInsets.screen,
        children: [
          AppCard(
            padding: AppInsets.exportHero,
            child: Column(
              children: [
                const Text('🐼📄', style: AppTypography.exportEmoji),
                Text('Export your data', style: textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Export one row per urination or defecation event.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.fieldGap),
                PrimaryButton(
                  expand: true,
                  onPressed: _exporting ? null : _export,
                  child: const Text('Export CSV'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
