import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../data/mock_restaurants.dart';
import '../models/restaurant_model.dart';
import '../../auth/providers/auth_provider.dart';

final restaurantSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'All');

final rawRestaurantsProvider = StateNotifierProvider<RestaurantsNotifier, List<RestaurantModel>>((ref) {
  return RestaurantsNotifier();
});

class RestaurantsNotifier extends StateNotifier<List<RestaurantModel>> {
  RestaurantsNotifier() : super(MockRestaurants.list) {
    loadRestaurants();
  }

  Future<void> loadRestaurants() async {
    try {
      final remoteList = await ApiClient().getRestaurants();
      if (remoteList.isNotEmpty) {
        state = remoteList;
      }
    } catch (_) {
      // Keep fallback mock list
    }
  }
}

final restaurantListProvider = Provider<List<RestaurantModel>>((ref) {
  final query = ref.watch(restaurantSearchQueryProvider).trim().toLowerCase();
  final categoryFilter = ref.watch(selectedCategoryFilterProvider);
  final user = ref.watch(authProvider).user;
  final isVegOnlyUser = user?.isVegOnly ?? false;

  var list = ref.watch(rawRestaurantsProvider);

  if (isVegOnlyUser) {
    list = list.where((r) => r.isPureVeg).toList();
  }

  if (categoryFilter != 'All') {
    list = list.where((r) => r.cuisines.contains(categoryFilter)).toList();
  }

  if (query.isNotEmpty) {
    list = list.where((r) {
      final nameMatches = r.name.toLowerCase().contains(query);
      final cuisineMatches = r.cuisines.any((c) => c.toLowerCase().contains(query));
      final itemMatches = r.menuItems.any((i) => i.name.toLowerCase().contains(query));
      return nameMatches || cuisineMatches || itemMatches;
    }).toList();
  }

  return list;
});

final restaurantDetailProvider = Provider.family<RestaurantModel?, String>((ref, restaurantId) {
  final list = ref.watch(rawRestaurantsProvider);
  final cleanId = restaurantId.replaceAll('rest_', '').toLowerCase();

  try {
    RestaurantModel restro = list.firstWhere(
      (r) => r.id == restaurantId || r.id == cleanId || r.name.toLowerCase().contains(cleanId),
    );

    // If remote list had empty menuItems for any reason, merge from MockRestaurants
    if (restro.menuItems.isEmpty) {
      final fallback = MockRestaurants.list.firstWhere(
        (m) => m.name.toLowerCase().contains(cleanId) || m.id == restaurantId,
        orElse: () => MockRestaurants.list.first,
      );
      restro = RestaurantModel(
        id: restro.id,
        name: restro.name,
        tagline: restro.tagline,
        rating: restro.rating,
        ratingCount: restro.ratingCount,
        deliveryTimeMinutes: restro.deliveryTimeMinutes,
        distanceKm: restro.distanceKm,
        priceForTwo: restro.priceForTwo,
        cuisines: restro.cuisines,
        imageUrl: restro.imageUrl,
        coverUrl: restro.coverUrl,
        isPureVeg: restro.isPureVeg,
        isPosConnected: restro.isPosConnected,
        offerTag: restro.offerTag,
        categories: restro.categories.isNotEmpty ? restro.categories : fallback.categories,
        menuItems: fallback.menuItems,
      );
    }
    return restro;
  } catch (_) {
    try {
      return MockRestaurants.list.firstWhere(
        (r) => r.id == restaurantId || r.name.toLowerCase().contains(cleanId),
      );
    } catch (_) {
      return null;
    }
  }
});
