import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';
import '../models/address_model.dart';
import '../providers/location_provider.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pinController;
  late Animation<double> _pinTranslate;

  final MapController _mapController = MapController();
  ll.LatLng _currentMapPosition = const ll.LatLng(21.1702, 72.8311);

  String _selectedTag = 'Home';
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pinTranslate = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(parent: _pinController, curve: Curves.easeInOut),
    );

    final current = ref.read(locationProvider).activeAddress;
    _selectedTag = current.tag;
    _addressController.text = current.fullAddress;
    _landmarkController.text = current.landmark;
  }

  @override
  void dispose() {
    _pinController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _onConfirmLocation() {
    final fullAddr = _addressController.text.trim();
    if (fullAddr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your delivery address')),
      );
      return;
    }

    final updated = AddressModel(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      tag: _selectedTag,
      fullAddress: fullAddr,
      landmark: _landmarkController.text.trim(),
      latitude: _currentMapPosition.latitude,
      longitude: _currentMapPosition.longitude,
      isDefault: true,
    );

    ref.read(locationProvider.notifier).setActiveAddress(updated);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          // MAP AREA WITH INTERACTIVE GOOGLE MAP & ANIMATED PIN
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              children: [
                // Interactive OpenStreetMap via FlutterMap
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentMapPosition,
                      initialZoom: 15.0,
                      onPositionChanged: (camera, hasGesture) {
                        if (hasGesture) {
                          _currentMapPosition = camera.center;
                          if (!_pinController.isAnimating) {
                            _pinController.repeat(reverse: true);
                          }
                        }
                      },
                      onMapEvent: (event) {
                        if (event is MapEventMoveEnd) {
                          _pinController.stop();
                          _pinController.value = 0.0;
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.liverestro.app.liverestro',
                        maxZoom: 19,
                      ),
                    ],
                  ),
                ),

                // Top Back Button
                Positioned(
                  top: 44,
                  left: 16,
                  child: GestureDetector(
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.flame100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: HugeIcon(
                          icon: AppIcons.back,
                          color: AppColors.flame,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                // CENTER PIN (Animated translateY bounce)
                Center(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _pinTranslate,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _pinTranslate.value - 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.flameDark,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.flameDark.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Order delivered here',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const HugeIcon(
                              icon: AppIcons.pin,
                              color: AppColors.flame,
                              size: 38,
                            ),
                            Container(
                              width: 8,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.flameDark.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ZOOM & GPS CONTROLS (bottom-right)
                Positioned(
                  bottom: 14,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zoom In
                      GestureDetector(
                        onTap: () {
                          _mapController.move(_currentMapPosition, _mapController.camera.zoom + 1);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.flame100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.add, size: 18, color: AppColors.flame),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Zoom Out
                      GestureDetector(
                        onTap: () {
                          _mapController.move(_currentMapPosition, _mapController.camera.zoom - 1);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.flame100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.remove, size: 18, color: AppColors.flame),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Current Location GPS Button
                      GestureDetector(
                        onTap: () async {
                          await ref.read(locationProvider.notifier).detectCurrentGPSLocation();
                          final active = ref.read(locationProvider).activeAddress;
                          final target = ll.LatLng(active.latitude, active.longitude);
                          _currentMapPosition = target;
                          _mapController.move(target, 16.0);
                          _addressController.text = active.fullAddress;
                          _landmarkController.text = active.landmark;
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('GPS Detected: ${active.landmark.isNotEmpty ? active.landmark : active.fullAddress}'),
                                backgroundColor: AppColors.flameDark,
                                duration: const Duration(milliseconds: 1500),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.flame100, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: HugeIcon(
                              icon: AppIcons.gps,
                              color: AppColors.flame,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ADDRESS INPUT DETAILS
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Save Address As',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.flame,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ADDRESS TYPE PILLS
                  Row(
                    children: [
                      _buildTagPill('Home', AppIcons.home),
                      const SizedBox(width: 8),
                      _buildTagPill('Work', AppIcons.work),
                      const SizedBox(width: 8),
                      _buildTagPill('Other', AppIcons.pin),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Flat/House no., Street, Area',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12),
                        child: HugeIcon(
                          icon: AppIcons.address,
                          color: AppColors.flame,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _landmarkController,
                    style: AppTypography.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Landmark (e.g. Near ISRO circle)',
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(12),
                        child: HugeIcon(
                          icon: AppIcons.location,
                          color: AppColors.flame,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  GradientButton(
                    label: 'Confirm & Deliver Here',
                    leadingIcon: AppIcons.checkCircle,
                    onTap: _onConfirmLocation,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagPill(String tag, List<List<dynamic>> icon) {
    final isSelected = _selectedTag == tag;

    return GestureDetector(
      onTap: () => setState(() => _selectedTag = tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.flame : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.flame : AppColors.flame100,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: icon,
              color: isSelected ? Colors.white : AppColors.flameMedium,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              tag,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.flameMedium,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
