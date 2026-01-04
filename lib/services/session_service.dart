import 'package:attendance_new/models/session_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SessionService {
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<String> startSession({
    required String courseId,
    required String teacherId,
  }) async {
    final sessionUuid = _uuid.v4();

    final doc = await _firestore.collection('sessions').add({
      'courseId': courseId,
      'teacherId': teacherId,
      'startedAt': FieldValue.serverTimestamp(),
      'endedAt': null,
      'bleUuid': sessionUuid,
    });

    return doc.id;
  }

  Future<void> endSession(String sessionId) async {
    await _firestore.collection('sessions').doc(sessionId).update({
      'endedAt': FieldValue.serverTimestamp(),
    });
  }
  Future<SessionModel?> getActiveSessionByBleUuid(String bleUuid) async {
    final query = await _firestore
        .collection('sessions')
        .where('bleUuid', isEqualTo: bleUuid)
        .where('endedAt', isNull: true)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return SessionModel.fromFirestore(query.docs.first);
  }

  Future<SessionModel?> getSessionByCourseId(String courseId) async {
    final doc =
        await _firestore.collection('sessions').doc(courseId).get();

    if (!doc.exists) return null;
    return SessionModel.fromFirestore(doc);
  }

}
