import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricStorageService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Android options for biometric storage
  static const AndroidOptions _androidOptions = AndroidOptions(encryptedSharedPreferences: true);

  // iOS options for biometric storage
  static const IOSOptions _iosOptions = IOSOptions(accessibility: KeychainAccessibility.passcode);

  // Save credentials securely for biometric authentication
  static Future<void> saveBiometricCredentials({required String email, required String password}) async {
    try {
      // Save email in secure storage
      await _secureStorage.write(
        key: 'biometric_email',
        value: email,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      // Save password in secure storage
      await _secureStorage.write(
        key: 'biometric_password',
        value: password,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      debugPrint('Biometric credentials saved successfully for: $email');
    } catch (e) {
      debugPrint('Error saving biometric credentials: $e');
      throw Exception('Failed to save biometric credentials');
    }
  }

  // Get saved biometric credentials
  static Future<Map<String, String?>> getBiometricCredentials() async {
    try {
      final email = await _secureStorage.read(key: 'biometric_email', aOptions: _androidOptions, iOptions: _iosOptions);
      final password = await _secureStorage.read(
        key: 'biometric_password',
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      return {'email': email, 'password': password};
    } catch (e) {
      debugPrint('Error reading biometric credentials: $e');
      return {'email': null, 'password': null};
    }
  }

  // Check if biometric is enabled (we consider it enabled if credentials exist)
  static Future<bool> isBiometricEnabled() async {
    return await hasBiometricCredentials();
  }

  // Check if we have valid biometric credentials
  static Future<bool> hasBiometricCredentials() async {
    final credentials = await getBiometricCredentials();
    return credentials['email'] != null &&
        credentials['email']!.isNotEmpty &&
        credentials['password'] != null &&
        credentials['password']!.isNotEmpty;
  }

  // Disable biometric authentication and clear credentials
  static Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: 'biometric_email', aOptions: _androidOptions, iOptions: _iosOptions);
      await _secureStorage.delete(key: 'biometric_password', aOptions: _androidOptions, iOptions: _iosOptions);

      debugPrint('Biometric authentication disabled');
    } catch (e) {
      debugPrint('Error disabling biometric: $e');
    }
  }

  // Clear all biometric data
  static Future<void> clearBiometricData() async {
    try {
      await _secureStorage.deleteAll(aOptions: _androidOptions, iOptions: _iosOptions);
    } catch (e) {
      debugPrint('Error clearing biometric data: $e');
    }
  }
}
