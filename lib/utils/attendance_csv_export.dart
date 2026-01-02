import 'dart:io';
import 'package:attendance_new/models/attendance_report_model.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

Future<File> exportAttendanceCsv(
    List<AttendanceReportRow> report) async {

  final rows = [
    ['Studente', 'Presenze', 'Totale', 'Percentuale']
  ];

  for (final r in report) {
    rows.add([
      r.studentName,
      r.attendedSessions.toString(),
      r.totalSessions.toString(),
      r.percentage.toStringAsFixed(1),
    ]);
  }

  final csvData =
      const ListToCsvConverter().convert(rows);

  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/report_presenze.csv');

  return file.writeAsString(csvData);
}
