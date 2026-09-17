class UserProfile {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final bool isVegOnly;
  final String? appliedCouponCode;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.isVegOnly = false,
    this.appliedCouponCode,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    bool? isVegOnly,
    String? appliedCouponCode,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isVegOnly: isVegOnly ?? this.isVegOnly,
      appliedCouponCode: appliedCouponCode ?? this.appliedCouponCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'email': email,
    'isVegOnly': isVegOnly,
    'appliedCouponCode': appliedCouponCode,
    'createdAt': createdAt.toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    phoneNumber: json['phoneNumber'] as String,
    email: json['email'] as String?,
    isVegOnly: json['isVegOnly'] as bool? ?? false,
    appliedCouponCode: json['appliedCouponCode'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
