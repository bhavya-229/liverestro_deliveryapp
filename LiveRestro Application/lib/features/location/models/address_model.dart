class AddressModel {
  final String id;
  final String tag; // Home, Work, Other
  final String fullAddress;
  final String landmark;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.tag,
    required this.fullAddress,
    required this.landmark,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  AddressModel copyWith({
    String? id,
    String? tag,
    String? fullAddress,
    String? landmark,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      tag: tag ?? this.tag,
      fullAddress: fullAddress ?? this.fullAddress,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
