import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../../core/network/api_client.dart';
import '../data/mock_restaurants.dart';
import '../models/restaurant_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../location/providers/location_provider.dart';

final restaurantSearchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryFilterProvider = StateProvider<String>((ref) => 'All');
final maxDeliveryRadiusKmProvider = StateProvider<double>((ref) => 15.0);

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
  final activeAddress = ref.watch(locationProvider).activeAddress;
  final maxRadiusKm = ref.watch(maxDeliveryRadiusKmProvider);

  const distanceCalc = ll.Distance();
  final userLatLng = ll.LatLng(activeAddress.latitude, activeAddress.longitude);

  var rawList = ref.watch(rawRestaurantsProvider);

  // 1. Calculate real-time distance from user's active address and filter within 15 km
  final List<RestaurantModel> listWithDistance = [];

  for (final restro in rawList) {
    double computedDistanceKm = restro.distanceKm;

    if (restro.latitude != null && restro.longitude != null) {
      final restroLatLng = ll.LatLng(restro.latitude!, restro.longitude!);
      // distance in meters converted to km
      final meters = distanceCalc.as(ll.LengthUnit.Meter, userLatLng, restroLatLng);
      computedDistanceKm = (meters / 1000.0);
      computedDistanceKm = double.parse(computedDistanceKm.toStringAsFixed(1));
    }

    // Include if within radius (e.g., 15 km)
    if (computedDistanceKm <= maxRadiusKm) {
      final estimatedMinutes = 15 + (computedDistanceKm * 3.5).round();
      listWithDistance.add(
        restro.copyWith(
          distanceKm: computedDistanceKm,
          deliveryTimeMinutes: estimatedMinutes,
        ),
      );
    }
  }

  // If no restaurants match within 15 km (e.g., test device in different city/state without nearby outlets),
  // fall back to showing all available restaurants with their actual distances so user can still test & order
  if (listWithDistance.isEmpty && rawList.isNotEmpty) {
    for (final restro in rawList) {
      double computedDistanceKm = restro.distanceKm;
      if (restro.latitude != null && restro.longitude != null) {
        final restroLatLng = ll.LatLng(restro.latitude!, restro.longitude!);
        final meters = distanceCalc.as(ll.LengthUnit.Meter, userLatLng, restroLatLng);
        computedDistanceKm = double.parse((meters / 1000.0).toStringAsFixed(1));
      }
      final estimatedMinutes = 15 + (computedDistanceKm * 3.5).round();
      listWithDistance.add(
        restro.copyWith(
          distanceKm: computedDistanceKm,
          deliveryTimeMinutes: estimatedMinutes,
        ),
      );
    }
  }

  // Sort by nearest distance first
  listWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

  var list = listWithDistance;

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
