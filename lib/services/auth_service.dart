import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
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
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try{

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('Login google annullato');
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null){
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists){
          debugPrint('creazione documento utente');

          final nameParts = user.displayName?.split(' ') ?? ['', ''];
          final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
          final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          await _firestore.collection('users').doc(user.uid).set({
            'uid': user.uid,
            'name': firstName,
            'surname': lastName,
            'email': user.email ?? '',
            'role': null,
            'authProvider': 'google',
          });
        }
      }
    }
    catch(e){
      debugPrint('registrazione con google fallita');
    }
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