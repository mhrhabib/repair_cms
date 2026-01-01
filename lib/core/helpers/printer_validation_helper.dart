import 'dart:io';
import 'package:flutter/foundation.dart';

/// Helper class for printer validation before printing
class PrinterValidationHelper {
  /// Validate printer configuration before attempting to print
  static Future<ValidationResult> validatePrinterConfig({
    required String ipAddress,
    required int port,
    String? printerModel,
    String? labelSize,
  }) async {
    // Check IP address format
    if (ipAddress.isEmpty) {
      return ValidationResult(isValid: false, message: 'IP address is required');
    }

    // Basic IP format validation
    final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
    if (!ipRegex.hasMatch(ipAddress)) {
      return ValidationResult(isValid: false, message: 'Invalid IP address format. Expected format: 192.168.0.1');
    }

    // Check port range
    if (port < 1 || port > 65535) {
      return ValidationResult(isValid: false, message: 'Invalid port number. Must be between 1 and 65535');
    }

    // Test network connectivity
    try {
      debugPrint('🔍 [Validation] Testing connection to $ipAddress:$port');
      final socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 5));
      socket.destroy();
      debugPrint('✅ [Validation] Connection test passed');

      return ValidationResult(isValid: true, message: 'Printer configuration is valid');
    } catch (e) {
      debugPrint('❌ [Validation] Connection test failed: $e');
      String errorMsg = 'Connection test failed: ';
      if (e.toString().contains('timeout')) {
        errorMsg += 'Timeout - check if printer is on and IP is correct';
      } else if (e.toString().contains('refused')) {
        errorMsg += 'Connection refused - check port number and firewall settings';
      } else if (e.toString().contains('unreachable') || e.toString().contains('Network')) {
        errorMsg += 'Network unreachable - check network connection';
      } else {
        errorMsg += 'Unable to reach printer. Check printer power, IP, and network';
      }

      return ValidationResult(isValid: false, message: errorMsg);
    }
  }

  /// Quick connection check without detailed validation
  static Future<bool> isReachable(String ipAddress, int port) async {
    try {
      final socket = await Socket.connect(ipAddress, port, timeout: const Duration(seconds: 4));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Validate label size is appropriate for Brother printers
  static bool isValidBrotherLabelSize(String? labelSize) {
    if (labelSize == null) return false;

    final validSizes = [
      'W17H54',
      'W17H87',
      'W23H23',
      'W29H42',
      'W29H90',
      'W38H90',
      'W39H48',
      'W52H29',
      'W62H29',
      'W62H100',
      'W12',
      'W29',
      'W38',
      'W50',
      'W54',
      'W62',
      'W60H86',
      'W54H29',
      'W62',
    ];

    return validSizes.any((size) => labelSize.contains(size));
  }
}

/// Result of printer validation
class ValidationResult {
  final bool isValid;
  final String message;
  final String? suggestion;

  ValidationResult({required this.isValid, required this.message, this.suggestion});
}
