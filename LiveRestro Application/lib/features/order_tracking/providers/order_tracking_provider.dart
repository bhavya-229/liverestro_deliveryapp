import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/order_model.dart';

import '../../cart/models/cart_item_model.dart';
import '../../location/models/address_model.dart';
import '../../restaurant/data/mock_restaurants.dart';

final orderTrackingProvider = StateNotifierProvider<OrderTrackingNotifier, List<OrderModel>>((ref) {
  return OrderTrackingNotifier();
});

class OrderTrackingNotifier extends StateNotifier<List<OrderModel>> {
  OrderTrackingNotifier() : super(_getInitialOrders());

  static List<OrderModel> _getInitialOrders() {
    final restaurants = MockRestaurants.list;
    final r1 = restaurants[0]; // Chatkara
    final r2 = restaurants.length > 1 ? restaurants[1] : r1;
    final r3 = restaurants.length > 2 ? restaurants[2] : r1;

    final defaultAddress = const AddressModel(
      id: 'addr_home',
      tag: 'Home',
      fullAddress: 'A-402, Shivalik Yash, 132 Feet Ring Rd, Ahmedabad',
      landmark: 'Near Naranpura Cross Roads',
      latitude: 23.0525,
      longitude: 72.5328,
      isDefault: true,
    );

    return [
      // ACTIVE ORDER (shows in live banner)
      OrderModel(
        orderId: 'ORD_001',
        restaurantId: r1.id,
        restaurantName: 'Agashiye — The House of MG',
        items: [
          CartItemModel(
            menuItem: r1.menuItems[0],
            restaurantId: r1.id,
            restaurantName: 'Agashiye — The House of MG',
            quantity: 2,
          ),
          CartItemModel(
            menuItem: r1.menuItems.length > 1 ? r1.menuItems[1] : r1.menuItems[0],
            restaurantId: r1.id,
            restaurantName: 'Agashiye — The House of MG',
            quantity: 1,
          ),
        ],
        billAmount: 940,
        deliveryAddress: defaultAddress,
        paymentMethod: 'Google Pay',
        placedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        status: OrderStatus.preparing,
        etaMinutes: 18,
        customerName: 'Bhavya Makwana',
        customerPhone: '+91 98765 43210',
        riderName: 'Ramesh Kumar (Activa Fleet)',
        riderPhone: '+91 98765 12345',
        riderVehicleNumber: 'GJ-01 AB 2345',
      ),

      // DELIVERED
      OrderModel(
        orderId: 'ORD_002',
        restaurantId: r2.id,
        restaurantName: 'Green House Café',
        items: [
          CartItemModel(
            menuItem: r2.menuItems[0],
            restaurantId: r2.id,
            restaurantName: 'Green House Café',
            quantity: 2,
          ),
        ],
        billAmount: 420,
        deliveryAddress: defaultAddress,
        paymentMethod: 'PhonePe UPI',
        placedAt: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
        status: OrderStatus.delivered,
        etaMinutes: 0,
        customerName: 'Bhavya Makwana',
        customerPhone: '+91 98765 43210',
      ),

      // DELIVERED
      OrderModel(
        orderId: 'ORD_003',
        restaurantId: r1.id,
        restaurantName: 'Burger Singh',
        items: [
          CartItemModel(
            menuItem: r1.menuItems[0],
            restaurantId: r1.id,
            restaurantName: 'Burger Singh',
            quantity: 3,
          ),
        ],
        billAmount: 680,
        deliveryAddress: defaultAddress,
        paymentMethod: 'Google Pay',
        placedAt: DateTime.now().subtract(const Duration(days: 3, hours: 4)),
        status: OrderStatus.delivered,
        etaMinutes: 0,
        customerName: 'Bhavya Makwana',
        customerPhone: '+91 98765 43210',
      ),

      // CANCELLED
      OrderModel(
        orderId: 'ORD_004',
        restaurantId: r3.id,
        restaurantName: "La Pino'z Pizza",
        items: [
          CartItemModel(
            menuItem: r3.menuItems[0],
            restaurantId: r3.id,
            restaurantName: "La Pino'z Pizza",
            quantity: 1,
          ),
        ],
        billAmount: 399,
        refundAmount: 399,
        deliveryAddress: defaultAddress,
        paymentMethod: 'Paytm Wallet',
        placedAt: DateTime.now().subtract(const Duration(days: 5, hours: 10)),
        status: OrderStatus.cancelled,
        etaMinutes: 0,
        customerName: 'Bhavya Makwana',
        customerPhone: '+91 98765 43210',
      ),
    ];
  }

