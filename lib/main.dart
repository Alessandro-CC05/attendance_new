import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './ui/pages/login_page.dart';
import './services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attendance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: StreamBuilder<User?>(
        stream: AuthService().authStateChanges, 
        builder: (context, snapshot){
          // Mostra loading mentre controlla lo stato
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // Se l'utente è loggato

          /*
          if(snapshot.hasData){
            return const Scaffold(
              body: Center(
                child: Text('HOME - Utente loggato!'),
              ),
            );
          }
          */
          
          // Se l'utente NON è loggato
          return const AttendanceLoginScreen();
        }
      )
    );
  }
}