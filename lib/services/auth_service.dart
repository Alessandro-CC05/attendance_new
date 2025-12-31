import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

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

      final user = userCredential.user;

      await _firestore.collection('users').doc(user!.uid).set({
        'uid': user.uid,
        'name': name,
        'surname': surname,
        'email': email,
        'role': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;

    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      debugPrint('✅ Email di reset password inviata a: $email');
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Errore reset password: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  Future<void> updateRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': role,
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
    } catch (e) {
      throw 'Errore durante aggiornamento ruolo: $e';
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<User?> signInWithGoogle() async {
    try {
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

      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          debugPrint('Creazione documento utente Google');

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
            'createdAt': FieldValue.serverTimestamp(),
          });

          await Future.delayed(const Duration(milliseconds: 800));
          
          debugPrint('✅ Documento utente Google creato');
        } else {
          debugPrint('✅ Utente Google esistente trovato');
        }
        
        return user;
      }
    } catch (e) {
      debugPrint('❌ ERRORE GOOGLE SIGN-IN:');
      debugPrint('   Errore: $e');
      debugPrint('   Tipo: ${e.runtimeType}');
      rethrow;
    }
    return null;
  }

  Future<UserModel?> getCurrentUserData() async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) {
      debugPrint('❌ Nessun utente corrente');
      return null;
    }
    
    debugPrint('📥 Caricamento dati per utente: ${user.uid}');
    
    int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (!doc.exists) {
          debugPrint('⚠️ Documento non trovato, tentativo ${retryCount + 1}/$maxRetries');
          retryCount++;
          
          if (retryCount < maxRetries) {
            await Future.delayed(Duration(milliseconds: 500 * retryCount));
            continue;
          }
          
          debugPrint('❌ Documento non trovato dopo $maxRetries tentativi');
          return null;
        }
        
        debugPrint('✅ Documento utente caricato');
        return UserModel.fromFirestore(doc);
        
      } catch (e) {
        debugPrint('❌ Errore caricamento dati: $e');
        retryCount++;
        
        if (retryCount < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        } else {
          rethrow;
        }
      }
    }
    
    return null;
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