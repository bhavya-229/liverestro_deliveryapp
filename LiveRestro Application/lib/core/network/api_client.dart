import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../features/restaurant/data/mock_restaurants.dart';
import '../../features/restaurant/models/restaurant_model.dart';
import '../../features/restaurant/models/menu_item_model.dart';
import 'api_endpoints.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String get _activeBaseUrl => kIsWeb ? ApiEndpoints.localhostUrl : ApiEndpoints.baseUrl;

  // 1. Fetch Restaurants
  Future<List<RestaurantModel>> getRestaurants({
    String? search,
    bool? isVeg,
    String? cuisine,
  }) async {
    if (ApiEndpoints.useOfflineMockOnly) {
      var list = MockRestaurants.list;
      if (isVeg == true) list = list.where((r) => r.isPureVeg).toList();
      if (cuisine != null && cuisine != 'All') {
        list = list.where((r) => r.cuisines.contains(cuisine)).toList();
      }
      if (search != null && search.isNotEmpty) {
        list = list.where((r) => r.name.toLowerCase().contains(search.toLowerCase())).toList();
      }
      return list;
    }

    try {
      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (isVeg != null && isVeg) queryParams['is_veg'] = '1';
      if (cuisine != null && cuisine != 'All') queryParams['cuisine'] = cuisine;

      final uri = Uri.parse('$_activeBaseUrl${ApiEndpoints.restaurants}').replace(queryParameters: queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] is List) {
          return (data['data'] as List).map((json) => RestaurantModel.fromJson(json)).toList();
        }
      }
    } catch (e) {
      debugPrint('ApiClient.getRestaurants failed: $e. Falling back to local dataset.');
    }

    // Fallback to local data
    var list = MockRestaurants.list;
    if (isVeg == true) list = list.where((r) => r.isPureVeg).toList();
    if (cuisine != null && cuisine != 'All') {
      list = list.where((r) => r.cuisines.contains(cuisine)).toList();
    }
    if (search != null && search.isNotEmpty) {
      list = list.where((r) => r.name.toLowerCase().contains(search.toLowerCase())).toList();
    }
    return list;
  }

  // 2. Fetch Restaurant Menu & Categories
  Future<List<MenuItemModel>> getRestaurantMenu(String restaurantId) async {
    if (ApiEndpoints.useOfflineMockOnly) {
      final restro = MockRestaurants.list.firstWhere(
        (r) => r.id == restaurantId,
        orElse: () => MockRestaurants.list.first,
      );
      return restro.menuItems;
    }

    try {
      final uri = Uri.parse('$_activeBaseUrl${ApiEndpoints.restaurantMenu(restaurantId)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['categories'] is List) {
          final List<MenuItemModel> allItems = [];
          for (final cat in data['categories']) {
            final catName = cat['category_name'] ?? 'General';
            if (cat['items'] is List) {
              for (final itemJson in cat['items']) {
                itemJson['category'] = catName;
                allItems.add(MenuItemModel.fromJson(itemJson, restaurantId));
              }
            }
          }
          if (allItems.isNotEmpty) return allItems;
        }
      }
    } catch (e) {
      debugPrint('ApiClient.getRestaurantMenu failed: $e. Falling back to local menu items.');
    }

    // Fallback to local mock data
    final restro = MockRestaurants.list.firstWhere(
      (r) => r.id == restaurantId,
      orElse: () => MockRestaurants.list.first,
    );
    return restro.menuItems;
  }

  // 3. Place / Create Order into LiveRestro POS
  Future<Map<String, dynamic>?> createOrder({
    required String restaurantId,
    required String customerName,
    required String customerPhone,
    required String deliveryAddress,
    required String paymentMethod,
    required double totalAmount,
    required List<Map<String, dynamic>> items,
    String? specialNotes,
    double? deliveryTip,
  }) async {
    if (ApiEndpoints.useOfflineMockOnly) {
      return {
        'order_number': 'LR-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        'status': 'placed',
        'eta_minutes': 35,
      };
    }

    try {
      final uri = Uri.parse('$_activeBaseUrl${ApiEndpoints.createOrder}');
      final payload = {
        'restro_id': restaurantId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
        'total_amount': totalAmount,
        'items': items,
        'special_notes': specialNotes ?? '',
        'delivery_tip': deliveryTip ?? 0.0,
      };

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
    } catch (e) {
      debugPrint('ApiClient.createOrder failed: $e.');
    }
    return null;
  }

  // 4. Get Live POS Order Status
  Future<Map<String, dynamic>?> getOrderStatus(String orderNumber) async {
    if (ApiEndpoints.useOfflineMockOnly) {
      return null;
    }

    try {
      final uri = Uri.parse('$_activeBaseUrl${ApiEndpoints.orderStatus(orderNumber)}');
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
    } catch (e) {
      debugPrint('ApiClient.getOrderStatus failed: $e.');
    }
    return null;
  }
}
