class MenuItemCustomization {
  final String title;
  final List<CustomizationOption> options;
  final bool isRequired;

  const MenuItemCustomization({
    required this.title,
    required this.options,
    this.isRequired = false,
  });

  factory MenuItemCustomization.fromJson(Map<String, dynamic> json) {
    return MenuItemCustomization(
      title: json['title'] ?? '',
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      options: (json['options'] as List<dynamic>?)
              ?.map((o) => CustomizationOption.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CustomizationOption {
  final String name;
  final double extraPrice;

  const CustomizationOption({
    required this.name,
    this.extraPrice = 0.0,
  });

  factory CustomizationOption.fromJson(Map<String, dynamic> json) {
    return CustomizationOption(
      name: json['name'] ?? '',
      extraPrice: (json['extra_price'] ?? json['price_modifier'] ?? json['extraPrice'] ?? 0.0).toDouble(),
    );
  }
}

class MenuItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final bool isVeg;
  final bool isBestseller;
  final double rating;
  final int ratingCount;
  final String category;
  final List<MenuItemCustomization> customizations;

  const MenuItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.isVeg,
    this.isBestseller = false,
    this.rating = 4.5,
    this.ratingCount = 80,
    required this.category,
    this.customizations = const [],
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json, [String? fallbackRestroId]) {
    final rawPrice = json['item_price'] ?? json['price'];
    final double parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : (double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0);

    final rawRating = json['rating'];
    final double parsedRating = rawRating is num
        ? rawRating.toDouble()
        : (double.tryParse(rawRating?.toString() ?? '4.5') ?? 4.5);

    final rawRatingCount = json['rating_count'] ?? json['ratingCount'];
    final int parsedRatingCount = rawRatingCount is int
        ? rawRatingCount
        : (rawRatingCount is num
            ? rawRatingCount.toInt()
            : (int.tryParse(rawRatingCount?.toString() ?? '80') ?? 80));

    final rawVeg = json['is_veg'] ?? json['isVeg'];
    final isVegFlag = (rawVeg == 1 || rawVeg == '1' || rawVeg == true);

    return MenuItemModel(
      id: (json['id'] ?? json['item_id'] ?? '').toString(),
      restaurantId: (json['RestroID'] ?? json['restaurantId'] ?? fallbackRestroId ?? '55').toString(),
      name: json['item_name'] ?? json['name'] ?? '',
      description: json['item_description'] ?? json['description'] ?? '',
      price: parsedPrice,
      imageUrl: (json['item_image'] != null && json['item_image'].toString().startsWith('http'))
          ? json['item_image']
          : (json['imageUrl'] ?? 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=400&q=80'),
      isVeg: (isVegFlag &&
          !(json['item_name'] ?? json['name'] ?? '').toString().toLowerCase().contains('chicken') &&
          !(json['item_name'] ?? json['name'] ?? '').toString().toLowerCase().contains('mutton') &&
          !(json['item_name'] ?? json['name'] ?? '').toString().toLowerCase().contains('fish') &&
          !(json['item_name'] ?? json['name'] ?? '').toString().toLowerCase().contains('wings') &&
          !(json['item_name'] ?? json['name'] ?? '').toString().toLowerCase().contains('egg') &&
          !(json['item_name'] ?? json['name'] ?? '').toString().toLowerCase().contains('meat')),
      isBestseller: json['is_bestseller'] == 1 || json['is_bestseller'] == '1' || json['isBestseller'] == true,
      rating: parsedRating,
      ratingCount: parsedRatingCount,
      category: json['category'] ?? json['category_name'] ?? 'General',
      customizations: (json['customizations'] as List<dynamic>?)
              ?.map((c) => MenuItemCustomization.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
