import 'package:device_info_plus/device_info_plus.dart';
import 'package:quickpass/api/client.dart';
import 'package:quickpass/features/auth/data/models/user_model.dart';
import 'package:quickpass/utils/encryption.dart';

class AuthRepository {
  final ApiClient _client = ApiClient();

  // Request OTP for the given phone number
  Future<void> requestOtp(String phone) async {
    try {
      await _client.post(
        '/auth/request-otp',
        {'phone': phone},
      );
    } catch (e) {
      throw Exception('Failed to request OTP: $e');
    }
  }

  // Verify OTP and authenticate user
  Future<UserModel> verifyOtp(String phone, String otp) async {
    try {
      // Get device ID for one-device login enforcement
      final deviceInfo = DeviceInfoPlugin();
      final deviceId = (await deviceInfo.androidInfo).id; // Adjust for iOS if needed

      final response = await _client.post(
        '/auth/verify-otp',
        {
          'phone': phone,
          'otp': otp,
          'deviceId': EncryptionUtil.encrypt(deviceId), // Encrypt device ID
        },
      );

      return UserModel.fromJson(response);
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // Logout user and invalidate session
  Future<void> logout(String token) async {
    try {
      await _client.post(
        '/auth/logout',
        {},
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    // In production, check secure storage for token
    return false; // Placeholder
  }
}