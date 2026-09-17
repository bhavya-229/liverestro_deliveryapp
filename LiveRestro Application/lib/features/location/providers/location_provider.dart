import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/address_model.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

class LocationState {
  final AddressModel activeAddress;
  final List<AddressModel> savedAddresses;
  final bool isLoading;

  const LocationState({
    required this.activeAddress,
    required this.savedAddresses,
    this.isLoading = false,
  });

  LocationState copyWith({
    AddressModel? activeAddress,
    List<AddressModel>? savedAddresses,
    bool? isLoading,
  }) {
    return LocationState(
      activeAddress: activeAddress ?? this.activeAddress,
      savedAddresses: savedAddresses ?? this.savedAddresses,
      isLoading: isLoading ?? this.isLoading,
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
        );

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
