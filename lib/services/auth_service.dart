import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email, 
    required String password
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> createUserWithEmailAndPassword({
    required String name,
    required String surname,
    required String email, 
    required String password
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, 
        password: password
      );

      final user= userCredential.user;

      await _firestore.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'name': name,
        'surname': surname,
        'email': email,
        'role': null,
      });

      return user;

    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> updateRole(String uid, String role) async{
    try{
      await _firestore.collection('users').doc(uid).update({
        'role': role
      });
    }
    catch (e){
      throw 'errore durante aggiornamento ruolo';
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Nessun utente trovato con questa email';
      case 'wrong-password':
        return 'Password errata';
      case 'email-already-in-use':
        return 'Email già registrata';
      case 'weak-password':
        return 'Password troppo debole';
      case 'invalid-email':
        return 'Email non valida';
      default:
        return e.message ?? 'Errore di autenticazione';
    }
  }
}