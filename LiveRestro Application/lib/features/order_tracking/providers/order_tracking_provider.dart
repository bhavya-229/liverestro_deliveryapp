import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/order_model.dart';

final orderTrackingProvider = StateNotifierProvider<OrderTrackingNotifier, List<OrderModel>>((ref) {
  return OrderTrackingNotifier();
});

class OrderTrackingNotifier extends StateNotifier<List<OrderModel>> {
  OrderTrackingNotifier() : super([]);

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
        nextStatus = OrderStatus.delivered;
        break;
    }

    final updatedList = List<OrderModel>.from(state);
    updatedList[index] = currentOrder.copyWith(status: nextStatus);
    state = updatedList;
  }
}
