import 'package:attendance_new/ui/pages/attendance_report_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/course_model.dart';
import '../../services/session_service.dart';
import '../../ble/teacher_ble_service.dart';

class TeacherCourseDetailPage extends StatefulWidget {
  final CourseModel course;
  final String teacherId;

  const TeacherCourseDetailPage({
    super.key,
    required this.course,
    required this.teacherId,
  });

  @override
  State<TeacherCourseDetailPage> createState() =>
      _TeacherCourseDetailPageState();
}

class _TeacherCourseDetailPageState extends State<TeacherCourseDetailPage> {
  final SessionService _sessionService = SessionService();
  final TeacherBleService _bleService = TeacherBleService();

  String? _activeSessionId;
  String? _bleUuid;
  bool _isLoading = false;
  bool _isAdvertising = false;

  /// ▶️ AVVIA SESSIONE + BLE
  Future<void> _startSession() async {
    setState(() => _isLoading = true);

    try {
      final sessionId = await _sessionService.startSession(
        courseId: widget.course.id,
        teacherId: widget.teacherId,
      );

      final sessionDoc = await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .get();

      final bleUuid = sessionDoc['bleUuid'] as String;

      await _bleService.startAdvertising(bleUuid);

      setState(() {
        _activeSessionId = sessionId;
        _bleUuid = bleUuid;
        _isAdvertising = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore avvio sessione: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// ⛔ CHIUDI SESSIONE + STOP BLE
  Future<void> _endSession() async {
    if (_activeSessionId == null) return;

    try {
      await _bleService.stopAdvertising();
      await _sessionService.endSession(_activeSessionId!);

      setState(() {
        _activeSessionId = null;
        _bleUuid = null;
        _isAdvertising = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessione chiusa correttamente'),
          backgroundColor: Color(0xFF46ad5a),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore chiusura sessione: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    if (_isAdvertising) {
      _bleService.stopAdvertising();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          color: Color.fromARGB(255, 193, 193, 193),
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.course.name,
          style: TextStyle(
            color: const Color.fromARGB(255, 193, 193, 193)
          ),
          ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CODICE CORSO
            Text(
              widget.course.code,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),

            /// BLOCCO SESSIONE
            if (_activeSessionId == null) ...[
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF46ad5a),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Avvia sessione presenze',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18
                            ),
                        ),
                ),
              ),
            ] else ...[
              const Text(
                'Sessione attiva',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'BLE UUID:',
                style: TextStyle(color: Colors.grey[400]),
              ),
              SelectableText(
                _bleUuid ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _endSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Chiudi sessione',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18
                      ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            /// 📊 BOTTONE REPORT PRESENZE (NUOVO)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.bar_chart),
                label: const Text(
                  'Controlla presenze',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF46ad5a),
                  side: const BorderSide(color: Color(0xFF46ad5a)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceReportPage(
                        course: widget.course,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
