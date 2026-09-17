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
    return MenuItemModel(
      id: (json['id'] ?? json['item_id'] ?? '').toString(),
      restaurantId: (json['RestroID'] ?? json['restaurantId'] ?? fallbackRestroId ?? '55').toString(),
      name: json['item_name'] ?? json['name'] ?? '',
      description: json['item_description'] ?? json['description'] ?? '',
      price: (json['item_price'] ?? json['price'] ?? 0.0).toDouble(),
      imageUrl: (json['item_image'] != null && json['item_image'].toString().startsWith('http'))
          ? json['item_image']
          : (json['imageUrl'] ?? 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=400&q=80'),
      isVeg: json['is_veg'] == 1 || json['isVeg'] == true,
      isBestseller: json['is_bestseller'] == 1 || json['isBestseller'] == true,
      rating: (json['rating'] ?? 4.5).toDouble(),
      ratingCount: json['rating_count'] ?? json['ratingCount'] ?? 80,
      category: json['category'] ?? json['category_name'] ?? 'General',
      customizations: (json['customizations'] as List<dynamic>?)
              ?.map((c) => MenuItemCustomization.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
