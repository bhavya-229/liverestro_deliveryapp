import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
<<<<<<< HEAD
import '../../../core/network/api_client.dart';
=======
import 'package:http/http.dart' as http;
>>>>>>> 14d50d1c8d97e63fa9d7ed96cd1638951a0a7423
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

<<<<<<< HEAD
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
=======
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
>>>>>>> 14d50d1c8d97e63fa9d7ed96cd1638951a0a7423
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
