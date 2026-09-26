class AddressModel {
  final String id;
  final String tag; // Home, Work, Other
  final String fullAddress;
  final String landmark;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String? recipientName;
  final String? recipientPhone;

  const AddressModel({
    required this.id,
    required this.tag,
    required this.fullAddress,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.recipientName,
    this.recipientPhone,
  });

  AddressModel copyWith({
    String? id,
    String? tag,
    String? fullAddress,
    String? landmark,
    double? latitude,
    double? longitude,
    bool? isDefault,
    String? recipientName,
    String? recipientPhone,
  }) {
    return AddressModel(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      fullAddress: fullAddress ?? this.fullAddress,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tag': tag,
    'fullAddress': fullAddress,
    'landmark': landmark,
    'latitude': latitude,
    'longitude': longitude,
    'isDefault': isDefault,
    if (recipientName != null) 'recipientName': recipientName,
    if (recipientPhone != null) 'recipientPhone': recipientPhone,
  };

  Map<String, dynamic> toBackendJson() => {
    'address_type': tag.toLowerCase(),
    'complete_address': fullAddress,
    'landmark': landmark,
    'latitude': latitude,
    'longitude': longitude,
    'is_default': isDefault ? 1 : 0,
    if (recipientName != null) 'recipient_name': recipientName,
    if (recipientPhone != null) 'recipient_phone': recipientPhone,
  };

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    String rawTag = (json['tag'] ?? json['address_type'] ?? 'Home').toString();
    if (rawTag.isNotEmpty) {
      rawTag = rawTag[0].toUpperCase() + rawTag.substring(1).toLowerCase();
    } else {
      rawTag = 'Home';
    }

    return AddressModel(
      id: (json['id'] ?? '').toString(),
      tag: rawTag,
      fullAddress: (json['fullAddress'] ?? json['complete_address'] ?? json['address'] ?? '').toString(),
      landmark: (json['landmark'] ?? '').toString(),
      latitude: (json['latitude'] != null)
          ? double.tryParse(json['latitude'].toString()) ?? 0.0
          : 0.0,
      longitude: (json['longitude'] != null)
          ? double.tryParse(json['longitude'].toString()) ?? 0.0
          : 0.0,
      isDefault: json['isDefault'] == true ||
          json['is_default'] == 1 ||
          json['is_default'] == true ||
          json['is_default'] == '1',
      recipientName: json['recipientName'] ?? json['recipient_name'],
      recipientPhone: json['recipientPhone'] ?? json['recipient_phone'],
    );
  }
}
