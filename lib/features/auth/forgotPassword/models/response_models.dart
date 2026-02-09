// models/forgot_password_models.dart
class SendOtpResponseModel {
  final bool success;
  final String message;
  final dynamic data;
  final dynamic error;

  SendOtpResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return SendOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      error: json['error'],
    );
  }
}

class VerifyOtpResponseModel {
  final bool success;
  final String message;
  final dynamic data;
  final dynamic error;

  VerifyOtpResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      error: json['error'],
    );
  }
}

class ResetPasswordResponseModel {
  final bool success;
  final String message;
  final dynamic data;
  final dynamic error;

  ResetPasswordResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      error: json['error'],
    );
  }
}
