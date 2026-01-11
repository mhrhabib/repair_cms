import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

/// Service for managing label content settings
/// Stores user preferences for which fields to show on device labels
class LabelContentSettingsService {
  static final LabelContentSettingsService _instance = LabelContentSettingsService._internal();
  factory LabelContentSettingsService() => _instance;
  LabelContentSettingsService._internal();

  final _storage = GetStorage();
  static const String _storageKey = 'label_content_settings';

  /// Get current label content settings
  LabelContentSettings getSettings() {
    debugPrint('🏷️ [LabelContentService] Loading label content settings');
    try {
      final data = _storage.read(_storageKey);
      if (data != null && data is Map<String, dynamic>) {
        return LabelContentSettings.fromJson(data);
      }
    } catch (e) {
      debugPrint('❌ [LabelContentService] Error loading settings: $e');
    }

    // Return default settings if none saved
    debugPrint('🏷️ [LabelContentService] Using default settings');
    return LabelContentSettings.defaults();
  }

  /// Save label content settings
  Future<void> saveSettings(LabelContentSettings settings) async {
    debugPrint('🏷️ [LabelContentService] Saving label content settings');
    try {
      await _storage.write(_storageKey, settings.toJson());
      debugPrint('✅ [LabelContentService] Settings saved successfully');
    } catch (e) {
      debugPrint('❌ [LabelContentService] Error saving settings: $e');
      rethrow;
    }
  }

  /// Reset to default settings
  Future<void> resetToDefaults() async {
    debugPrint('🏷️ [LabelContentService] Resetting to default settings');
    await saveSettings(LabelContentSettings.defaults());
  }
}

/// Model class for label content settings
class LabelContentSettings {
  final bool showTrackingPortalQR;
  final bool showJobQR;
  final bool showBarcode;
  final bool showJobNo;
  final bool showCustomerName;
  final bool showModelBrand;
  final bool showDate;
  final bool showJobType;
  final bool showSymptom;
  final bool showPhysicalLocation;

  LabelContentSettings({
    required this.showTrackingPortalQR,
    required this.showJobQR,
    required this.showBarcode,
    required this.showJobNo,
    required this.showCustomerName,
    required this.showModelBrand,
    required this.showDate,
    required this.showJobType,
    required this.showSymptom,
    required this.showPhysicalLocation,
  });

  /// Default settings (most fields enabled)
  factory LabelContentSettings.defaults() {
    return LabelContentSettings(
      showTrackingPortalQR: false,
      showJobQR: true,
      showBarcode: true,
      showJobNo: true,
      showCustomerName: true,
      showModelBrand: true,
      showDate: true,
      showJobType: true,
      showSymptom: true,
      showPhysicalLocation: true,
    );
  }

  /// Create from JSON
  factory LabelContentSettings.fromJson(Map<String, dynamic> json) {
    return LabelContentSettings(
      showTrackingPortalQR: json['showTrackingPortalQR'] as bool? ?? false,
      showJobQR: json['showJobQR'] as bool? ?? true,
      showBarcode: json['showBarcode'] as bool? ?? true,
      showJobNo: json['showJobNo'] as bool? ?? true,
      showCustomerName: json['showCustomerName'] as bool? ?? true,
      showModelBrand: json['showModelBrand'] as bool? ?? true,
      showDate: json['showDate'] as bool? ?? true,
      showJobType: json['showJobType'] as bool? ?? true,
      showSymptom: json['showSymptom'] as bool? ?? true,
      showPhysicalLocation: json['showPhysicalLocation'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'showTrackingPortalQR': showTrackingPortalQR,
      'showJobQR': showJobQR,
      'showBarcode': showBarcode,
      'showJobNo': showJobNo,
      'showCustomerName': showCustomerName,
      'showModelBrand': showModelBrand,
      'showDate': showDate,
      'showJobType': showJobType,
      'showSymptom': showSymptom,
      'showPhysicalLocation': showPhysicalLocation,
    };
  }

  /// Copy with method for easy updates
  LabelContentSettings copyWith({
    bool? showTrackingPortalQR,
    bool? showJobQR,
    bool? showBarcode,
    bool? showJobNo,
    bool? showCustomerName,
    bool? showModelBrand,
    bool? showDate,
    bool? showJobType,
    bool? showSymptom,
    bool? showPhysicalLocation,
  }) {
    return LabelContentSettings(
      showTrackingPortalQR: showTrackingPortalQR ?? this.showTrackingPortalQR,
      showJobQR: showJobQR ?? this.showJobQR,
      showBarcode: showBarcode ?? this.showBarcode,
      showJobNo: showJobNo ?? this.showJobNo,
      showCustomerName: showCustomerName ?? this.showCustomerName,
      showModelBrand: showModelBrand ?? this.showModelBrand,
      showDate: showDate ?? this.showDate,
      showJobType: showJobType ?? this.showJobType,
      showSymptom: showSymptom ?? this.showSymptom,
      showPhysicalLocation: showPhysicalLocation ?? this.showPhysicalLocation,
    );
  }
}
