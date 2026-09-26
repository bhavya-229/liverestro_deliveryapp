import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../models/address_model.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
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
  LocationNotifier()
      : super(
          const LocationState(
            activeAddress: AddressModel(
              id: 'addr_1',
              tag: 'Home',
              fullAddress: 'A-402, Shivam Heights, University Road, Rajkot, Gujarat',
              landmark: 'Near Kotecha Chowk',
              latitude: 22.3039,
              longitude: 70.8022,
              isDefault: true,
            ),
            savedAddresses: [
              AddressModel(
                id: 'addr_1',
                tag: 'Home',
                fullAddress: 'A-402, Shivam Heights, University Road, Rajkot, Gujarat',
                landmark: 'Near Kotecha Chowk',
                latitude: 22.3039,
                longitude: 70.8022,
                isDefault: true,
              ),
              AddressModel(
                id: 'addr_2',
                tag: 'Work',
                fullAddress: 'Tech Hub POS Labs, 3rd Floor, Kalawad Road, Rajkot',
                landmark: 'Opposite Cosmoplex Cinema',
                latitude: 22.2856,
                longitude: 70.7725,
              ),
            ],
          ),
        ) {
    detectCurrentGPSLocation();
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
        // On Realme / ColorOS / Xiaomi, prompt to open location settings if GPS switch is off
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
        isDefault: true,
      );

      state = state.copyWith(
        activeAddress: gpsAddress,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void setActiveAddress(AddressModel address) {
    state = state.copyWith(activeAddress: address);
  }

  void addAddress(AddressModel address) {
    state = state.copyWith(
      savedAddresses: [...state.savedAddresses, address],
      activeAddress: address,
    );
  }
}
