import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/gradient_button.dart';
import '../providers/auth_provider.dart';

class CountryInfo {
  final String name;
  final String flag;
  final String dialCode;
  final int phoneLength;
  final String hint;

  const CountryInfo({
    required this.name,
    required this.flag,
    required this.dialCode,
    required this.phoneLength,
    required this.hint,
  });
}

const List<CountryInfo> kSupportedCountries = [
  CountryInfo(name: 'India', flag: '🇮🇳', dialCode: '+91', phoneLength: 10, hint: '98765 43210'),
  CountryInfo(name: 'United States', flag: '🇺🇸', dialCode: '+1', phoneLength: 10, hint: '(555) 012-3456'),
  CountryInfo(name: 'United Kingdom', flag: '🇬🇧', dialCode: '+44', phoneLength: 10, hint: '7911 123456'),
  CountryInfo(name: 'United Arab Emirates', flag: '🇦🇪', dialCode: '+971', phoneLength: 9, hint: '50 123 4567'),
  CountryInfo(name: 'Canada', flag: '🇨🇦', dialCode: '+1', phoneLength: 10, hint: '(416) 123-4567'),
  CountryInfo(name: 'Australia', flag: '🇦🇺', dialCode: '+61', phoneLength: 9, hint: '412 345 678'),
  CountryInfo(name: 'Singapore', flag: '🇸🇬', dialCode: '+65', phoneLength: 8, hint: '8123 4567'),
  CountryInfo(name: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966', phoneLength: 9, hint: '50 123 4567'),
  CountryInfo(name: 'Germany', flag: '🇩🇪', dialCode: '+49', phoneLength: 10, hint: '151 12345678'),
  CountryInfo(name: 'France', flag: '🇫🇷', dialCode: '+33', phoneLength: 9, hint: '6 12 34 56 78'),
  CountryInfo(name: 'Qatar', flag: '🇶🇦', dialCode: '+974', phoneLength: 8, hint: '3312 3456'),
  CountryInfo(name: 'Kuwait', flag: '🇰🇼', dialCode: '+965', phoneLength: 8, hint: '5123 4567'),
  CountryInfo(name: 'Oman', flag: '🇴🇲', dialCode: '+968', phoneLength: 8, hint: '9123 4567'),
  CountryInfo(name: 'Bahrain', flag: '🇧🇭', dialCode: '+973', phoneLength: 8, hint: '3612 3456'),
];

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  CountryInfo _selectedCountry = kSupportedCountries[0];
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _otpSent = false;
  int _countdown = 30;
  Timer? _timer;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _countdown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        t.cancel();
      }
    });
  }

  void _onGetOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length != _selectedCountry.phoneLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid ${_selectedCountry.phoneLength}-digit mobile number for ${_selectedCountry.name}'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final fullNumber = '${_selectedCountry.dialCode}$phone';
    await ref.read(authProvider.notifier).sendOtp(fullNumber);
    if (!mounted) return;
    setState(() => _otpSent = true);
    _startTimer();
    _otpFocusNodes[0].requestFocus();
  }

  void _onVerifyOtp() async {
    final otp = _otpControllers.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full OTP')),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyOtp(otp);
    if (!mounted) return;

    if (success) {
      final user = ref.read(authProvider).user;
      if (user != null && user.name.isNotEmpty) {
        context.go('/home');
      } else {
        context.go('/profile-setup');
      }
    } else {
      final error = ref.read(authProvider).errorMessage ?? 'Invalid OTP code';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.nonVeg),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          // HERO HEADER (gradient)
          Container(
            height: 180,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 44, 16, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_white.png',
                  height: 38,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                Text(
                  'Order fresh food straight from kitchen POS',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.90),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // CONTENT
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !_otpSent ? _buildPhoneInput(authState) : _buildOtpInput(authState),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInput(AuthState authState) {
    return Column(
      key: const ValueKey('phone_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        // FIELD LABEL ROW
        Row(
          children: [
            const HugeIcon(
              icon: AppIcons.phone,
              color: AppColors.flame,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Mobile number',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.flame,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // MOBILE INPUT ROW
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppSpacing.inputRadius,
            border: Border.all(color: AppColors.flame100, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              InkWell(
                onTap: _showCountryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: AppColors.flame50,
                  height: double.infinity,
                  child: Row(
                    children: [
                      Text(_selectedCountry.flag, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 4),
                      Text(
                        _selectedCountry.dialCode,
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.flame,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.arrow_drop_down_rounded, color: AppColors.flame, size: 20),
                    ],
                  ),
                ),
              ),
              Container(width: 1, color: AppColors.flame100),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: _selectedCountry.phoneLength,
                  style: AppTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: _selectedCountry.hint,
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    fillColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // CTA BUTTON
        GradientButton(
          label: 'Get OTP',
          trailingIcon: AppIcons.forward,
          isLoading: authState.isLoading,
          onTap: _onGetOtp,
        ),

        const SizedBox(height: 28),

        // TRUST CARD
        _buildTrustCard(),
      ],
    );
  }

  Widget _buildOtpInput(AuthState authState) {
    return Column(
      key: const ValueKey('otp_step'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            const HugeIcon(
              icon: AppIcons.lockKey,
              color: AppColors.flame,
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'Enter OTP sent to ${_selectedCountry.dialCode} ${_phoneController.text}',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.flame,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                setState(() => _otpSent = false);
              },
              child: Text(
                'Edit',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.txtMuted,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 6 OTP BOXES
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 44,
              height: 48,
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: AppTypography.headlineLarge.copyWith(
                  color: AppColors.flame,
                  fontWeight: FontWeight.w800,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: '',
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.flame100, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.flame, width: 2),
                  ),
                ),
                onChanged: (val) {
                  if (val.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  } else if (val.isEmpty && index > 0) {
                    _otpFocusNodes[index - 1].requestFocus();
                  }
                  if (index == 5 && val.isNotEmpty) {
                    _onVerifyOtp();
                  }
                },
              ),
            );
          }),
        ),

        const SizedBox(height: 14),

        // RESEND TIMER ROW
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(
                icon: AppIcons.clock,
                color: AppColors.flameMedium,
                size: 13,
              ),
              const SizedBox(width: 5),
              _countdown > 0
                  ? Text(
                      'Resend OTP in 0:${_countdown.toString().padLeft(2, '0')}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.flameMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : GestureDetector(
                      onTap: _onGetOtp,
                      child: Text(
                        'Resend OTP Now',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.flame,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // CTA BUTTON
        GradientButton(
          label: 'Verify & Continue',
          leadingIcon: AppIcons.checkCircle,
          isLoading: authState.isLoading,
          onTap: _onVerifyOtp,
        ),

        const SizedBox(height: 28),

        // TRUST CARD
        _buildTrustCard(),
      ],
    );
  }

  Widget _buildTrustCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.flame50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.flame100, width: 1),
      ),
      child: Row(
        children: [
          const HugeIcon(
            icon: AppIcons.secure,
            color: AppColors.flame,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Zero hidden commissions — sent directly to kitchen POS',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.flameDark,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _CountryPickerSheet(
          selectedCountry: _selectedCountry,
          onSelect: (country) {
            setState(() {
              _selectedCountry = country;
              _phoneController.clear();
            });
            Navigator.of(ctx).pop();
          },
        );
      },
    );
  }
}

class _CountryPickerSheet extends StatefulWidget {
  final CountryInfo selectedCountry;
  final ValueChanged<CountryInfo> onSelect;

  const _CountryPickerSheet({
    required this.selectedCountry,
    required this.onSelect,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<CountryInfo> _filteredCountries = kSupportedCountries;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = kSupportedCountries;
      } else {
        _filteredCountries = kSupportedCountries.where((c) {
          return c.name.toLowerCase().contains(query) ||
              c.dialCode.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.flame100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Select Country',
                  style: AppTypography.headlineMedium.copyWith(
                    color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBg : AppColors.flame50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.flame100),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 20, color: AppColors.flame),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search country or code...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppTypography.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.flame50),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredCountries.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.flame50,
              ),
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = country.dialCode == widget.selectedCountry.dialCode &&
                    country.name == widget.selectedCountry.name;

                return ListTile(
                  onTap: () => widget.onSelect(country),
                  leading: Text(
                    country.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    country.name,
                    style: AppTypography.labelMedium.copyWith(
                      color: isDark ? AppColors.darkTxt : AppColors.txtPrimary,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    '${country.phoneLength} digits (e.g. ${country.hint})',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.dialCode,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.flame,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: AppColors.flame, size: 18),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
