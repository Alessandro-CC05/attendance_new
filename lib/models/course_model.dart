import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String name;
  final String code;
  final String? schedule;
  final String room;
  final String teacherId;
  final String teacherName;
  final DateTime createdAt;
  final List<String> studentIds;

  CourseModel({
    required this.id,
    required this.name,
    required this.code,
    this.schedule,
    required this.room,
    required this.teacherId,
    required this.teacherName,
    required this.createdAt,
    this.studentIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'schedule': schedule,
      'room': room,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'createdAt': Timestamp.fromDate(createdAt),
      'studentIds': studentIds,
    };
  }

  factory CourseModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    
    try {
      if (map['createdAt'] == null) {
        parsedDate = DateTime.now();
      } else if (map['createdAt'] is Timestamp) {
        parsedDate = (map['createdAt'] as Timestamp).toDate();
      } else if (map['createdAt'] is String) {
        parsedDate = DateTime.parse(map['createdAt']);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return CourseModel(
      id: id,
      name: map['name']?.toString() ?? '',
      code: map['code']?.toString() ?? '',
      schedule: map['schedule']?.toString(),
      room: map['room']?.toString() ?? '',
      teacherId: map['teacherId']?.toString() ?? '',
      teacherName: map['teacherName']?.toString() ?? '',
      createdAt: parsedDate,
      studentIds: (map['studentIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return CourseModel.fromMap(data, doc.id);
    } catch (e) {
      throw Exception('Errore parsing corso: $e');
    }
  }
}