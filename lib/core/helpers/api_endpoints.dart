class ApiEndpoints {
  static const String baseUrl = 'https://api.repaircms.com';
  static const String findUserByEmail = '$baseUrl/auth/find-by-email/';
  static const String login = '$baseUrl/auth/login';
  static const String sentOtp = '$baseUrl/auth/otp';
  static const String verifyOtp = '$baseUrl/auth/check-otp';
  static const String updatePassword = '$baseUrl/user/email/';
  static const String passwordForgotten = '$baseUrl/auth/forget-password';
  static const String fetchData = '$baseUrl/data';
}
