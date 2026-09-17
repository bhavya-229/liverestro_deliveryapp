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
    this.offerTag,
    required this.categories,
    required this.menuItems,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: (json['RestroID'] ?? json['id'] ?? '55').toString(),
      name: json['RestroName'] ?? json['name'] ?? '',
      tagline: json['tagline'] ?? json['RestroAddress'] ?? '',
      rating: (json['rating'] ?? 4.5).toDouble(),
      ratingCount: json['rating_count'] ?? json['ratingCount'] ?? 100,
      deliveryTimeMinutes: json['delivery_time_minutes'] ?? json['deliveryTimeMinutes'] ?? 25,
      distanceKm: (json['distance_km'] ?? json['distanceKm'] ?? 2.0).toDouble(),
      priceForTwo: (json['price_for_two'] ?? json['priceForTwo'] ?? 300).toDouble(),
      cuisines: (json['cuisines'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? ['Fast Food'],
      imageUrl: json['imageUrl'] ?? 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=600&q=80',
      coverUrl: json['coverUrl'] ?? 'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1200&q=80',
      isPureVeg: (json['is_pure_veg'] == 1 || json['isPureVeg'] == true),
      isPosConnected: (json['is_pos_connected'] == 1 || json['isPosConnected'] == true),
      offerTag: json['offerTag'],
      categories: (json['categories'] as List<dynamic>?)?.map((c) => c.toString()).toList() ?? [],
      menuItems: (json['menuItems'] as List<dynamic>?)
              ?.map((item) => MenuItemModel.fromJson(item as Map<String, dynamic>, (json['RestroID'] ?? json['id'] ?? '55').toString()))
              .toList() ??
          [],
    );
  }
}
