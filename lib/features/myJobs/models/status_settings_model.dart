class StatusSetting {
  final String id;
  final String statusName;
  final String colorCode;
  final String userId;
  final String companyId;
  final String createdAt;
  final String updatedAt;
  final int v;

  StatusSetting({
    required this.id,
    required this.statusName,
    required this.colorCode,
    required this.userId,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory StatusSetting.fromJson(Map<String, dynamic> json) {
    return StatusSetting(
      id: json['_id'] ?? json['id'] ?? '',
      statusName: json['statusName'] ?? '',
      colorCode: json['colorCode'] ?? '#000000',
      userId: json['userId'] ?? '',
      companyId: json['companyId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'statusName': statusName,
      'colorCode': colorCode,
      'userId': userId,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}

class StatusSettingsResponse {
  final bool success;
  final int totalStatus;
  final List<StatusSetting> status;

  StatusSettingsResponse({
    required this.success,
    required this.totalStatus,
    required this.status,
  });

  factory StatusSettingsResponse.fromJson(Map<String, dynamic> json) {
    return StatusSettingsResponse(
      success: json['success'] ?? false,
      totalStatus: json['totalStatus'] ?? 0,
      status: (json['status'] as List<dynamic>?)
          ?.map((item) => StatusSetting.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'totalStatus': totalStatus,
      'status': status.map((item) => item.toJson()).toList(),
    };
  }
}