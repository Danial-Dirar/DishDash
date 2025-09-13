class Offer {
  final int id;
  final String title;
  final String description;
  final String imageUrl;
  final int companyId;
  final DateTime? createdAt;
  final DateTime? expiresAt;
  final double? originalPrice;
  final double? discountedPrice;
  final int? discountPercentage;
  final String? category;
  final bool? isActive;
  final String? promoCode;

  Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.companyId,
    this.createdAt,
    this.expiresAt,
    this.originalPrice,
    this.discountedPrice,
    this.discountPercentage,
    this.category,
    this.isActive,
    this.promoCode,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image_url'] ?? '',
      companyId: int.parse(json['company_id'].toString()),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'])
          : null,
      originalPrice: json['original_price'] != null
          ? double.tryParse(json['original_price'].toString())
          : null,
      discountedPrice: json['discounted_price'] != null
          ? double.tryParse(json['discounted_price'].toString())
          : null,
      discountPercentage: json['discount_percentage'] != null
          ? int.tryParse(json['discount_percentage'].toString())
          : null,
      category: json['category'],
      isActive: json['is_active'],
      promoCode: json['promo_code'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'image_url': imageUrl,
    'company_id': companyId,
    'created_at': createdAt?.toIso8601String(),
    'expires_at': expiresAt?.toIso8601String(),
    'original_price': originalPrice,
    'discounted_price': discountedPrice,
    'discount_percentage': discountPercentage,
    'category': category,
    'is_active': isActive,
    'promo_code': promoCode,
  };

  // Utility methods for offer discovery
  bool get hasImage => imageUrl.isNotEmpty;
  bool get isExpired => expiresAt?.isBefore(DateTime.now()) ?? false;
  bool get isAvailable => (isActive ?? true) && !isExpired;

  bool get hasDiscount =>
      (originalPrice != null && discountedPrice != null) ||
      discountPercentage != null;

  String get displayPrice {
    if (discountedPrice != null) {
      return '\$${discountedPrice!.toStringAsFixed(2)}';
    } else if (originalPrice != null) {
      return '\$${originalPrice!.toStringAsFixed(2)}';
    }
    return '';
  }

  String get displayDiscount {
    if (discountPercentage != null) {
      return '${discountPercentage}% OFF';
    } else if (originalPrice != null && discountedPrice != null) {
      double savings = originalPrice! - discountedPrice!;
      return 'Save \$${savings.toStringAsFixed(2)}';
    }
    return '';
  }

  String get timeRemaining {
    if (expiresAt == null) return '';

    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) return 'Expired';

    final difference = expiresAt!.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else {
      return '${difference.inMinutes} minutes left';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Offer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Offer(id: $id, title: $title, companyId: $companyId)';
}
