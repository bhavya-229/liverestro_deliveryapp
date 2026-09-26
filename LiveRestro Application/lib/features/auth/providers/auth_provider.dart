import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../../core/network/api_client.dart';
import '../models/user_profile.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserProfile? user;
  final String? tempPhoneNumber;
  final String? errorMessage;
  final bool isExistingUser;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.tempPhoneNumber,
    this.errorMessage,
    this.isExistingUser = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserProfile? user,
    String? tempPhoneNumber,
    String? errorMessage,
    bool? isExistingUser,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      tempPhoneNumber: tempPhoneNumber ?? this.tempPhoneNumber,
      errorMessage: errorMessage,
      isExistingUser: isExistingUser ?? this.isExistingUser,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadUser();
  }

  static const String _userKey = 'live_restro_user_data';

  Future<void> _loadUser() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null) {
      try {
        final data = jsonDecode(jsonStr);
        final user = UserProfile.fromJson(data);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
          isExistingUser: true,
        );
        return;
      } catch (_) {}
    }
    state = state.copyWith(isLoading: false);
  }

  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(
      isLoading: false,
      tempPhoneNumber: phoneNumber,
    );
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 700));
    if (otp.length < 4) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid OTP. Please enter a valid code.',
      );
      return false;
    }

    final phone = state.tempPhoneNumber ?? '9876543210';
    
    // Check with Backend MySQL Database
    try {
      final backendCustomer = await ApiClient().authenticateCustomer(phoneNumber: phone);
      if (backendCustomer != null) {
        final fullName = backendCustomer['full_name'] as String?;
        final custId = backendCustomer['id']?.toString() ?? const Uuid().v4();
        
        // If user already has a saved name in MySQL, restore their full session!
        if (fullName != null && fullName.trim().isNotEmpty && fullName != 'Customer') {
          final existingProfile = UserProfile(
            id: custId,
            name: fullName,
            phoneNumber: phone,
            email: backendCustomer['email'] as String?,
            isVegOnly: backendCustomer['is_veg_only'] == 1 || backendCustomer['is_veg_only'] == true,
            createdAt: DateTime.now(),
          );

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userKey, jsonEncode(existingProfile.toJson()));

          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: existingProfile,
            isExistingUser: true,
          );
          return true;
        }
      }
    } catch (e) {
      // Offline fallback
    }

    state = state.copyWith(
      isLoading: false,
      isExistingUser: false,
    );
    return true;
  }

  Future<void> completeRegistration({
    required String name,
    String? email,
    required bool isVegOnly,
    String? couponCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final phone = state.tempPhoneNumber ?? '9876543210';

    // Persist to MySQL Backend
    String assignedId = const Uuid().v4();
    try {
      final backendCustomer = await ApiClient().authenticateCustomer(
        phoneNumber: phone,
        name: name,
        email: email,
        isVegOnly: isVegOnly,
      );
      if (backendCustomer != null && backendCustomer['id'] != null) {
        assignedId = backendCustomer['id'].toString();
      }
    } catch (_) {}

    final newUser = UserProfile(
      id: assignedId,
      name: name,
      phoneNumber: phone,
      email: email?.trim().isEmpty ?? true ? null : email!.trim(),
      isVegOnly: isVegOnly,
      appliedCouponCode: couponCode?.trim().toUpperCase(),
      createdAt: DateTime.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(newUser.toJson()));

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: true,
      user: newUser,
      isExistingUser: true,
    );
  }

  Future<void> toggleVegPreference(bool isVegOnly) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(isVegOnly: isVegOnly);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updated.toJson()));
      state = state.copyWith(user: updated);

      // Sync to backend DB
      ApiClient().authenticateCustomer(
        phoneNumber: updated.phoneNumber,
        isVegOnly: isVegOnly,
      );
    }
  }

  Future<void> updateProfile({required String name, String? email}) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(
        name: name,
        email: (email != null && email.trim().isNotEmpty) ? email.trim() : null,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updated.toJson()));
      state = state.copyWith(user: updated);

      // Sync to backend DB
      ApiClient().authenticateCustomer(
        phoneNumber: updated.phoneNumber,
        name: name,
        email: email,
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    state = const AuthState();
  }
}
