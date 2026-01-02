import 'package:cloud_firestore/cloud_firestore.dart';

class SessionModel{
  final String id;
  final String courseId;
  final String teacherId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  SessionModel({
  required this.id,
  required this.courseId,
  required this.teacherId,
  required this.startTime,
  required this.endTime,
  required this.isActive,
  });

  Map<String, dynamic> toMap()=>{
    'id': id,
    'courseId': courseId,
    'teacherId': teacherId,
    'startTime': Timestamp.fromDate(startTime),
    'endTime': Timestamp.fromDate(endTime),
    'isActive': isActive,
  };
  factory SessionModel.fromFirestore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>;
    return SessionModel(
      id: doc.id,
      courseId: data['courseId'] ?? '',
      teacherId: data['teacherId'] ?? '',
      startTime: DateTime.parse(data['startTime']),
      endTime: DateTime.parse(data['endTime']),
      isActive: data['isActive'] ?? false,
    );
  }
}
