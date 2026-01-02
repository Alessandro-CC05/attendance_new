import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// registra presenza (1 sola volta)
  Future<void> confirmPresence({
    required String sessionId,
    required String studentId,
  }) async {
    final ref = _firestore
        .collection('sessions')
        .doc(sessionId)
        .collection('attendances')
        .doc(studentId);

    final snapshot = await ref.get();

    if (snapshot.exists) {
      // già presente → non fare nulla
      return;
    }

    await ref.set({
      'studentId': studentId,
      'confirmedAt': FieldValue.serverTimestamp(),
    });
  }
}
