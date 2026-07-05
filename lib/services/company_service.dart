import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/company_model.dart';

class CompanyService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _db.collection('companies').doc(uid);

  static Stream<Company?> stream(String uid) =>
      _doc(uid).snapshots().map((d) => d.exists ? Company.fromDoc(d) : null);

  static Future<Company?> get(String uid) async {
    final doc = await _doc(uid).get();
    return doc.exists ? Company.fromDoc(doc) : null;
  }

  static Future<void> update(String uid, Map<String, dynamic> data) =>
      _doc(uid).set(data, SetOptions(merge: true));

  /// All restaurants (used for the discovery map/list).
  static Stream<List<Company>> streamAll() =>
      _db.collection('companies').snapshots().map(
        (s) => s.docs.map(Company.fromDoc).toList(),
      );
}
