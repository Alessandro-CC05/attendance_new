import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> confirmPresence({
    required String courseId,
    required String sessionId,
    required String studentId,
  }) async {
    final query = await _firestore
        .collection('attendance')
        .where('sessionId', isEqualTo: sessionId)
        .where('studentId', isEqualTo: studentId)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      // presenza già registrata
      return;
    }

    await _firestore.collection('attendance').add({
      'courseId': courseId,
      'sessionId': sessionId,
      'studentId': studentId,
      'confirmedAt': FieldValue.serverTimestamp(),
    });
  }
}
