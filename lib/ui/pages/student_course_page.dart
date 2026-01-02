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
  final StudentBleService _bleService = StudentBleService();
  final SessionService _sessionService = SessionService();

  bool _signalDetected = false;
  bool _presenceConfirmed = false;
  bool _isScanning = false;

  String _statusText = 'Ricerca lezione in corso...';
  String? _sessionId;

  @override
  void initState() {
    super.initState();
    _startBleScan();
  }

  /// 🔍 Avvia scansione BLE
  Future<void> _startBleScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _statusText = 'Ricerca lezione in corso...';
    });

    try {
      await _bleService.startScan(
        onDetected: (bleUuid) async {
          if (_signalDetected) return;

          final sessionId =
              await _sessionService.getActiveSessionIdByBleUuid(bleUuid);

          if (!mounted) return;

          if (sessionId == null) {
            setState(() {
              _statusText = 'Nessuna lezione attiva trovata';
            });
            return;
          }

          // ✅ TROVATA SESSIONE VALIDA → STOP SCAN
          await _bleService.stopScan();

          setState(() {
            _sessionId = sessionId;
            _signalDetected = true;
            _isScanning = false;
            _statusText = 'Lezione rilevata';
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isScanning = false;
        _statusText = 'Bluetooth non disponibile';
      });
    }
  }

  /// ✅ Conferma presenza su Firestore
  Future<void> _confirmPresence() async {
    if (_sessionId == null || _presenceConfirmed) return;

    try {
      await AttendanceService().confirmPresence(
        sessionId: _sessionId!,
        studentId: widget.studentId,
      );

      setState(() {
        _presenceConfirmed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Presenza registrata con successo'),
          backgroundColor: Color(0xFF46ad5a),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore registrazione presenza: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _bleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      appBar: AppBar(
        title: Text(widget.course.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.course.teacherName,
              style: TextStyle(color: Colors.grey[400]),
            ),

            const SizedBox(height: 32),

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
                    _statusText,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          _signalDetected ? Colors.green : Colors.grey[400],
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
                onPressed:
                    (_signalDetected && !_presenceConfirmed)
                        ? _confirmPresence
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF46ad5a),
                  disabledBackgroundColor: Colors.grey[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Conferma presenza',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
