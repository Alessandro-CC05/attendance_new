import 'dart:io';

import 'package:attendance_new/models/attendance_report_model.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class AttendanceCsvService {
  /// Costruisce il CSV come stringa
  static String _buildCsv(List<AttendanceReportRow> report) {
    final List<List<String>> rows = [
      ['Studente', 'Presenze', 'Totale', 'Percentuale'],
    ];

    for (final r in report) {
      rows.add([
        r.studentName,
        r.attendedSessions.toString(),
        r.totalSessions.toString(),
        r.percentage.toStringAsFixed(1),
      ]);
    }

    return const ListToCsvConverter().convert(rows);
  }

  /// Restituisce il file CSV salvato (uso interno)
  static Future<File> _createCsvFile(
    List<AttendanceReportRow> report,
  ) async {
    final csvData = _buildCsv(report);

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/report_presenze.csv');

    return file.writeAsString(csvData);
  }

  /// ⬇️ SALVA (download locale)
  static Future<File> saveCsv(
    List<AttendanceReportRow> report,
  ) async {
    return _createCsvFile(report);
  }

  /// 📤 CONDIVIDI (WhatsApp, Drive, Mail…)
  static Future<void> shareCsv(
    List<AttendanceReportRow> report,
  ) async {
    final file = await _createCsvFile(report);

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Report presenze corso',
    );
  }
}
