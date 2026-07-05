import 'package:cloud_firestore/cloud_firestore.dart';

/// A single dish on a restaurant's menu, stored under
/// companies/{ownerUid}/menu/{itemId}.
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double? price;
  final String? category;
  final String? imageBase64;
  final DateTime? createdAt;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    this.price,
    this.category,
    this.imageBase64,
    this.createdAt,
  });

  String get displayPrice => price != null ? '৳${price!.toStringAsFixed(0)}' : '';

  factory MenuItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return MenuItem(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      price: (d['price'] as num?)?.toDouble(),
      category: d['category'],
      imageBase64: d['imageBase64'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'imageBase64': imageBase64,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
