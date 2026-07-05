import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// A restaurant profile. The document id equals the owner's Firebase Auth uid,
/// so there is exactly one company per owner account.
class Company {
  final String id; // == owner uid
  final String name;
  final String description;
  final String location;
  final String? logoBase64;
  final double? latitude;
  final double? longitude;
  final String? contact;
  final String? website;
  final String? email;
  final List<String> cuisineTypes;
  final double rating;
  final DateTime? createdAt;

  Company({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    this.logoBase64,
    this.latitude,
    this.longitude,
    this.contact,
    this.website,
    this.email,
    this.cuisineTypes = const [],
    this.rating = 0,
    this.createdAt,
  });

  bool get hasLogo => (logoBase64 ?? '').isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;
  String get displayRating => rating > 0 ? rating.toStringAsFixed(1) : 'New';
  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';

  factory Company.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const {};
    return Company(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      location: d['location'] ?? '',
      logoBase64: d['logoBase64'],
      latitude: (d['latitude'] as num?)?.toDouble(),
      longitude: (d['longitude'] as num?)?.toDouble(),
      contact: d['contact'],
      website: d['website'],
      email: d['email'],
      cuisineTypes: (d['cuisineTypes'] as List?)?.cast<String>() ?? const [],
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'location': location,
    'logoBase64': logoBase64,
    'latitude': latitude,
    'longitude': longitude,
    'contact': contact,
    'website': website,
    'email': email,
    'cuisineTypes': cuisineTypes,
    'rating': rating,
  };

  /// Great-circle distance from a point, in kilometers.
  double? distanceFrom(double lat, double lng) {
    if (latitude == null || longitude == null) return null;
    const earthRadius = 6371.0;
    final dLat = _rad(latitude! - lat);
    final dLng = _rad(longitude! - lng);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat)) * cos(_rad(latitude!)) * sin(dLng / 2) * sin(dLng / 2);
    return earthRadius * 2 * asin(sqrt(a));
  }

  double _rad(double deg) => deg * pi / 180.0;
}
