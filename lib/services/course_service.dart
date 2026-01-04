import 'package:attendance_new/models/session_model.dart';
import 'package:attendance_new/models/user_model.dart';
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
      final batch = _firestore.batch();

      final courseRef = _firestore.collection('courses').doc(courseId);
      final userRef = _firestore.collection('users').doc(studentId);

      batch.update(courseRef, {
        'studentIds': FieldValue.arrayUnion([studentId]),
      });

      batch.update(userRef, {
        'courses': FieldValue.arrayUnion([courseId]),
      });

      await batch.commit();

      debugPrint('✅ Studente aggiunto al corso (bidirezionale)');
    } catch (e) {
      debugPrint('❌ Errore aggiunta studente: $e');
      rethrow;
    }
  }
  Future<void> joinCourseByCode({
    required String courseCode,
    required String studentId,
  }) async {
    try {
      final query = await _firestore
          .collection('courses')
          .where('code', isEqualTo: courseCode)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Corso non trovato');
      }

      final courseDoc = query.docs.first;
      final courseId = courseDoc.id;

      final batch = _firestore.batch();

      batch.update(courseDoc.reference, {
        'studentIds': FieldValue.arrayUnion([studentId]),
      });

      batch.set(
        _firestore.collection('users').doc(studentId),
        {'courses': FieldValue.arrayUnion([courseId])},
        SetOptions(merge: true),
      );

      await batch.commit();

      debugPrint('✅ Studente iscritto al corso tramite codice');
    } catch (e) {
      debugPrint('❌ Errore join corso: $e');
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
  Future<SessionModel?> getSessionByCourseId(String courseId) async {
    final doc =
        await _firestore.collection('sessions').doc(courseId).get();

    if (!doc.exists) return null;
    return SessionModel.fromFirestore(doc);
  }

  Future<List<SessionModel>> getSessionsForCourse(String courseId) async {
    final sessionsQuery = await _firestore
        .collection('sessions')
        .where('courseId', isEqualTo: courseId)
        .get();

    final sessions = sessionsQuery.docs
        .map((doc) => SessionModel.fromFirestore(doc))
        .toList();

    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  Future<List<UserModel>> getStudentsInCourse(String courseId) async {
    final courseDoc =
        await _firestore.collection('courses').doc(courseId).get();

    if (!courseDoc.exists) return [];

    final data = courseDoc.data() as Map<String, dynamic>;
    final List<dynamic> studentIds = data['studentIds'] ?? [];

    if (studentIds.isEmpty) return [];

    final studentsQuery = await _firestore
        .collection('users')
        .where('uid', whereIn: studentIds)
        .get();

    return studentsQuery.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  } 

}
