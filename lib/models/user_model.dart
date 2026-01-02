import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String surname;
  final String email;
  final String? role;
  final DateTime createdAt;
  final String? authProvider;

  UserModel({
    required this.uid,
    required this.name,
    required this.surname,
    required this.email,
    this.role,
    required this.createdAt,
    this.authProvider,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'surname': surname,
      'email': email,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'authProvider': authProvider,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] ?? '',
      surname: map['surname'] ?? '',
      email: map['email'] ?? '',
      role: map['role'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.parse(map['createdAt'])
              : (map['createdAt'] is Timestamp
                  ? (map['createdAt'] as Timestamp).toDate()
                  : DateTime.now()))
          : DateTime.now(),
      authProvider: map['authProvider'],
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel.fromMap(data, doc.id);
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? surname,
    String? email,
    String? role,
    DateTime? createdAt,
    String? authProvider,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      authProvider: authProvider ?? this.authProvider,
    );
  }
}