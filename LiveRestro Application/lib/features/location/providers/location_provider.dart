import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/api_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/address_model.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref);
});

class LocationState {
  final AddressModel activeAddress;
  final List<AddressModel> savedAddresses;
  final bool isLoading;
  final String? errorMessage;

  const LocationState({
    required this.activeAddress,
    required this.savedAddresses,
    this.isLoading = false,
    this.errorMessage,
  });

  LocationState copyWith({
    AddressModel? activeAddress,
    List<AddressModel>? savedAddresses,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LocationState(
      activeAddress: activeAddress ?? this.activeAddress,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final Ref _ref;

  static const String _savedAddressesKey = 'live_restro_saved_addresses';
  static const String _activeAddressKey = 'live_restro_active_address';

  static const AddressModel _defaultAddress = AddressModel(
    id: 'addr_default',
    tag: 'Home',
    fullAddress: 'A-402, Shivam Heights, University Road, Rajkot, Gujarat',
    landmark: 'Near Kotecha Chowk',
    latitude: 22.3039,
    longitude: 70.8022,
    isDefault: true,
  );

  LocationNotifier(this._ref)
      : super(
          const LocationState(
            activeAddress: _defaultAddress,
            savedAddresses: [],
          ),
        ) {
    _initLocationState();
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && next.user != null) {
        syncCustomerAddresses(next.user!.id);
      }
    });
  }

