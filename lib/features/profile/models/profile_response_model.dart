class ProfileResponseModel {
  bool? success;
  String? message;
  UserData? data;
  String? error;

  ProfileResponseModel({this.success, this.message, this.data, this.error});

  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
      error: json['error'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson(), 'error': error};
  }
}

class UserData {
  String? id;
  String? email;
  String? fullName;
  bool? getFeatureUpdate;
  String? avatar;
  bool? isVerified;
  bool? isNew;
  String? kindOfWork;
  int? v;
  String? updatedAt;
  String? position;
  String? shortName;
  Currency? currency;
  DateFormat? dateFormat;
  Language? language;
  TimeFormat? timeFormat;
  TimeZone? timeZone;
  bool? repaircmsAccess;
  String? userType;
  bool? isSubUser;
  Location? location;
  String? repairTrackingId;
  List<dynamic>? accessList;
  bool? appStoreAccess;
  bool? companyAccess;
  bool? contactsAccess;
  bool? ecommerceAccess;
  bool? emailTemplateAccess;
  bool? exportDataAccess;
  bool? invoiceAccess;
  bool? jobsAccess;
  bool? labelAccess;
  bool? paymentMethodAccess;
  bool? receiptAccess;
  bool? servicesAccess;
  bool? settingsAccess;
  bool? statusAccess;
  bool? stockAccess;
  bool? stripeOnboardingComplete;
  bool? textTemplateAccess;
  bool? turnoverAccess;
  bool? isEmailChanged;
  String? stripeAccountId;
  bool? forceUpgrade;
  String? role;
  String? twoFactorEmail;
  bool? emailBasedAuthEnabled;
  bool? appBasedAuthEnabled;
  Subscription? subscription;

