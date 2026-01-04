import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel {
  final String id;
  final String courseId;
  final String teacherId;
  final String bleUuid;
  final DateTime startedAt;
  final DateTime? endedAt;

  SessionModel({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.bleUuid,
    required this.startedAt,
    required this.endedAt,
  });

  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception('Sessione ${doc.id} senza dati');
    }

    final Timestamp startedTs = data['startedAt'];
    final Timestamp? endedTs = data['endedAt'];

    return SessionModel(
      id: doc.id,
      courseId: data['courseId'] as String,
      teacherId: data['teacherId'] as String,
      bleUuid: data['bleUuid'] as String,
      startedAt: startedTs.toDate(),
      endedAt: endedTs?.toDate(),
    );
  }

  bool get isActive => endedAt == null;
}
