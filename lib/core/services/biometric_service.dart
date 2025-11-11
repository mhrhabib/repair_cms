import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  Future<bool> checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      debugPrint(
        'canCheckBiometrics: $canCheck, isDeviceSupported: $isSupported',
      );
      return canCheck && isSupported;
    } catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      debugPrint('Available biometrics: $biometrics');
      return biometrics;
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  Future<bool> authenticate({String? reason}) async {
    try {
      debugPrint('🔐 Starting biometric authentication...');

      // Check if biometric is available
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      debugPrint(
        '📱 Device check - available: $isAvailable, supported: $isDeviceSupported',
      );

      if (!isAvailable || !isDeviceSupported) {
        debugPrint('❌ Biometric not available on this device');
        return false;
      }

      // Get available biometrics
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      debugPrint('👆 Available biometrics: $availableBiometrics');

      if (availableBiometrics.isEmpty) {
        debugPrint('❌ No biometrics enrolled on device');
        return false;
      }

      debugPrint('🚀 Triggering authentication prompt...');

      // This should show the system biometric prompt
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ?? 'Scan your fingerprint or face to continue',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      debugPrint('✅ Authentication result: $didAuthenticate');
      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('❌ PlatformException: ${e.code} - ${e.message}');

      // Handle specific error codes
      if (e.code == 'NotAvailable') {
        debugPrint('Biometric authentication not available');
      } else if (e.code == 'NotEnrolled') {
        debugPrint('No biometrics enrolled');
      } else if (e.code == 'LockedOut') {
        debugPrint('Too many failed attempts - locked out');
      } else if (e.code == 'PermanentlyLockedOut') {
        debugPrint('Permanently locked out');
      }

      return false;
    } catch (e) {
      debugPrint('❌ Unknown error during authentication: $e');
      return false;
    }
  }

  String getBiometricTypeName(List<BiometricType> availableBiometrics) {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (availableBiometrics.contains(BiometricType.strong)) {
      return 'Biometric';
    } else if (availableBiometrics.contains(BiometricType.weak)) {
      return 'Biometric';
    } else {
      return 'Biometric';
    }
  }
}
