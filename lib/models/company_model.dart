import 'dart:math';

class Company {
  final int id;
  final String name;
  final String description;
  final String location;
  final String logoUrl;
  final double? latitude;
  final double? longitude;
  final String? contact;
  final DateTime? createdAt;
  final String? email;
  final String? website;
  final List<String>? cuisineTypes;
  final double? rating;
  final bool? isActive;

  Company({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.logoUrl,
    this.latitude,
    this.longitude,
    this.contact,
    this.createdAt,
    this.email,
    this.website,
    this.cuisineTypes,
    this.rating,
    this.isActive,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      contact: json['contact'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      email: json['email'],
      website: json['website'],
      cuisineTypes: json['cuisine_types'] != null
          ? List<String>.from(json['cuisine_types'])
          : null,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'location': location,
    'logo_url': logoUrl,
    'latitude': latitude,
    'longitude': longitude,
    'contact': contact,
    'created_at': createdAt?.toIso8601String(),
    'email': email,
    'website': website,
    'cuisine_types': cuisineTypes,
    'rating': rating,
    'is_active': isActive,
  };

  // Utility methods
  bool get hasLogo => logoUrl.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;
  bool get isOpen => isActive ?? true;
  String get displayRating =>
      rating != null ? rating!.toStringAsFixed(1) : 'N/A';

  // Calculate distance from user location (if needed)
  double? distanceFrom(double userLat, double userLng) {
    if (latitude == null || longitude == null) return null;

    // Simple distance calculation (in kilometers)
    const double earthRadius = 6371.0;
    double dLat = _toRadians(latitude! - userLat);
    double dLng = _toRadians(longitude! - userLng);
    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(userLat)) *
            cos(_toRadians(latitude!)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (pi / 180.0);

  // Copy with method
  Company copyWith({
    int? id,
    String? name,
    String? description,
    String? location,
    String? logoUrl,
    double? latitude,
    double? longitude,
    String? contact,
    DateTime? createdAt,
    String? email,
    String? website,
    List<String>? cuisineTypes,
    double? rating,
    bool? isActive,
  }) {
    return Company(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      logoUrl: logoUrl ?? this.logoUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      website: website ?? this.website,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Company && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Company(id: $id, name: $name, location: $location)';
}
