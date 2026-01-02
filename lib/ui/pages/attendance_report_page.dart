import 'package:attendance_new/models/attendance_report_model.dart';
import 'package:attendance_new/models/course_model.dart';
import 'package:attendance_new/services/attendance_report_service.dart';
import 'package:attendance_new/utils/attendance_csv_export.dart';
import 'package:flutter/material.dart';

class AttendanceReportPage extends StatefulWidget {
  final CourseModel course;

  const AttendanceReportPage({
    super.key,
    required this.course,
  });

  @override
  State<AttendanceReportPage> createState() =>
      _AttendanceReportPageState();
}

class _AttendanceReportPageState
    extends State<AttendanceReportPage> {

  final _service = AttendanceReportService();

  List<AttendanceReportRow> _report = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _loading = true);

    final report = await _service.buildReport(
      courseId: widget.course.id,
      studentIds: widget.course.studentIds,
    );

    setState(() {
      _report = report;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report presenze'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _report.isEmpty
                ? null
                : () async {
                    final file =
                        await exportAttendanceCsv(_report);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'CSV salvato: ${file.path}',
                        ),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _report.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1),
              itemBuilder: (_, i) {
                final r = _report[i];

                return ListTile(
                  title: Text(r.studentName),
                  subtitle: Text(
                    'Presenze: ${r.attendedSessions}/${r.totalSessions}',
                  ),
                  trailing: Text(
                    '${r.percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: r.percentage >= 75
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
