import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('companies').doc(uid).collection('menu');

  static Stream<List<MenuItem>> stream(String uid) =>
      _col(uid).snapshots().map((s) {
        final list = s.docs.map(MenuItem.fromDoc).toList();
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return list;
      });

  static Future<void> add(String uid, MenuItem item) =>
      _col(uid).add(item.toMap());

  static Future<void> delete(String uid, String itemId) =>
      _col(uid).doc(itemId).delete();
}
