class User {
  final int id;
  final String name;
  final String email;
  final String profileImageUrl;
  final DateTime? createdAt;
  final String? role;
  final bool? isEmailVerified;
  final String? phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImageUrl,
    this.createdAt,
    this.role,
    this.isEmailVerified,
    this.phoneNumber,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profile_image_url'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      role: json['role'],
      isEmailVerified: json['is_email_verified'],
      phoneNumber: json['phone_number'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'profile_image_url': profileImageUrl,
    'created_at': createdAt?.toIso8601String(),
    'role': role,
    'is_email_verified': isEmailVerified,
    'phone_number': phoneNumber,
  };

  // Utility methods
  bool get hasProfileImage => profileImageUrl.isNotEmpty;
  bool get isVerified => isEmailVerified ?? false;
  String get displayName => name.isNotEmpty ? name : email.split('@').first;

  // Copy with method for updates
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? profileImageUrl,
    DateTime? createdAt,
    String? role,
    bool? isEmailVerified,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, name: $name, email: $email)';
}
