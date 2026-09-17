import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';

class PromoCodeModel {
  final String code;
  final String description;
  final double discountPercentage;
  final double maxDiscount;
  final double minOrderAmount;

  const PromoCodeModel({
    required this.code,
    required this.description,
    required this.discountPercentage,
    required this.maxDiscount,
    required this.minOrderAmount,
  });
}

class CartState {
  final List<CartItemModel> items;
  final String? restaurantId;
  final String? restaurantName;
  final PromoCodeModel? appliedPromo;
  final double deliveryTip;
  final String deliveryInstructions;

  const CartState({
    this.items = const [],
    this.restaurantId,
    this.restaurantName,
    this.appliedPromo,
    this.deliveryTip = 0.0,
    this.deliveryInstructions = '',
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);
  double get itemTotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);
  
  double get deliveryFee => itemTotal > 399 ? 0.0 : 35.0;
  double get platformFee => items.isEmpty ? 0.0 : 5.0;
  double get taxesAndGst => itemTotal * 0.05;

  double get discountAmount {
    if (appliedPromo == null || itemTotal < appliedPromo!.minOrderAmount) return 0.0;
    final calc = itemTotal * (appliedPromo!.discountPercentage / 100);
    return calc > appliedPromo!.maxDiscount ? appliedPromo!.maxDiscount : calc;
  }

  double get finalAmount {
    if (items.isEmpty) return 0.0;
    final total = itemTotal + deliveryFee + platformFee + taxesAndGst + deliveryTip - discountAmount;
    return total > 0 ? total : 0.0;
  }

  int getItemQuantity(String menuItemId) {
    for (final it in items) {
      if (it.menuItem.id == menuItemId) return it.quantity;
    }
    return 0;
  }

  CartState copyWith({
    List<CartItemModel>? items,
    String? restaurantId,
    String? restaurantName,
    PromoCodeModel? appliedPromo,
    double? deliveryTip,
    String? deliveryInstructions,
    bool clearPromo = false,
  }) {
    return CartState(
      items: items ?? this.items,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      appliedPromo: clearPromo ? null : (appliedPromo ?? this.appliedPromo),
      deliveryTip: deliveryTip ?? this.deliveryTip,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  static const List<PromoCodeModel> availablePromos = [
    PromoCodeModel(
      code: 'WELCOME100',
      description: '₹100 flat OFF on first order above ₹199',
      discountPercentage: 50,
      maxDiscount: 100,
      minOrderAmount: 199,
    ),
    PromoCodeModel(
      code: 'LIVERESTRO50',
      description: '50% OFF up to ₹120 on POS partner restaurants',
      discountPercentage: 50,
      maxDiscount: 120,
      minOrderAmount: 249,
    ),
    PromoCodeModel(
      code: 'FREESHIP',
      description: '100% Free Delivery on orders above ₹149',
      discountPercentage: 100,
      maxDiscount: 35,
      minOrderAmount: 149,
    ),
  ];

  void addItem(CartItemModel newItem) {
    if (state.restaurantId != null && state.restaurantId != newItem.restaurantId) {
      state = CartState(
        items: [newItem],
        restaurantId: newItem.restaurantId,
        restaurantName: newItem.restaurantName,
      );
      return;
    }

    final index = state.items.indexWhere(
      (it) => it.menuItem.id == newItem.menuItem.id && it.selectedOption == newItem.selectedOption,
    );

    if (index >= 0) {
      final updatedList = List<CartItemModel>.from(state.items);
      final current = updatedList[index];
      updatedList[index] = current.copyWith(quantity: current.quantity + newItem.quantity);
      state = state.copyWith(items: updatedList);
    } else {
      state = state.copyWith(
        items: [...state.items, newItem],
        restaurantId: newItem.restaurantId,
        restaurantName: newItem.restaurantName,
      );
    }
  }

  void incrementQuantity(String menuItemId) {
    final index = state.items.indexWhere((it) => it.menuItem.id == menuItemId);
    if (index >= 0) {
      final updatedList = List<CartItemModel>.from(state.items);
      updatedList[index] = updatedList[index].copyWith(quantity: updatedList[index].quantity + 1);
      state = state.copyWith(items: updatedList);
    }
  }

  void decrementQuantity(String menuItemId) {
    final index = state.items.indexWhere((it) => it.menuItem.id == menuItemId);
    if (index >= 0) {
      final updatedList = List<CartItemModel>.from(state.items);
      if (updatedList[index].quantity > 1) {
        updatedList[index] = updatedList[index].copyWith(quantity: updatedList[index].quantity - 1);
        state = state.copyWith(items: updatedList);
      } else {
        updatedList.removeAt(index);
        if (updatedList.isEmpty) {
          state = const CartState();
        } else {
          state = state.copyWith(items: updatedList);
        }
      }
    }
  }

  void applyPromo(PromoCodeModel promo) {
    state = state.copyWith(appliedPromo: promo);
  }

  void removePromo() {
    state = state.copyWith(clearPromo: true);
  }

  void setDeliveryTip(double tip) {
    state = state.copyWith(deliveryTip: tip);
  }

  void setDeliveryInstructions(String instructions) {
    state = state.copyWith(deliveryInstructions: instructions);
  }

  void clearCart() {
    state = const CartState();
  }
}
