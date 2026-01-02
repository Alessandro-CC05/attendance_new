import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceModel {
  final String id;
  final String sessionId;
  final String courseId;
  final String studentId;
  final DateTime timestamp;
  final bool manual;

  AttendanceModel({
    required this.id,
    required this.sessionId,
    required this.courseId,
    required this.studentId,
    required this.timestamp,
    required this.manual,
  });

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'courseId': courseId,
        'studentId': studentId,
        'timestamp': timestamp.toIso8601String(),
        'manual': manual,
      };

  factory AttendanceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceModel(
      id: doc.id,
      sessionId: data['sessionId'] ?? '',
      courseId: data['courseId'] ?? '',
      studentId: data['studentId'] ?? '',
      timestamp: DateTime.parse(data['timestamp']),
      manual: data['manual'] ?? false,
    );
  }
}
