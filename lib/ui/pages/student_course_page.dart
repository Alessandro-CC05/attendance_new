import 'package:flutter/material.dart';
import '../../models/course_model.dart';
import '../../ble/student_ble_service.dart';
import '../../services/session_service.dart';
import '../../services/attendance_service.dart';

class StudentCourseScreen extends StatefulWidget {
  final CourseModel course;
  final String studentId;

  const StudentCourseScreen({
    super.key,
    required this.course,
    required this.studentId,
  });

  @override
  State<StudentCourseScreen> createState() => _StudentCourseScreenState();
}

class _StudentCourseScreenState extends State<StudentCourseScreen> {
  final StudentBleService _ble = StudentBleService();
  final SessionService _sessionService = SessionService();

  bool _signalDetected = false;
  bool _presenceConfirmed = false;
  bool _scanning = false;

  String _status = 'Ricerca lezione in corso...';
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    if (_scanning) return;
    _scanning = true;

    await _ble.startScan(
      onDetected: (uuid) async {
        final sessionId =
            await _sessionService.getActiveSessionIdByBleUuid(uuid);

        if (sessionId == null) return;

        if (!mounted) return;

        setState(() {
          _sessionId = sessionId;
          _signalDetected = true;
          _status = 'Lezione trovata';
        });
      },
    );
  }

  Future<void> _confirmPresence() async {
    if (_sessionId == null || _presenceConfirmed) return;

    await AttendanceService().confirmPresence(
      sessionId: _sessionId!,
      studentId: widget.studentId,
    );

    setState(() => _presenceConfirmed = true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Presenza registrata'),
        backgroundColor: Colors.green,
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _ble.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      appBar: AppBar(
        title: Text(widget.course.name),
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _signalDetected
                      ? Icons.bluetooth_connected
                      : Icons.bluetooth_searching,
                  color: _signalDetected ? Colors.green : Colors.grey,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: _signalDetected
                          ? Colors.green
                          : Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _signalDetected ? _confirmPresence : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  disabledBackgroundColor: Colors.grey[700],
                ),
                child: const Text(
                  'Conferma presenza',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
