/// Printer configuration model for storing printer settings
class PrinterConfigModel {
  final String printerType; // 'thermal', 'label', 'a4'
  final String? printerModel;
  final String? ipAddress;
  final String? protocol;
  final bool isDefault;
  final DateTime? lastUpdated;

  PrinterConfigModel({
    required this.printerType,
    this.printerModel,
    this.ipAddress,
    this.protocol,
    this.isDefault = false,
    this.lastUpdated,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'printerType': printerType,
      'printerModel': printerModel,
      'ipAddress': ipAddress,
      'protocol': protocol,
      'isDefault': isDefault,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  // Create from JSON
  factory PrinterConfigModel.fromJson(Map<String, dynamic> json) {
    return PrinterConfigModel(
      printerType: json['printerType'] as String,
      printerModel: json['printerModel'] as String?,
      ipAddress: json['ipAddress'] as String?,
      protocol: json['protocol'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      lastUpdated: json['lastUpdated'] != null ? DateTime.parse(json['lastUpdated'] as String) : null,
    );
  }

  // Copy with method for updating fields
  PrinterConfigModel copyWith({
    String? printerType,
    String? printerModel,
    String? ipAddress,
    String? protocol,
    bool? isDefault,
    DateTime? lastUpdated,
  }) {
    return PrinterConfigModel(
      printerType: printerType ?? this.printerType,
      printerModel: printerModel ?? this.printerModel,
      ipAddress: ipAddress ?? this.ipAddress,
      protocol: protocol ?? this.protocol,
      isDefault: isDefault ?? this.isDefault,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isConfigured => ipAddress != null && ipAddress!.isNotEmpty && printerModel != null;
}