  Timer? _simulationTimer;

  void startNewOrder(OrderModel order) {
    state = [order, ...state];
    _startPosLifecycleSync(order.orderId);
  }

  void _startPosLifecycleSync(String orderId) {
    _simulationTimer?.cancel();

    _simulationTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final index = state.indexWhere((o) => o.orderId == orderId);
      if (index == -1) {
        timer.cancel();
        return;
      }

      // Try checking API server for status
      final remoteStatus = await ApiClient().getOrderStatus(orderId);
      if (remoteStatus != null && remoteStatus['status'] != null) {
        final statusStr = remoteStatus['status'].toString();
        OrderStatus parsedStatus;
        switch (statusStr) {
          case 'preparing':
            parsedStatus = OrderStatus.preparing;
            break;
          case 'ready':
            parsedStatus = OrderStatus.ready;
            break;
          case 'out_for_delivery':
            parsedStatus = OrderStatus.outForDelivery;
            break;
          case 'delivered':
          case 'settled':
            parsedStatus = OrderStatus.delivered;
            timer.cancel();
            break;
          default:
            parsedStatus = OrderStatus.placed;
        }

        final currentOrder = state[index];
        final updatedList = List<OrderModel>.from(state);
        updatedList[index] = currentOrder.copyWith(
          status: parsedStatus,
          etaMinutes: remoteStatus['eta_minutes'] ?? currentOrder.etaMinutes,
        );
        state = updatedList;
        return;
      }

      // Fallback local simulation progression if offline
      final currentOrder = state[index];
      OrderStatus nextStatus;
      int nextEta = currentOrder.etaMinutes;

      switch (currentOrder.status) {
        case OrderStatus.placed:
          nextStatus = OrderStatus.preparing;
          nextEta = 20;
          break;
        case OrderStatus.preparing:
          nextStatus = OrderStatus.ready;
          nextEta = 14;
          break;
        case OrderStatus.ready:
          nextStatus = OrderStatus.outForDelivery;
          nextEta = 8;
          break;
        case OrderStatus.outForDelivery:
          nextStatus = OrderStatus.delivered;
          nextEta = 0;
          timer.cancel();
          break;
        case OrderStatus.delivered:
        case OrderStatus.cancelled:
          timer.cancel();
          return;
      }

      final updatedList = List<OrderModel>.from(state);
      updatedList[index] = currentOrder.copyWith(
        status: nextStatus,
        etaMinutes: nextEta,
      );
      state = updatedList;
    });
  }

  void fastForwardStatus(String orderId) {
    final index = state.indexWhere((o) => o.orderId == orderId);
    if (index == -1) return;

    final currentOrder = state[index];
    OrderStatus nextStatus = OrderStatus.delivered;

    switch (currentOrder.status) {
      case OrderStatus.placed:
        nextStatus = OrderStatus.preparing;
        break;
      case OrderStatus.preparing:
        nextStatus = OrderStatus.ready;
        break;
      case OrderStatus.ready:
        nextStatus = OrderStatus.outForDelivery;
        break;
      case OrderStatus.outForDelivery:
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        nextStatus = OrderStatus.delivered;
        break;
    }

    final updatedList = List<OrderModel>.from(state);
    updatedList[index] = currentOrder.copyWith(status: nextStatus);
    state = updatedList;
  }
}
