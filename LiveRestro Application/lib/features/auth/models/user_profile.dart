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
    id: (json['id'] ?? '').toString(),
    name: (json['name'] ?? '').toString(),
    phoneNumber: (json['phoneNumber'] ?? json['mobile_number'] ?? json['phone'] ?? '').toString(),
    email: json['email']?.toString(),
    isVegOnly: json['isVegOnly'] == true || json['isVegOnly'] == 1 || json['is_veg_only'] == 1 || json['is_veg_only'] == true,
    appliedCouponCode: json['appliedCouponCode']?.toString(),
    createdAt: json['createdAt'] != null
        ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
        : DateTime.now(),
  );
}
