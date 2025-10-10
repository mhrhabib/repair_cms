class ApiEndpoints {
  static const String baseUrl = 'https://api.repaircms.com';
  static const String findUserByEmail = '$baseUrl/auth/find-by-email/';
  static const String login = '$baseUrl/auth/login';
  static const String sentOtp = '$baseUrl/auth/otp';
  static const String verifyOtp = '$baseUrl/auth/check-otp';
  static const String updatePassword = '$baseUrl/user/email/';
  static const String passwordForgotten = '$baseUrl/auth/forget-password';

  //user profile
  static const String getProfile = '$baseUrl/auth/me';
  static const String updateProfileById = '$baseUrl/user/<id>';
  static const String updateProfileEmail = '$baseUrl/user/email/<id>';
  static const String updateProfilePassword = '$baseUrl/user/password/<id>';
  static const String updateProfileAvatar = '$baseUrl/user/avatar/<id>';

  //job
  static const String getAllJobs = '$baseUrl/job';
  static const String createJob = '$baseUrl/job';

  static const String completeUserJob = '$baseUrl/job/user/complete/<id>';

  //quick task
  static const String getAllQuickTasks = '$baseUrl/quick-task/user/<id>';
  static const String completeTodo = '$baseUrl/quick-task/<id>';
  static const String deleteTodo = '$baseUrl/quick-task/<id>';
  static const String createTodo = '$baseUrl/quick-task';

  //services
  static const String servicesListUrl = '$baseUrl/auth/service';
}