  Future<void> _initLocationState() async {
    await _loadFromLocal();

    // Check if user is already logged in
    final authState = _ref.read(authProvider);
    if (authState.isAuthenticated && authState.user != null) {
      await syncCustomerAddresses(authState.user!.id);
    }

    // Attempt GPS detection for accurate current coordinates
    await detectCurrentGPSLocation();
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load active address
      final activeStr = prefs.getString(_activeAddressKey);
      AddressModel? activeAddr;
      if (activeStr != null && activeStr.isNotEmpty) {
        final decoded = jsonDecode(activeStr);
        if (decoded is Map<String, dynamic>) {
          activeAddr = AddressModel.fromJson(decoded);
        }
      }

      // Load saved addresses
      final savedStr = prefs.getString(_savedAddressesKey);
      List<AddressModel> savedList = [];
      if (savedStr != null && savedStr.isNotEmpty) {
        final decoded = jsonDecode(savedStr);
        if (decoded is List) {
          savedList = decoded
              .whereType<Map<String, dynamic>>()
              .map((item) => AddressModel.fromJson(item))
              .toList();
        }
      }

      state = state.copyWith(
        activeAddress: activeAddr ?? (savedList.isNotEmpty ? savedList.first : state.activeAddress),
        savedAddresses: savedList,
      );
    } catch (e) {
      debugPrint('[LocationNotifier] Error loading stored addresses: $e');
    }
  }

  Future<void> _persistToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeAddressKey, jsonEncode(state.activeAddress.toJson()));
      final savedListJson = state.savedAddresses.map((a) => a.toJson()).toList();
      await prefs.setString(_savedAddressesKey, jsonEncode(savedListJson));
    } catch (e) {
      debugPrint('[LocationNotifier] Error persisting addresses: $e');
    }
  }

  Future<void> syncCustomerAddresses([String? customerId]) async {
    final targetId = customerId ?? _ref.read(authProvider).user?.id;
    if (targetId == null || targetId.isEmpty) return;

    try {
      final backendAddresses = await ApiClient().getCustomerAddresses(targetId);
      if (backendAddresses.isNotEmpty) {
        // Merge backend addresses with existing saved addresses
        final Map<String, AddressModel> addressMap = {};
        for (final a in state.savedAddresses) {
          addressMap[a.id] = a;
        }
        for (final a in backendAddresses) {
          addressMap[a.id] = a;
        }

        final mergedList = addressMap.values.toList();
        // If current active is still placeholder default, pick default or first from backend
        AddressModel newActive = state.activeAddress;
        if (newActive.id == 'addr_default') {
          newActive = mergedList.firstWhere((a) => a.isDefault, orElse: () => mergedList.first);
        }

        state = state.copyWith(
          savedAddresses: mergedList,
          activeAddress: newActive,
        );
        await _persistToLocal();
      }
    } catch (e) {
      debugPrint('[LocationNotifier] syncCustomerAddresses failed: $e');
    }
  }

  Future<void> detectCurrentGPSLocation() async {
    try {
      state = state.copyWith(isLoading: true);

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(isLoading: false);
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          state = state.copyWith(isLoading: false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      String formattedAddress = 'GPS (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      String landmark = 'Current Location';

      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'LiveRestroDeliveryApp/1.0'},
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['display_name'] != null) {
            formattedAddress = data['display_name'].toString();
            final addressObj = data['address'] as Map<String, dynamic>?;
            if (addressObj != null) {
              landmark = addressObj['suburb'] ??
                  addressObj['neighbourhood'] ??
                  addressObj['city'] ??
                  addressObj['town'] ??
                  'Current Area';
            }
          }
        }
      } catch (_) {
        // Fallback to coordinates string
      }

      final gpsAddress = AddressModel(
        id: 'addr_gps',
        tag: 'Current Location',
        fullAddress: formattedAddress,
        landmark: landmark,
        latitude: position.latitude,
        longitude: position.longitude,
        isDefault: false,
      );

      state = state.copyWith(
        activeAddress: gpsAddress,
        isLoading: false,
      );
      await _persistToLocal();
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setActiveAddress(AddressModel address) {
    state = state.copyWith(activeAddress: address);
    _persistToLocal();
  }

  Future<void> addAddress(AddressModel address) async {
    // If marked default, unset default on other saved addresses
    List<AddressModel> updatedList = state.savedAddresses.map((a) {
      if (address.isDefault) {
        return a.copyWith(isDefault: false);
      }
      return a;
    }).toList();

    // Check if updating existing id
    final existingIndex = updatedList.indexWhere((a) => a.id == address.id);
    if (existingIndex >= 0) {
      updatedList[existingIndex] = address;
    } else {
      updatedList.insert(0, address);
    }

    state = state.copyWith(
      savedAddresses: updatedList,
      activeAddress: address,
    );
    await _persistToLocal();

    // Sync with backend if user is authenticated
    final user = _ref.read(authProvider).user;
    if (user != null && user.id.isNotEmpty) {
      try {
        final serverAddrId = await ApiClient().saveCustomerAddress(user.id, address);
        if (serverAddrId != null && serverAddrId != address.id) {
          // Update local address id to match database primary key
          final syncedAddr = address.copyWith(id: serverAddrId);
          final syncIndex = state.savedAddresses.indexWhere((a) => a.id == address.id);
          if (syncIndex >= 0) {
            final reUpdated = List<AddressModel>.from(state.savedAddresses);
            reUpdated[syncIndex] = syncedAddr;
            state = state.copyWith(
              savedAddresses: reUpdated,
              activeAddress: syncedAddr,
            );
            await _persistToLocal();
          }
        }
      } catch (e) {
        debugPrint('[LocationNotifier] Failed to sync address to backend: $e');
      }
    }
  }

  Future<void> deleteAddress(String id) async {
    final updatedList = state.savedAddresses.where((a) => a.id != id).toList();

    AddressModel newActive = state.activeAddress;
    if (state.activeAddress.id == id) {
      newActive = updatedList.isNotEmpty ? updatedList.first : _defaultAddress;
    }

    state = state.copyWith(
      savedAddresses: updatedList,
      activeAddress: newActive,
    );
    await _persistToLocal();

    // Sync deletion with backend if user is authenticated
    final user = _ref.read(authProvider).user;
    if (user != null && user.id.isNotEmpty) {
      try {
        await ApiClient().deleteCustomerAddress(user.id, id);
      } catch (e) {
        debugPrint('[LocationNotifier] Failed to delete address from backend: $e');
      }
    }
  }
}
