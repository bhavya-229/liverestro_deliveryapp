import '../../cart/models/cart_item_model.dart';
import '../../location/models/address_model.dart';

enum OrderStatus {
  placed,
  preparing,
  ready,
  outForDelivery,
  delivered,
}

class OrderModel {
  final String orderId;
  final String restaurantId;
  final String restaurantName;
  final List<CartItemModel> items;
  final double billAmount;
  final AddressModel deliveryAddress;
  final String paymentMethod;
  final DateTime placedAt;
  final OrderStatus status;
  final String customerName;
  final String customerPhone;
  final String? riderName;
  final String? riderPhone;
  final String? riderVehicleNumber;
  final int etaMinutes;

  const OrderModel({
    required this.orderId,
    required this.restaurantId,
    required this.restaurantName,
    required this.items,
    required this.billAmount,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.placedAt,
    this.status = OrderStatus.placed,
    required this.customerName,
    required this.customerPhone,
    this.riderName = 'Ramesh Kumar (Shadowfax/Rapido Fleet)',
    this.riderPhone = '+91 98251 09876',
    this.riderVehicleNumber = 'GJ 03 EK 4492',
    this.etaMinutes = 25,
  });

  OrderModel copyWith({
    String? orderId,
    String? restaurantId,
    String? restaurantName,
    List<CartItemModel>? items,
    double? billAmount,
    AddressModel? deliveryAddress,
    String? paymentMethod,
    DateTime? placedAt,
    OrderStatus? status,
    String? customerName,
    String? customerPhone,
    String? riderName,
    String? riderPhone,
    String? riderVehicleNumber,
    int? etaMinutes,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      billAmount: billAmount ?? this.billAmount,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      placedAt: placedAt ?? this.placedAt,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      riderVehicleNumber: riderVehicleNumber ?? this.riderVehicleNumber,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }
}
