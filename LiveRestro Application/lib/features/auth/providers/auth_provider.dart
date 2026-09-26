import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
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

  // Use '127.0.0.1' or 'localhost' for Windows/Web.
  // Use '10.0.2.2' for Android Emulator.
  // Use your computer's Wi-Fi IP (e.g., '192.168.29.xxx') for a physical phone.
  static const String _baseUrl = 'http://192.168.29.105:4000/api/v1/auth';

  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phoneNumber}),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          tempPhoneNumber: phoneNumber,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: data['message'] ?? 'Failed to send OTP',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Make sure the backend server is running and the IP address is correct.',
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    if (otp.length < 4) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Invalid OTP. Please enter a valid code.',
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': state.tempPhoneNumber,
          'otp': otp,
        }),
      ).timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: data['message'] ?? 'Invalid OTP code',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Network error. Could not verify OTP.',
      );
      return false;
    }
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
