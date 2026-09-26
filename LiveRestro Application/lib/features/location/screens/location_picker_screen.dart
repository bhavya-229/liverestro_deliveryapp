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
  ll.LatLng _currentMapPosition = const ll.LatLng(22.3039, 70.8022);

  int _selectedTabIndex = 0; // 0 = Saved Addresses, 1 = Add New Address
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

    final locState = ref.read(locationProvider);
    final current = locState.activeAddress;
    _selectedTag = current.tag.isNotEmpty ? current.tag : 'Home';
    _addressController.text = current.fullAddress;
    _landmarkController.text = current.landmark;
    _currentMapPosition = ll.LatLng(current.latitude, current.longitude);

    // If no saved addresses exist yet, open the Add New Address tab directly
    if (locState.savedAddresses.isEmpty) {
      _selectedTabIndex = 1;
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _onConfirmNewLocation() async {
    final fullAddr = _addressController.text.trim();
    if (fullAddr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your delivery address')),
      );
      return;
    }

    final newAddress = AddressModel(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      tag: _selectedTag,
      fullAddress: fullAddr,
      landmark: _landmarkController.text.trim(),
      latitude: _currentMapPosition.latitude,
      longitude: _currentMapPosition.longitude,
      isDefault: true,
    );

    await ref.read(locationProvider.notifier).addAddress(newAddress);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Address saved: ${newAddress.tag}'),
          backgroundColor: AppColors.flameDark,
          duration: const Duration(seconds: 2),
        ),
      );

      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  void _onSelectAddress(AddressModel address) {
    ref.read(locationProvider.notifier).setActiveAddress(address);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Delivering to ${address.tag}: ${address.landmark.isNotEmpty ? address.landmark : address.fullAddress}'),
        backgroundColor: AppColors.flameDark,
        duration: const Duration(seconds: 2),
      ),
    );

    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  void _onDeleteAddress(AddressModel address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: Text('Are you sure you want to delete your saved "${address.tag}" address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(locationProvider.notifier).deleteAddress(address.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Address "${address.tag}" deleted'),
                  backgroundColor: Colors.red.shade700,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final savedAddresses = locationState.savedAddresses;
    final activeAddress = locationState.activeAddress;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
            icon: AppIcons.back,
            color: AppColors.flame,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Delivery Address',
          style: AppTypography.headlineMedium.copyWith(
            color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.flame100,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    index: 0,
                    label: 'Saved Addresses (${savedAddresses.length})',
                    icon: AppIcons.address,
                    isSelected: _selectedTabIndex == 0,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTabButton(
                    index: 1,
                    label: '+ Add New',
                    icon: AppIcons.pin,
                    isSelected: _selectedTabIndex == 1,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _selectedTabIndex == 0
          ? _buildSavedAddressesView(savedAddresses, activeAddress, isDark)
          : _buildAddNewAddressView(isDark),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required List<List<dynamic>> icon,
    required bool isSelected,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.flame : (isDark ? AppColors.darkCard : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? AppColors.flame : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              color: isSelected ? Colors.white : (isDark ? AppColors.darkTxt2 : AppColors.txtSecondary),
              size: 15,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? Colors.white : (isDark ? AppColors.darkTxt2 : AppColors.txtSecondary),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 0: SAVED ADDRESSES VIEW
  // -------------------------------------------------------------
  Widget _buildSavedAddressesView(
    List<AddressModel> savedAddresses,
    AddressModel activeAddress,
    bool isDark,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current GPS quick selection card
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.flame.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.flame.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.flame50,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: HugeIcon(
                    icon: AppIcons.gps,
                    color: AppColors.flame,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deliver to Current Location',
                      style: AppTypography.labelLarge.copyWith(
                        color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      activeAddress.id == 'addr_gps'
                          ? activeAddress.fullAddress
                          : 'Detect live GPS location instantly',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(locationProvider.notifier).detectCurrentGPSLocation();
                  final currentGps = ref.read(locationProvider).activeAddress;
                  _onSelectAddress(currentGps);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.flame,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('Use GPS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // Section Title
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'SAVED ADDRESSES (${savedAddresses.length})',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.flame,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ),

        // If no addresses saved
        if (savedAddresses.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.flame50,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: HugeIcon(
                      icon: AppIcons.address,
                      color: AppColors.flame,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Saved Addresses Yet',
                  style: AppTypography.headlineSmall.copyWith(
                    color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add your Home or Work address for quick 1-tap checkout.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => setState(() => _selectedTabIndex = 1),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New Address Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.flame,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          )
        else
          // Saved addresses cards list
          ...savedAddresses.map((addr) {
            final isActive = activeAddress.id == addr.id ||
                (activeAddress.fullAddress == addr.fullAddress && addr.fullAddress.isNotEmpty);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? AppColors.flame
                      : (isDark ? AppColors.darkBorder : Colors.grey.shade200),
                  width: isActive ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tag Icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _getTagColor(addr.tag).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: HugeIcon(
                            icon: _getTagIcon(addr.tag),
                            color: _getTagColor(addr.tag),
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Tag Name & Active Badge
                      Text(
                        addr.tag,
                        style: AppTypography.labelLarge.copyWith(
                          color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.flame,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      // Delete Action Button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                        tooltip: 'Delete Address',
                        onPressed: () => _onDeleteAddress(addr),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Address text
                  Text(
                    addr.fullAddress,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (addr.landmark.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const HugeIcon(
                          icon: AppIcons.location,
                          color: AppColors.flameMedium,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Landmark: ${addr.landmark}',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTxt2 : AppColors.txtSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Deliver Here CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onSelectAddress(addr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? AppColors.flameDark : AppColors.flame,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        isActive ? '✓ Delivering Here' : 'Deliver to this Address',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

        const SizedBox(height: 16),
        // Bottom CTA to Add New Address
        OutlinedButton.icon(
          onPressed: () => setState(() => _selectedTabIndex = 1),
          icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.flame, size: 20),
          label: const Text(
            '+ Add Another Address',
            style: TextStyle(color: AppColors.flame, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.flame, width: 1.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 1: ADD NEW ADDRESS VIEW (Map + Form)
  // -------------------------------------------------------------
  Widget _buildAddNewAddressView(bool isDark) {
    return Column(
      children: [
        // MAP AREA WITH INTERACTIVE OPENSTREETMAP & ANIMATED PIN
        SizedBox(
          height: 250,
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
                              'Deliver here',
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
                bottom: 12,
                right: 14,
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
                    const SizedBox(height: 6),
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
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('GPS Detected: ${active.landmark.isNotEmpty ? active.landmark : active.fullAddress}'),
                            backgroundColor: AppColors.flameDark,
                            duration: const Duration(milliseconds: 1500),
                          ),
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
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
                            size: 19,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAVE ADDRESS AS',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.flame,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
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
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Complete Address',
                    hintText: 'Flat / House no., Building, Street, Area',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: HugeIcon(
                        icon: AppIcons.address,
                        color: AppColors.flame,
                        size: 18,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkCard : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.flame100),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _landmarkController,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Landmark (Optional)',
                    hintText: 'e.g. Near Kotecha Chowk / Behind Domino\'s',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12),
                      child: HugeIcon(
                        icon: AppIcons.location,
                        color: AppColors.flame,
                        size: 18,
                      ),
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkCard : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.flame100),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                GradientButton(
                  label: 'Save & Deliver Here',
                  leadingIcon: AppIcons.checkCircle,
                  onTap: _onConfirmNewLocation,
                ),
              ],
            ),
          ),
        ),
      ],
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

  List<List<dynamic>> _getTagIcon(String tag) {
    switch (tag.toLowerCase()) {
      case 'home':
        return AppIcons.home;
      case 'work':
        return AppIcons.work;
      default:
        return AppIcons.pin;
    }
  }

  Color _getTagColor(String tag) {
    switch (tag.toLowerCase()) {
      case 'home':
        return AppColors.flame;
      case 'work':
        return Colors.blue.shade700;
      default:
        return Colors.deepPurple;
    }
  }
}
