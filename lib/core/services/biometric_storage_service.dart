import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:io' show Platform;

class BiometricStorageService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();

  // Android options for biometric storage
  static const AndroidOptions _androidOptions = AndroidOptions(encryptedSharedPreferences: true);

  // iOS options for biometric storage - using unlocked accessibility for better compatibility
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.unlocked,
    synchronizable: false,
  );

  // Get platform-specific biometric type
  static Future<String> getBiometricType() async {
    try {
      // Platform-specific defaults
      if (Platform.isIOS) {
        // For iOS, most modern devices have Face ID
        return 'Face ID';
      } else if (Platform.isAndroid) {
        // For Android, check available biometrics
        final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
        final bool canAuthenticate = await _localAuth.isDeviceSupported();

        if (!canAuthenticate || !canAuthenticateWithBiometrics) {
          return 'Biometric';
        }

        final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

        if (availableBiometrics.contains(BiometricType.face)) {
          return 'Face ID';
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          return 'Fingerprint';
        } else if (availableBiometrics.contains(BiometricType.iris)) {
          return 'Iris';
        } else {
          return 'Biometric';
        }
      } else {
        // For other platforms, use generic biometric check
        final bool canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
        final bool canAuthenticate = await _localAuth.isDeviceSupported();

        if (!canAuthenticate || !canAuthenticateWithBiometrics) {
          return 'Biometric';
        }

        final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

        if (availableBiometrics.contains(BiometricType.face)) {
          return 'Face ID';
        } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
          return 'Fingerprint';
        } else if (availableBiometrics.contains(BiometricType.iris)) {
          return 'Iris';
        } else {
          return 'Biometric';
        }
      }
    } catch (e) {
      debugPrint('Error getting biometric type: $e');
      // Platform-specific fallbacks
      if (Platform.isIOS) {
        return 'Face ID';
      } else {
        return 'Biometric';
      }
    }
  }

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
