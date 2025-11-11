// models/login_response_model.dart
class LoginResponseModel {
  final bool success;
  final String message;
  final String? error;
  final LoginData? data;

  LoginResponseModel({
    required this.success,
    required this.message,
    this.error,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
      data: json['data'] != null ? LoginData.fromJson(json['data']) : null,
    );
  }
}

class LoginData {
  final String accessToken;
  final User user;

  LoginData({required this.accessToken, required this.user});

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      accessToken: json['accessToken'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}

class User {
  final String id;
  final String email;
  final String fullName;
  final String? avatar;
  final bool isVerified;
  final String userType;
  final bool isSubUser;
  final String role;
  final Location? location;
  final Subscription? subscription;
  final Map<String, dynamic> currency;
  final Map<String, dynamic> timeZone;
  final bool repaircmsAccess;
  final bool stripeOnboardingComplete;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatar,
    required this.isVerified,
    required this.userType,
    required this.isSubUser,
    required this.role,
    this.location,
    this.subscription,
    required this.currency,
    required this.timeZone,
    required this.repaircmsAccess,
    required this.stripeOnboardingComplete,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'],
      isVerified: json['isVerified'] ?? false,
      userType: json['userType'] ?? '',
      isSubUser: json['isSubUser'] ?? false,
      role: json['role'] ?? '',
      location: json['location'] != null
          ? Location.fromJson(json['location'])
          : null,
      subscription: json['subscription'] != null
          ? Subscription.fromJson(json['subscription'])
          : null,
      currency: json['currency'] ?? {},
      timeZone: json['timeZone'] ?? {},
      repaircmsAccess: json['repaircms_access'] ?? false,
      stripeOnboardingComplete: json['stripeOnboardingComplete'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'isVerified': isVerified,
      'userType': userType,
      'isSubUser': isSubUser,
      'role': role,
      'location': location?.toJson(),
      'subscription': subscription?.toJson(),
      'currency': currency,
      'timeZone': timeZone,
      'repaircms_access': repaircmsAccess,
      'stripeOnboardingComplete': stripeOnboardingComplete,
    };
  }
}

class Location {
  final String id;
  final String locationId;
  final String locationName;
  final String city;
  final String country;
  final bool isDefault;

  Location({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.city,
    required this.country,
    required this.isDefault,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'] ?? json['id'] ?? '',
      locationId: json['location_id'] ?? '',
      locationName: json['location_name'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      isDefault: json['default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_id': locationId,
      'location_name': locationName,
      'city': city,
      'country': country,
      'default': isDefault,
    };
  }
}

class Subscription {
  final String id;
  final String plan;
  final String status;
  final DateTime startDate;
  final DateTime endDate;
  final String billingPeriod;
  final int seats;

  Subscription({
    required this.id,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.billingPeriod,
    required this.seats,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] ?? json['id'] ?? '',
      plan: json['plan'] ?? '',
      status: json['status'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      billingPeriod: json['billing_period'] ?? '',
      seats: json['seats'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan': plan,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'billing_period': billingPeriod,
      'seats': seats,
    };
  }
}
