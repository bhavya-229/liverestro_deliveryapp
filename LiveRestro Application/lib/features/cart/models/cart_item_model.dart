import '../../restaurant/models/menu_item_model.dart';

class CartItemModel {
  final MenuItemModel menuItem;
  final String restaurantId;
  final String restaurantName;
  final int quantity;
  final String? selectedOption;
  final double extraPrice;
  final String? specialInstructions;

  const CartItemModel({
    required this.menuItem,
    required this.restaurantId,
    required this.restaurantName,
    this.quantity = 1,
    this.selectedOption,
    this.extraPrice = 0.0,
    this.specialInstructions,
  });

  double get unitPrice => menuItem.price + extraPrice;
  double get totalPrice => unitPrice * quantity;

  CartItemModel copyWith({
    MenuItemModel? menuItem,
    String? restaurantId,
    String? restaurantName,
    int? quantity,
    String? selectedOption,
    double? extraPrice,
    String? specialInstructions,
  }) {
    return CartItemModel(
      menuItem: menuItem ?? this.menuItem,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      quantity: quantity ?? this.quantity,
      selectedOption: selectedOption ?? this.selectedOption,
      extraPrice: extraPrice ?? this.extraPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}
