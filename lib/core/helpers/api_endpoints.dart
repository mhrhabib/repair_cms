class ApiEndpoints {
  static const String baseUrl = 'https://api.repaircms.com';
  static const String findUserByEmail = '$baseUrl/auth/find-by-email/';
  static const String findByOwner = '$baseUrl/user/find-by-owner/';
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
  static const String uploadProfileAvatar = '$baseUrl/file-upload/json/<userId>/profile';
  static const String getAnImage = '$baseUrl/file-upload/json/images';

  //job
  static const String getAllJobs = '$baseUrl/job';
  static const String createJob = '$baseUrl/job';
  static const String getJobById = '$baseUrl/job/<id>';

  static const String completeUserJob = '$baseUrl/job/user/complete/<id>';
  static const String jobFileUpload = '$baseUrl/job/file-upload/<userId>/<jobId>';

  //quick task
  static const String getAllQuickTasks = '$baseUrl/quick-task/user/<id>';
  static const String completeTodo = '$baseUrl/quick-task/<id>';
  static const String deleteTodo = '$baseUrl/quick-task/<id>';
  static const String createTodo = '$baseUrl/quick-task';

  //services
  static const String servicesListUrl = '$baseUrl/auth/service';
  //brands
  static const String brandsListUrl = '$baseUrl/manufacturer/user/<id>';
  static const String addbrandsListUrl = '$baseUrl/manufacturer';
  //models
  static const String modelsListUrl = '$baseUrl/model/brand/<brandId>';
  static const String createModel = '$baseUrl/model';

  // accessories
  static const String accessoriesListUrl = '$baseUrl/accessories/user/<id>';
  static const String createAccessories = '$baseUrl/accessories/create';
  //business list
  static const String businessListUrl = '$baseUrl/customer-or-supplier/user/<id>';
  static const String createBusiness = '$baseUrl/customer-or-supplier';
  static const String updateBusiness = '$baseUrl/customer-or-supplier/<id>';
  //job types
  static const String jobTypeListUrl = '$baseUrl/job-type/user/<id>';
  //items
  static const String itemsListUrl = '$baseUrl/auth/item/user/<id>';

  static const String fileUplaodUrl = '$baseUrl/file-upload/';

  //notifications
  static const String getAllNotifications = '$baseUrl/notification/user/<id>';
}
