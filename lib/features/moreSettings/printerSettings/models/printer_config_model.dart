class PrinterConfigModel {
  final String printerType; // 'thermal', 'label', 'a4'
  final String printerBrand; // 'Brother', 'Epson', 'Star', 'Xprinter', 'Dymo', 'Generic'
  final String? printerModel;
  final String ipAddress;
  final String protocol; // 'TCP', 'USB'
  final bool isDefault;
  final int? port; // Optional port number
  final String? usbDeviceId; // For USB printers
  final LabelSize? labelSize; // For label printers
  final int? paperWidth; // For thermal printers (80mm, 58mm)

  PrinterConfigModel({
    required this.printerType,
    required this.printerBrand,
    this.printerModel,
    required this.ipAddress,
    required this.protocol,
    this.isDefault = false,
    this.port,
    this.usbDeviceId,
    this.labelSize,
    this.paperWidth,
  });

  // Get label dimensions
  String get labelDimensions {
    if (labelSize == null) return 'Not set';
    return '${labelSize!.width}mm × ${labelSize!.height}mm';
  }

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
      labelSize: json['labelSize'] != null ? LabelSize.fromJson(json['labelSize']) : null,
      paperWidth: json['paperWidth'],
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
      'labelSize': labelSize?.toJson(),
      'paperWidth': paperWidth,
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
    LabelSize? labelSize,
    int? paperWidth,
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
      labelSize: labelSize ?? this.labelSize,
      paperWidth: paperWidth ?? this.paperWidth,
    );
  }
}

/// Label size model for label printers
class LabelSize {
  final int width; // in mm
  final int height; // in mm
  final String name; // e.g., "62x100", "102x152"

  LabelSize({required this.width, required this.height, required this.name});

  factory LabelSize.fromJson(Map<String, dynamic> json) {
    return LabelSize(width: json['width'] ?? 0, height: json['height'] ?? 0, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'width': width, 'height': height, 'name': name};
  }

  @override
  String toString() => '$name ($width×$height mm)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LabelSize) return false;
    return other.width == width && other.height == height && other.name == name;
  }

  @override
  int get hashCode => Object.hash(width, height, name);

  // Predefined label sizes for different brands
  static List<LabelSize> getBrotherSizes() {
    return [
      LabelSize(width: 62, height: 100, name: '62x100'),
      LabelSize(width: 62, height: 29, name: '62x29'),
      LabelSize(width: 102, height: 152, name: '102x152'),
      LabelSize(width: 102, height: 51, name: '102x51'),
      LabelSize(width: 29, height: 90, name: '29x90'),
    ];
  }

  static List<LabelSize> getDymoSizes() {
    return [
      LabelSize(width: 54, height: 101, name: '54x101'),
      LabelSize(width: 102, height: 159, name: '102x159'),
      LabelSize(width: 89, height: 28, name: '89x28'),
      LabelSize(width: 54, height: 25, name: '54x25'),
    ];
  }

  static List<LabelSize> getXprinterSizes() {
    return [
      LabelSize(width: 80, height: 80, name: '80x80'),
      LabelSize(width: 80, height: 60, name: '80x60'),
      LabelSize(width: 60, height: 40, name: '60x40'),
      LabelSize(width: 100, height: 100, name: '100x100'),
    ];
  }
}
