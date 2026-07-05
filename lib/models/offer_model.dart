import 'package:cloud_firestore/cloud_firestore.dart';

enum OfferStatus { scheduled, active, expired }

/// A promotional offer posted by a restaurant. Analytics counters
/// (views / saves / shares) live on the document and are updated atomically.
class Offer {
  final String id;
  final String companyId; // owner uid
  final String companyName;
  final String title;
  final String description;
  final String? imageBase64;
  final String? category;
  final double? originalPrice;
  final double? discountedPrice;
  final int? discountPercentage;
  final String? promoCode;
  final DateTime? createdAt;
  final DateTime? scheduledAt; // when the offer goes live
  final DateTime? expiresAt;
  final int viewCount;
  final int saveCount;
  final int shareCount;

  Offer({
    required this.id,
    required this.companyId,
    required this.companyName,
    required this.title,
    required this.description,
    this.imageBase64,
    this.category,
    this.originalPrice,
    this.discountedPrice,
    this.discountPercentage,
    this.promoCode,
    this.createdAt,
    this.scheduledAt,
    this.expiresAt,
    this.viewCount = 0,
    this.saveCount = 0,
    this.shareCount = 0,
  });

  factory Offer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Offer.fromMap(doc.id, doc.data() ?? const {});

  factory Offer.fromMap(String id, Map<String, dynamic> d) {
    return Offer(
      id: id,
      companyId: d['companyId'] ?? '',
      companyName: d['companyName'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      imageBase64: d['imageBase64'],
      category: d['category'],
      originalPrice: (d['originalPrice'] as num?)?.toDouble(),
      discountedPrice: (d['discountedPrice'] as num?)?.toDouble(),
      discountPercentage: (d['discountPercentage'] as num?)?.toInt(),
      promoCode: d['promoCode'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      scheduledAt: (d['scheduledAt'] as Timestamp?)?.toDate(),
      expiresAt: (d['expiresAt'] as Timestamp?)?.toDate(),
      viewCount: (d['viewCount'] as num?)?.toInt() ?? 0,
      saveCount: (d['saveCount'] as num?)?.toInt() ?? 0,
      shareCount: (d['shareCount'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes for writing. View/save/share counters are managed with
  /// atomic increments elsewhere and intentionally omitted on create/update.
  Map<String, dynamic> toCreateMap() => {
    'companyId': companyId,
    'companyName': companyName,
    'title': title,
    'description': description,
    'imageBase64': imageBase64,
    'category': category,
    'originalPrice': originalPrice,
    'discountedPrice': discountedPrice,
    'discountPercentage': discountPercentage,
    'promoCode': promoCode,
    'scheduledAt': scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    'createdAt': FieldValue.serverTimestamp(),
    'viewCount': 0,
    'saveCount': 0,
    'shareCount': 0,
  };

  /// A denormalized copy stored in a foodie's saved sub-collection so the
  /// Saved tab renders without extra joins.
  Map<String, dynamic> toSavedMap() => {
    'companyId': companyId,
    'companyName': companyName,
    'title': title,
    'description': description,
    'imageBase64': imageBase64,
    'category': category,
    'originalPrice': originalPrice,
    'discountedPrice': discountedPrice,
    'discountPercentage': discountPercentage,
    'promoCode': promoCode,
    'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    'savedAt': FieldValue.serverTimestamp(),
  };

  OfferStatus get status {
    final now = DateTime.now();
    if (expiresAt != null && expiresAt!.isBefore(now)) return OfferStatus.expired;
    if (scheduledAt != null && scheduledAt!.isAfter(now)) {
      return OfferStatus.scheduled;
    }
    return OfferStatus.active;
  }

  bool get isLive => status == OfferStatus.active;
  bool get hasImage => (imageBase64 ?? '').isNotEmpty;

  String get statusLabel => switch (status) {
    OfferStatus.scheduled => 'Scheduled',
    OfferStatus.active => 'Active',
    OfferStatus.expired => 'Expired',
  };

  bool get hasDiscount =>
      (originalPrice != null && discountedPrice != null) ||
      discountPercentage != null;

  String get displayPrice {
    if (discountedPrice != null) return '৳${discountedPrice!.toStringAsFixed(0)}';
    if (originalPrice != null) return '৳${originalPrice!.toStringAsFixed(0)}';
    return '';
  }

  String get displayDiscount {
    if (discountPercentage != null) return '$discountPercentage% OFF';
    if (originalPrice != null && discountedPrice != null) {
      return 'Save ৳${(originalPrice! - discountedPrice!).toStringAsFixed(0)}';
    }
    return '';
  }

  String get timeRemaining {
    final target = status == OfferStatus.scheduled ? scheduledAt : expiresAt;
    if (target == null) return '';
    final now = DateTime.now();
    final prefix = status == OfferStatus.scheduled ? 'Goes live in ' : '';
    if (status == OfferStatus.expired) return 'Expired';
    final diff = target.difference(now);
    if (diff.inDays > 0) return '$prefix${diff.inDays}d';
    if (diff.inHours > 0) return '$prefix${diff.inHours}h';
    return '$prefix${diff.inMinutes}m';
  }
}
