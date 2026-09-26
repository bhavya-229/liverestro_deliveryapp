import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
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

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.tempPhoneNumber,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserProfile? user,
    String? tempPhoneNumber,
    String? errorMessage,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      tempPhoneNumber: tempPhoneNumber ?? this.tempPhoneNumber,
      errorMessage: errorMessage,
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

    state = state.copyWith(isLoading: false);
    return true;
  }

  Future<void> completeRegistration({
    required String name,
    String? email,
    required bool isVegOnly,
    String? couponCode,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 600));

    final newUser = UserProfile(
      id: const Uuid().v4(),
      name: name,
      phoneNumber: state.tempPhoneNumber ?? '9876543210',
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
    );
  }

  Future<void> toggleVegPreference(bool isVegOnly) async {
    if (state.user != null) {
      final updated = state.user!.copyWith(isVegOnly: isVegOnly);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(updated.toJson()));
      state = state.copyWith(user: updated);
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
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    state = const AuthState();
  }
}
