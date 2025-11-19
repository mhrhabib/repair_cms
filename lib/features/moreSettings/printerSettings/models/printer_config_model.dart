class PrinterConfigModel {
  final String printerType; // 'thermal', 'label', 'a4'
  final String printerBrand; // 'Brother', 'Epson', 'Star', 'Xprinter', 'Dymo', 'Generic'
  final String? printerModel;
  final String ipAddress;
  final String protocol; // 'TCP', 'USB'
  final bool isDefault;
  final int? port; // Optional port number
  final String? usbDeviceId; // For USB printers

  PrinterConfigModel({
    required this.printerType,
    required this.printerBrand,
    this.printerModel,
    required this.ipAddress,
    required this.protocol,
    this.isDefault = false,
    this.port,
    this.usbDeviceId,
  });

  factory PrinterConfigModel.fromJson(Map<String, dynamic> json) {
    return PrinterConfigModel(
      printerType: json['printerType'] ?? '',
      printerBrand: json['printerBrand'] ?? '',
      printerModel: json['printerModel'],
      ipAddress: json['ipAddress'] ?? '',
      protocol: json['protocol'] ?? 'TCP',
      isDefault: json['isDefault'] ?? false,
      port: json['port'],
      usbDeviceId: json['usbDeviceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'printerType': printerType,
      'printerBrand': printerBrand,
      'printerModel': printerModel,
      'ipAddress': ipAddress,
      'protocol': protocol,
      'isDefault': isDefault,
      'port': port,
      'usbDeviceId': usbDeviceId,
    };
  }

  PrinterConfigModel copyWith({
    String? printerType,
    String? printerBrand,
    String? printerModel,
    String? ipAddress,
    String? protocol,
    bool? isDefault,
    int? port,
    String? usbDeviceId,
  }) {
    return PrinterConfigModel(
      printerType: printerType ?? this.printerType,
      printerBrand: printerBrand ?? this.printerBrand,
      printerModel: printerModel ?? this.printerModel,
      ipAddress: ipAddress ?? this.ipAddress,
      protocol: protocol ?? this.protocol,
      isDefault: isDefault ?? this.isDefault,
      port: port ?? this.port,
      usbDeviceId: usbDeviceId ?? this.usbDeviceId,
    );
  }
}
