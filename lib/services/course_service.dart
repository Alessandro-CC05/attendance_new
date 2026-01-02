import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/course_model.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createCourse({
    required String name,
    required String code,
    String? schedule,
    required String room,
    required String teacherId,
    required String teacherName,
  }) async {
    try {
      final courseData = {
        'name': name,
        'code': code,
        if (schedule != null && schedule.isNotEmpty) 'schedule': schedule,
        'room': room,
        'teacherId': teacherId,
        'teacherName': teacherName,
        'createdAt': FieldValue.serverTimestamp(),
        'studentIds': [],
      };

      debugPrint('📤 Creazione corso...');

      DocumentReference docRef = await _firestore.collection('courses').add(courseData);

      await docRef.update({'id': docRef.id});

      debugPrint('✅ Corso creato con ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Errore creazione corso: $e');
      rethrow;
    }
  }

  Stream<List<CourseModel>> getTeacherCourses(String teacherId) {
    debugPrint('📥 Caricamento corsi per teacherId: $teacherId');
    
    return _firestore
        .collection('courses')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .handleError((error) {
          debugPrint('❌ Errore stream corsi: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            debugPrint('📊 Documenti trovati: ${snapshot.docs.length}');
            
            final courses = <CourseModel>[];
            
            for (var doc in snapshot.docs) {
              try {
                final course = CourseModel.fromFirestore(doc);
                courses.add(course);
                debugPrint('  ✓ Corso caricato: ${course.name}');
              } catch (e) {
                debugPrint('  ✗ Errore caricamento corso ${doc.id}: $e');
              }
            }
            
            courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            return courses;
          } catch (e) {
            debugPrint('❌ Errore parsing snapshot: $e');
            return <CourseModel>[];
          }
        });
  }

  Stream<List<CourseModel>> getStudentCourses(String studentId) {
    return _firestore
        .collection('courses')
        .where('studentIds', arrayContains: studentId)
        .snapshots()
        .handleError((error) {
          debugPrint('❌ Errore stream corsi studente: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            final courses = snapshot.docs
                .map((doc) {
                  try {
                    return CourseModel.fromFirestore(doc);
                  } catch (e) {
                    debugPrint('Errore parsing corso ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<CourseModel>()
                .toList();
            
            courses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            
            return courses;
          } catch (e) {
            debugPrint('❌ Errore parsing snapshot studente: $e');
            return <CourseModel>[];
          }
        });
  }

  Future<void> addStudentToCourse(String courseId, String studentId) async {
    try {
      await _firestore.collection('courses').doc(courseId).update({
        'studentIds': FieldValue.arrayUnion([studentId]),
      });
      debugPrint('✅ Studente aggiunto al corso');
    } catch (e) {
      debugPrint('❌ Errore aggiunta studente: $e');
      rethrow;
    }
  }

  Future<void> deleteCourse(String courseId) async {
    try {
      await _firestore.collection('courses').doc(courseId).delete();
      debugPrint('✅ Corso eliminato');
    } catch (e) {
      debugPrint('❌ Errore eliminazione corso: $e');
      rethrow;
    }
  }
}