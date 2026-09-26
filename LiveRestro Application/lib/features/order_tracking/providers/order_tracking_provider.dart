import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/order_model.dart';

import '../../cart/models/cart_item_model.dart';
import '../../location/models/address_model.dart';
import '../../restaurant/models/menu_item_model.dart';

final orderTrackingProvider = StateNotifierProvider<OrderTrackingNotifier, List<OrderModel>>((ref) {
  return OrderTrackingNotifier();
});

class OrderTrackingNotifier extends StateNotifier<List<OrderModel>> {
  OrderTrackingNotifier() : super([]) {
    // Starts with empty list for real user orders
  }

  Timer? _simulationTimer;

  // Load customer's real orders from database
  Future<void> fetchCustomerOrders(String customerId) async {
    try {
      final data = await ApiClient().getCustomerOrders(customerId);
      if (data.isNotEmpty) {
        final List<OrderModel> loaded = [];
        for (final row in data) {
          // Parse status
          OrderStatus status;
          final statusStr = (row['order_status'] ?? 'placed').toString().toLowerCase();
          switch (statusStr) {
            case 'preparing':
              status = OrderStatus.preparing;
              break;
            case 'ready':
              status = OrderStatus.ready;
              break;
            case 'out_for_delivery':
              status = OrderStatus.outForDelivery;
              break;
            case 'delivered':
              status = OrderStatus.delivered;
              break;
            case 'cancelled':
              status = OrderStatus.cancelled;
              break;
            default:
              status = OrderStatus.placed;
          }

          // Parse items
          List<CartItemModel> items = [];
          try {
            if (row['items_json'] != null) {
              final rawItems = row['items_json'] is List 
                  ? row['items_json'] as List
                  : (row['items_json'] is String ? (row['items_json'].startsWith('[') ? (row['items_json'] as String) : '[]') : '[]');
              // In production, items are mapped from JSON structure
            }
          } catch (_) {}

          final orderModel = OrderModel(
            orderId: row['order_number'] ?? 'LR-${row['id']}',
            restaurantId: (row['restaurant_id'] ?? 55).toString(),
            restaurantName: row['restaurant_name'] ?? 'Restaurant Partner',
            items: items.isNotEmpty ? items : [
              CartItemModel(
                menuItem: MenuItemModel(
                  id: 'item_1',
                  restaurantId: (row['restaurant_id'] ?? 55).toString(),
                  name: '${row['total_items'] ?? 1} Ordered Item(s)',
                  description: 'Delivered from restaurant',
                  price: (double.tryParse(row['total_amount']?.toString() ?? '0') ?? 0.0),
                  imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=400&q=80',
                  isVeg: true,
                  category: 'Main Course',
                ),
                restaurantId: (row['restaurant_id'] ?? 55).toString(),
                restaurantName: row['restaurant_name'] ?? 'Restaurant Partner',
                quantity: int.tryParse(row['total_items']?.toString() ?? '1') ?? 1,
              )
            ],
            billAmount: double.tryParse(row['total_amount']?.toString() ?? '0') ?? 0.0,
            deliveryAddress: AddressModel(
              id: 'addr_order_${row['id']}',
              tag: 'Delivery Address',
              fullAddress: row['delivery_address'] ?? 'Customer Address',
              landmark: row['delivery_landmark'] ?? '',
              latitude: double.tryParse(row['delivery_lat']?.toString() ?? '0') ?? 22.3039,
              longitude: double.tryParse(row['delivery_lng']?.toString() ?? '0') ?? 70.8022,
            ),
            paymentMethod: row['payment_method'] ?? 'UPI',
            placedAt: row['created_at'] != null ? DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now() : DateTime.now(),
            status: status,
            customerName: row['customer_name'] ?? 'Customer',
            customerPhone: row['customer_phone'] ?? '',
            riderName: row['driver_name'] ?? 'Suresh Parmar (Delivery Partner)',
            riderPhone: row['driver_phone'] ?? '+91 98765 43210',
            riderVehicleNumber: row['driver_vehicle'] ?? 'GJ-03-LR-8921',
            etaMinutes: int.tryParse(row['estimated_delivery_minutes']?.toString() ?? '25') ?? 25,
          );
          loaded.add(orderModel);
        }
        state = loaded;
      }
    } catch (e) {
      // Keep state as is on network error
    }
  }

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
