class FindUserResponseModel {
  final bool success;
  final String message;

  FindUserResponseModel({required this.success, required this.message});

  factory FindUserResponseModel.fromJson(Map<String, dynamic> json) {
    return FindUserResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