  UserData({
    this.id,
    this.email,
    this.fullName,
    this.getFeatureUpdate,
    this.avatar,
    this.isVerified,
    this.isNew,
    this.kindOfWork,
    this.v,
    this.updatedAt,
    this.position,
    this.shortName,
    this.currency,
    this.dateFormat,
    this.language,
    this.timeFormat,
    this.timeZone,
    this.repaircmsAccess,
    this.userType,
    this.isSubUser,
    this.location,
    this.repairTrackingId,
    this.accessList,
    this.appStoreAccess,
    this.companyAccess,
    this.contactsAccess,
    this.ecommerceAccess,
    this.emailTemplateAccess,
    this.exportDataAccess,
    this.invoiceAccess,
    this.jobsAccess,
    this.labelAccess,
    this.paymentMethodAccess,
    this.receiptAccess,
    this.servicesAccess,
    this.settingsAccess,
    this.statusAccess,
    this.stockAccess,
    this.stripeOnboardingComplete,
    this.textTemplateAccess,
    this.turnoverAccess,
    this.isEmailChanged,
    this.stripeAccountId,
    this.forceUpgrade,
    this.role,
    this.twoFactorEmail,
    this.emailBasedAuthEnabled,
    this.appBasedAuthEnabled,
    this.subscription,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? json['id'] ?? '', // Handle both _id and id
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      getFeatureUpdate: json['getFeatureUpdate'] ?? false,
      avatar: json['avatar'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isNew: json['isNew'] ?? false,
      kindOfWork: json['kindOfWork'] ?? '',
      v: json['__v'] ?? 0,
      updatedAt: json['updatedAt'] ?? '',
      position: json['position'] ?? '',
      shortName: json['shortName'] ?? '',
      currency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
      dateFormat: json['dateFormat'] != null ? DateFormat.fromJson(json['dateFormat']) : null,
      language: json['language'] != null ? Language.fromJson(json['language']) : null,
      timeFormat: json['timeFormat'] != null ? TimeFormat.fromJson(json['timeFormat']) : null,
      timeZone: json['timeZone'] != null ? TimeZone.fromJson(json['timeZone']) : null,
      repaircmsAccess: json['repaircms_access'] ?? false,
      userType: json['userType'] ?? '',
      isSubUser: json['isSubUser'] ?? false,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      repairTrackingId: json['repair_tracking_id'] ?? '',
      accessList: json['accessList'] ?? [],
      appStoreAccess: json['app_store_access'] ?? false,
      companyAccess: json['company_access'] ?? false,
      contactsAccess: json['contacts_access'] ?? false,
      ecommerceAccess: json['ecommerce_access'] ?? false,
      emailTemplateAccess: json['email_template_access'] ?? false,
      exportDataAccess: json['export_data_access'] ?? false,
      invoiceAccess: json['invoice_access'] ?? false,
      jobsAccess: json['jobs_access'] ?? false,
      labelAccess: json['label_access'] ?? false,
      paymentMethodAccess: json['payment_method_access'] ?? false,
      receiptAccess: json['receipt_access'] ?? false,
      servicesAccess: json['services_access'] ?? false,
      settingsAccess: json['settings_access'] ?? false,
      statusAccess: json['status_access'] ?? false,
      stockAccess: json['stock_access'] ?? false,
      stripeOnboardingComplete: json['stripeOnboardingComplete'] ?? false,
      textTemplateAccess: json['text_template_access'] ?? false,
      turnoverAccess: json['turnover_access'] ?? false,
      isEmailChanged: json['isEmailChanged'] ?? false,
      stripeAccountId: json['stripeAccountId'] ?? '',
      forceUpgrade: json['force_upgrade'] ?? false,
      role: json['role'] ?? '',
      twoFactorEmail: json['two_factor_email'] ?? '',
      emailBasedAuthEnabled: json['email_based_auth_enabled'] ?? false,
      appBasedAuthEnabled: json['app_based_auth_enabled'] ?? false,
      subscription: json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'fullName': fullName,
      'getFeatureUpdate': getFeatureUpdate,
      'avatar': avatar,
      'isVerified': isVerified,
      'isNew': isNew,
      'kindOfWork': kindOfWork,
      '__v': v,
      'updatedAt': updatedAt,
      'position': position,
      'shortName': shortName,
      'currency': currency?.toJson(),
      'dateFormat': dateFormat?.toJson(),
      'language': language?.toJson(),
      'timeFormat': timeFormat?.toJson(),
      'timeZone': timeZone?.toJson(),
      'repaircms_access': repaircmsAccess,
      'userType': userType,
      'isSubUser': isSubUser,
      'location': location?.toJson(),
      'repair_tracking_id': repairTrackingId,
      'accessList': accessList,
      'app_store_access': appStoreAccess,
      'company_access': companyAccess,
      'contacts_access': contactsAccess,
      'ecommerce_access': ecommerceAccess,
      'email_template_access': emailTemplateAccess,
      'export_data_access': exportDataAccess,
      'invoice_access': invoiceAccess,
      'jobs_access': jobsAccess,
      'label_access': labelAccess,
      'payment_method_access': paymentMethodAccess,
      'receipt_access': receiptAccess,
      'services_access': servicesAccess,
      'settings_access': settingsAccess,
      'status_access': statusAccess,
      'stock_access': stockAccess,
      'stripeOnboardingComplete': stripeOnboardingComplete,
      'text_template_access': textTemplateAccess,
      'turnover_access': turnoverAccess,
      'isEmailChanged': isEmailChanged,
      'stripeAccountId': stripeAccountId,
      'force_upgrade': forceUpgrade,
      'role': role,
      'two_factor_email': twoFactorEmail,
      'email_based_auth_enabled': emailBasedAuthEnabled,
      'app_based_auth_enabled': appBasedAuthEnabled,
      'subscription': subscription?.toJson(),
    };
  }
}

class Currency {
  String? value;
  String? name;
  String? code;
  String? symbol;

  Currency({this.value, this.name, this.code, this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      value: json['value'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'name': name, 'code': code, 'symbol': symbol};
  }
}

class DateFormat {
  String? value;
  String? name;
  String? format;

  DateFormat({this.value, this.name, this.format});

  factory DateFormat.fromJson(Map<String, dynamic> json) {
    return DateFormat(value: json['value'] ?? '', name: json['name'] ?? '', format: json['format'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'name': name, 'format': format};
  }
}

class Language {
  String? value;
  String? name;
  String? code;

  Language({this.value, this.name, this.code});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(value: json['value'] ?? '', name: json['name'] ?? '', code: json['code'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'name': name, 'code': code};
  }
}

class TimeFormat {
  String? value;
  String? name;
  String? format;
  bool? hour12;

  TimeFormat({this.value, this.name, this.format, this.hour12});

  factory TimeFormat.fromJson(Map<String, dynamic> json) {
    return TimeFormat(
      value: json['value'] ?? '',
      name: json['name'] ?? '',
      format: json['format'] ?? '',
      hour12: json['hour12'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'name': name, 'format': format, 'hour12': hour12};
  }
}

class TimeZone {
  String? value;
  String? name;
  String? code;
  int? offset;
  String? label;

