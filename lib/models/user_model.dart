import 'package:cloud_firestore/cloud_firestore.dart';

/// A DishDash account. Named [AppUser] to avoid clashing with Firebase Auth's
/// own `User` type when both are imported in the same file.
class AppUser {
  final String id; // Firebase Auth uid
  final String name;
  final String email;
  final String role; // 'foodie' | 'owner'
  final String? photoBase64;
  final String? phoneNumber;
  final DateTime? createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoBase64,
    this.phoneNumber,
    this.createdAt,
  });

  bool get isOwner => role == 'owner';
  bool get isFoodie => role == 'foodie';
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return AppUser(
      id: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      role: d['role'] ?? 'foodie',
      photoBase64: d['photoBase64'],
      phoneNumber: d['phoneNumber'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'email': email,
    'role': role,
    'photoBase64': photoBase64,
    'phoneNumber': phoneNumber,
    'createdAt': createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : FieldValue.serverTimestamp(),
  };
}
