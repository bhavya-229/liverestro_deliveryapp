import 'menu_item_model.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String tagline;
  final double rating;
  final int ratingCount;
  final int deliveryTimeMinutes;
  final double distanceKm;
  final double priceForTwo;
  final List<String> cuisines;
  final String imageUrl;
  final String coverUrl;
  final bool isPureVeg;
  final bool isPosConnected;
  final double? latitude;
  final double? longitude;
  final String? offerTag;
  final List<String> categories;
  final List<MenuItemModel> menuItems;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.rating,
    required this.ratingCount,
    required this.deliveryTimeMinutes,
    required this.distanceKm,
    required this.priceForTwo,
    required this.cuisines,
    required this.imageUrl,
    required this.coverUrl,
    required this.isPureVeg,
    this.isPosConnected = true,
    this.latitude,
    this.longitude,
    this.offerTag,
    required this.categories,
    required this.menuItems,
  });

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? tagline,
    double? rating,
    int? ratingCount,
    int? deliveryTimeMinutes,
    double? distanceKm,
    double? priceForTwo,
    List<String>? cuisines,
    String? imageUrl,
    String? coverUrl,
    bool? isPureVeg,
    bool? isPosConnected,
    double? latitude,
    double? longitude,
    String? offerTag,
    List<String>? categories,
    List<MenuItemModel>? menuItems,
  }) {
    return RestaurantModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tagline: tagline ?? this.tagline,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      deliveryTimeMinutes: deliveryTimeMinutes ?? this.deliveryTimeMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      priceForTwo: priceForTwo ?? this.priceForTwo,
      cuisines: cuisines ?? this.cuisines,
      imageUrl: imageUrl ?? this.imageUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      isPureVeg: isPureVeg ?? this.isPureVeg,
      isPosConnected: isPosConnected ?? this.isPosConnected,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      offerTag: offerTag ?? this.offerTag,
      categories: categories ?? this.categories,
      menuItems: menuItems ?? this.menuItems,
    );
  }

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    final restroId = (json['RestroID'] ?? json['id'] ?? '55').toString();

    final rawRating = json['rating'];
    final double parsedRating = rawRating is num
        ? rawRating.toDouble()
        : (double.tryParse(rawRating?.toString() ?? '4.5') ?? 4.5);

    final rawRatingCount = json['rating_count'] ?? json['ratingCount'];
    final int parsedRatingCount = rawRatingCount is int
        ? rawRatingCount
        : (rawRatingCount is num
            ? rawRatingCount.toInt()
            : (int.tryParse(rawRatingCount?.toString() ?? '100') ?? 100));

    final rawDeliveryTime = json['delivery_time_minutes'] ?? json['deliveryTimeMinutes'] ?? json['delivery_time'];
    final int parsedDeliveryTime = rawDeliveryTime is int
        ? rawDeliveryTime
        : (rawDeliveryTime is num
            ? rawDeliveryTime.toInt()
            : (int.tryParse(rawDeliveryTime?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '25') ?? 25));

    final rawDistance = json['distance_km'] ?? json['distanceKm'] ?? json['distance'];
    final double parsedDistance = rawDistance is num
        ? rawDistance.toDouble()
        : (double.tryParse(rawDistance?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '2.0') ?? 2.0);

    final rawPriceForTwo = json['price_for_two'] ?? json['priceForTwo'] ?? json['cost_for_two'];
    final double parsedPriceForTwo = rawPriceForTwo is num
        ? rawPriceForTwo.toDouble()
        : (double.tryParse(rawPriceForTwo?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '300') ?? 300.0);

    double? parsedLat;
    if (json['latitude'] != null) {
      final rawLat = json['latitude'];
      parsedLat = rawLat is num ? rawLat.toDouble() : double.tryParse(rawLat.toString());
    }

    double? parsedLng;
    if (json['longitude'] != null) {
      final rawLng = json['longitude'];
      parsedLng = rawLng is num ? rawLng.toDouble() : double.tryParse(rawLng.toString());
    }

    final rawMenuItems = (json['menuItems'] as List<dynamic>?)
            ?.map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>, restroId))
            .toList() ??
        <MenuItemModel>[];

    List<String> parsedCategories = (json['categories'] as List<dynamic>?)
            ?.map((c) => c.toString())
            .toList() ??
        [];
    if (parsedCategories.isEmpty && rawMenuItems.isNotEmpty) {
      parsedCategories = rawMenuItems.map((m) => m.category).toSet().toList();
    }

    return RestaurantModel(
      id: restroId,
      name: json['RestroName'] ?? json['name'] ?? '',
      tagline: json['tagline'] ?? json['RestroAddress'] ?? json['address'] ?? '',
      rating: parsedRating,
      ratingCount: parsedRatingCount,
      deliveryTimeMinutes: parsedDeliveryTime,
      distanceKm: parsedDistance,
      priceForTwo: parsedPriceForTwo,
      cuisines: (json['cuisines'] as List<dynamic>?)?.map((c) => c.toString()).toList() ??
          (parsedCategories.isNotEmpty ? parsedCategories.take(4).toList() : ['Fast Food']),
      imageUrl: json['imageUrl'] ?? json['featured_image'] ?? 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
      coverUrl: json['coverUrl'] ?? 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1200&q=80',
      isPureVeg: (json['is_pure_veg'] == 1 || json['is_pure_veg'] == '1' || json['isPureVeg'] == true),
      isPosConnected: (json['is_pos_connected'] == 1 || json['is_pos_connected'] == '1' || json['isPosConnected'] == true),
      latitude: parsedLat,
      longitude: parsedLng,
      offerTag: json['offerTag'] ?? json['offer_text'],
      categories: parsedCategories,
      menuItems: rawMenuItems,
    );
  }
}
