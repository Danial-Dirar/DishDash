import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Handles Firebase Auth together with the Firestore `users` / `companies`
/// profile documents, so the app always knows whether an account is a
/// foodie or a restaurant owner.
class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;
  static Stream<User?> get authState => _auth.authStateChanges();

  /// Registers a food lover and creates their profile document.
  static Future<void> registerFoodie({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user!.updateDisplayName(name);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'role': 'foodie',
      'phoneNumber': phone,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Registers a restaurant owner: creates both the user profile (role: owner)
  /// and the company document in a single batch.
  static Future<void> registerOwner({
    required String name,
    required String email,
    required String password,
    required String description,
    required String location,
    String? contact,
    String? website,
    double? latitude,
    double? longitude,
    List<String> cuisineTypes = const [],
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    await cred.user!.updateDisplayName(name);

    final batch = _db.batch();
    batch.set(_db.collection('users').doc(uid), {
      'name': name,
      'email': email,
      'role': 'owner',
      'createdAt': FieldValue.serverTimestamp(),
    });
    batch.set(_db.collection('companies').doc(uid), {
      'name': name,
      'email': email,
      'description': description,
      'location': location,
      'contact': contact,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'cuisineTypes': cuisineTypes,
      'rating': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Signs in and returns the account role ('foodie' | 'owner').
  static Future<String> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return roleFor(cred.user!.uid);
  }

  static Future<String> roleFor(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['role'] as String?) ?? 'foodie';
  }

  static Future<AppUser?> currentProfile() async {
    final id = uid;
    if (id == null) return null;
    final doc = await _db.collection('users').doc(id).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  static Stream<AppUser?> profileStream() {
    final id = uid;
    if (id == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(id)
        .snapshots()
        .map((d) => d.exists ? AppUser.fromDoc(d) : null);
  }

  static Future<void> updateProfile({
    String? name,
    String? phone,
    String? photoBase64,
  }) async {
    final id = uid;
    if (id == null) return;
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phoneNumber'] = phone;
    if (photoBase64 != null) data['photoBase64'] = photoBase64;
    if (data.isEmpty) return;
    await _db.collection('users').doc(id).set(data, SetOptions(merge: true));
  }

  static Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  static Future<void> signOut() => _auth.signOut();
}
