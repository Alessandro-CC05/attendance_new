import 'package:attendance_new/models/attendance_report_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_report_model.dart';

class AttendanceReportService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<AttendanceReportRow>> buildReport({
    required String courseId,
    required List<String> studentIds,
  }) async {

    final sessionsSnap = await _firestore
        .collection('sessions')
        .where('courseId', isEqualTo: courseId)
        .get();

    final totalSessions = sessionsSnap.docs.length;

    final attendanceSnap = await _firestore
        .collection('attendance')
        .where('courseId', isEqualTo: courseId)
        .get();

    final Map<String, int> attendanceCount = {};

    for (final doc in attendanceSnap.docs) {
      final studentId = doc['studentId'];
      attendanceCount[studentId] =
          (attendanceCount[studentId] ?? 0) + 1;
    }

    final usersSnap = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: studentIds)
        .get();

    return usersSnap.docs.map((userDoc) {
      final studentId = userDoc.id;
      final name =
          '${userDoc['name']} ${userDoc['surname']}';

      return AttendanceReportRow(
        studentId: studentId,
        studentName: name,
        totalSessions: totalSessions,
        attendedSessions: attendanceCount[studentId] ?? 0,
      );
    }).toList();
  }
}