  TimeZone({this.value, this.name, this.code, this.offset, this.label});

  factory TimeZone.fromJson(Map<String, dynamic> json) {
    return TimeZone(
      value: json['value'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      offset: json['offset'] ?? 0,
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'name': name, 'code': code, 'offset': offset, 'label': label};
  }
}

class Location {
  String? id;
  String? locationId;
  String? locationName;
  String? street;
  String? streetNo;
  String? zipCode;
  String? city;
  String? country;
  String? email;
  String? telephone;
  bool? allowEcommerceSendIn;
  bool? allowContacts;
  bool? allowServicesStocks;
  bool? allowJobsInvoices;
  bool? allowMultiClient;
  bool? defaultLocation;
  String? companyId;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? openingHours;
  String? locationPrefix;

  Location({
    this.id,
    this.locationId,
    this.locationName,
    this.street,
    this.streetNo,
    this.zipCode,
    this.city,
    this.country,
    this.email,
    this.telephone,
    this.allowEcommerceSendIn,
    this.allowContacts,
    this.allowServicesStocks,
    this.allowJobsInvoices,
    this.allowMultiClient,
    this.defaultLocation,
    this.companyId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.openingHours,
    this.locationPrefix,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'] ?? json['id'] ?? '',
      locationId: json['location_id'] ?? '',
      locationName: json['location_name'] ?? '',
      street: json['street'] ?? '',
      streetNo: json['street_no'] ?? '',
      zipCode: json['zip_code'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      allowEcommerceSendIn: json['allow_ecommerce_send_in'] ?? false,
      allowContacts: json['allow_contacts'] ?? false,
      allowServicesStocks: json['allow_services_stocks'] ?? false,
      allowJobsInvoices: json['allow_jobs_invoices'] ?? false,
      allowMultiClient: json['allow_multi_client'] ?? false,
      defaultLocation: json['default'] ?? false,
      companyId: json['companyId'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
      openingHours: json['openingHours'] ?? '',
      locationPrefix: json['location_prefix'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'location_id': locationId,
      'location_name': locationName,
      'street': street,
      'street_no': streetNo,
      'zip_code': zipCode,
      'city': city,
      'country': country,
      'email': email,
      'telephone': telephone,
      'allow_ecommerce_send_in': allowEcommerceSendIn,
      'allow_contacts': allowContacts,
      'allow_services_stocks': allowServicesStocks,
      'allow_jobs_invoices': allowJobsInvoices,
      'allow_multi_client': allowMultiClient,
      'default': defaultLocation,
      'companyId': companyId,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'openingHours': openingHours,
      'location_prefix': locationPrefix,
    };
  }
}

class Subscription {
  String? id;
  String? plan;
  String? status;
  String? startDate;
  String? endDate;
  String? billingPeriod;
  String? subscriptionId;
  String? stripeCustomerId;
  int? seats;
  String? userId;
  int? orderNumber;
  int? additionalSeats;
  String? createdAt;
  String? updatedAt;
  int? v;
  int? additionalLocation;

  Subscription({
    this.id,
    this.plan,
    this.status,
    this.startDate,
    this.endDate,
    this.billingPeriod,
    this.subscriptionId,
    this.stripeCustomerId,
    this.seats,
    this.userId,
    this.orderNumber,
    this.additionalSeats,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.additionalLocation,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] ?? json['id'] ?? '',
      plan: json['plan'] ?? '',
      status: json['status'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      billingPeriod: json['billing_period'] ?? '',
      subscriptionId: json['subscriptionId'] ?? '',
      stripeCustomerId: json['stripeCustomerId'] ?? '',
      seats: json['seats'] ?? 0,
      userId: json['userId'] ?? '',
      orderNumber: json['order_number'] ?? 0,
      additionalSeats: json['additional_seats'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
      additionalLocation: json['additional_location'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'plan': plan,
      'status': status,
      'startDate': startDate,
      'endDate': endDate,
      'billing_period': billingPeriod,
      'subscriptionId': subscriptionId,
      'stripeCustomerId': stripeCustomerId,
      'seats': seats,
      'userId': userId,
      'order_number': orderNumber,
      'additional_seats': additionalSeats,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
      'additional_location': additionalLocation,
    };
  }
}
