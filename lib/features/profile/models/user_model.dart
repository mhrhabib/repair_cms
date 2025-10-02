class User {
  final String id;
  final String email;
  final String fullName;
  final String password;
  final bool getFeatureUpdate;
  final String avatar;
  final bool isVerified;
  final bool isNew;
  final String kindOfWork;
  final int v;
  final DateTime updatedAt;
  final String position;
  final String shortName;
  final Currency currency;
  final DateFormat dateFormat;
  final Language language;
  final TimeFormat timeFormat;
  final TimeZone timeZone;
  final bool repaircmsAccess;
  final String userType;
  final bool isSubUser;
  final Location location;
  final String repairTrackingId;
  final List<dynamic> accessList;
  final bool appStoreAccess;
  final bool companyAccess;
  final bool contactsAccess;
  final bool ecommerceAccess;
  final bool emailTemplateAccess;
  final bool exportDataAccess;
  final bool invoiceAccess;
  final bool jobsAccess;
  final bool labelAccess;
  final bool paymentMethodAccess;
  final bool receiptAccess;
  final bool servicesAccess;
  final bool settingsAccess;
  final bool statusAccess;
  final bool stockAccess;
  final bool stripeOnboardingComplete;
  final bool textTemplateAccess;
  final bool turnoverAccess;
  final bool isEmailChanged;
  final String stripeAccountId;
  final bool forceUpgrade;
  final String role;
  final String twoFactorEmail;
  final bool emailBasedAuthEnabled;
  final bool appBasedAuthEnabled;
  final Subscription subscription;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.password,
    required this.getFeatureUpdate,
    required this.avatar,
    required this.isVerified,
    required this.isNew,
    required this.kindOfWork,
    required this.v,
    required this.updatedAt,
    required this.position,
    required this.shortName,
    required this.currency,
    required this.dateFormat,
    required this.language,
    required this.timeFormat,
    required this.timeZone,
    required this.repaircmsAccess,
    required this.userType,
    required this.isSubUser,
    required this.location,
    required this.repairTrackingId,
    required this.accessList,
    required this.appStoreAccess,
    required this.companyAccess,
    required this.contactsAccess,
    required this.ecommerceAccess,
    required this.emailTemplateAccess,
    required this.exportDataAccess,
    required this.invoiceAccess,
    required this.jobsAccess,
    required this.labelAccess,
    required this.paymentMethodAccess,
    required this.receiptAccess,
    required this.servicesAccess,
    required this.settingsAccess,
    required this.statusAccess,
    required this.stockAccess,
    required this.stripeOnboardingComplete,
    required this.textTemplateAccess,
    required this.turnoverAccess,
    required this.isEmailChanged,
    required this.stripeAccountId,
    required this.forceUpgrade,
    required this.role,
    required this.twoFactorEmail,
    required this.emailBasedAuthEnabled,
    required this.appBasedAuthEnabled,
    required this.subscription,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      password: json['password'] ?? '',
      getFeatureUpdate: json['getFeatureUpdate'] ?? false,
      avatar: json['avatar'] ?? '',
      isVerified: json['isVerified'] ?? false,
      isNew: json['isNew'] ?? false,
      kindOfWork: json['kindOfWork'] ?? '',
      v: json['__v'] ?? 0,
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      position: json['position'] ?? '',
      shortName: json['shortName'] ?? '',
      currency: Currency.fromJson(json['currency'] ?? {}),
      dateFormat: DateFormat.fromJson(json['dateFormat'] ?? {}),
      language: Language.fromJson(json['language'] ?? {}),
      timeFormat: TimeFormat.fromJson(json['timeFormat'] ?? {}),
      timeZone: TimeZone.fromJson(json['timeZone'] ?? {}),
      repaircmsAccess: json['repaircms_access'] ?? false,
      userType: json['userType'] ?? '',
      isSubUser: json['isSubUser'] ?? false,
      location: Location.fromJson(json['location'] ?? {}),
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
      subscription: Subscription.fromJson(json['subscription'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'fullName': fullName,
      'password': password,
      'getFeatureUpdate': getFeatureUpdate,
      'avatar': avatar,
      'isVerified': isVerified,
      'isNew': isNew,
      'kindOfWork': kindOfWork,
      '__v': v,
      'updatedAt': updatedAt.toIso8601String(),
      'position': position,
      'shortName': shortName,
      'currency': currency.toJson(),
      'dateFormat': dateFormat.toJson(),
      'language': language.toJson(),
      'timeFormat': timeFormat.toJson(),
      'timeZone': timeZone.toJson(),
      'repaircms_access': repaircmsAccess,
      'userType': userType,
      'isSubUser': isSubUser,
      'location': location.toJson(),
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
      'subscription': subscription.toJson(),
    };
  }
}

class Currency {
  final String value;
  final String name;
  final String code;
  final String symbol;

  Currency({required this.value, required this.name, required this.code, required this.symbol});

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
  final String value;
  final String name;
  final String format;

  DateFormat({required this.value, required this.name, required this.format});

  factory DateFormat.fromJson(Map<String, dynamic> json) {
    return DateFormat(value: json['value'] ?? '', name: json['name'] ?? '', format: json['format'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'name': name, 'format': format};
  }
}

class Language {
  final String value;
  final String name;
  final String code;

  Language({required this.value, required this.name, required this.code});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(value: json['value'] ?? '', name: json['name'] ?? '', code: json['code'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'name': name, 'code': code};
  }
}

class TimeFormat {
  final String value;
  final String name;
  final String format;
  final bool hour12;

  TimeFormat({required this.value, required this.name, required this.format, required this.hour12});

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
  final String value;
  final String name;
  final String code;
  final int offset;
  final String label;

  TimeZone({required this.value, required this.name, required this.code, required this.offset, required this.label});

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
  final String id;
  final String locationId;
  final String locationName;
  final String street;
  final String streetNo;
  final String zipCode;
  final String city;
  final String country;
  final String email;
  final String telephone;
  final bool allowEcommerceSendIn;
  final bool allowContacts;
  final bool allowServicesStocks;
  final bool allowJobsInvoices;
  final bool allowMultiClient;
  final bool defaultLocation;
  final String companyId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String openingHours;
  final String locationPrefix;

  Location({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.street,
    required this.streetNo,
    required this.zipCode,
    required this.city,
    required this.country,
    required this.email,
    required this.telephone,
    required this.allowEcommerceSendIn,
    required this.allowContacts,
    required this.allowServicesStocks,
    required this.allowJobsInvoices,
    required this.allowMultiClient,
    required this.defaultLocation,
    required this.companyId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.openingHours,
    required this.locationPrefix,
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
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'openingHours': openingHours,
      'location_prefix': locationPrefix,
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
  final String subscriptionId;
  final String stripeCustomerId;
  final int seats;
  final String userId;
  final int orderNumber;
  final int additionalSeats;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final int additionalLocation;

  Subscription({
    required this.id,
    required this.plan,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.billingPeriod,
    required this.subscriptionId,
    required this.stripeCustomerId,
    required this.seats,
    required this.userId,
    required this.orderNumber,
    required this.additionalSeats,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.additionalLocation,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] ?? json['id'] ?? '',
      plan: json['plan'] ?? '',
      status: json['status'] ?? '',
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      billingPeriod: json['billing_period'] ?? '',
      subscriptionId: json['subscriptionId'] ?? '',
      stripeCustomerId: json['stripeCustomerId'] ?? '',
      seats: json['seats'] ?? 0,
      userId: json['userId'] ?? '',
      orderNumber: json['order_number'] ?? 0,
      additionalSeats: json['additional_seats'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
      additionalLocation: json['additional_location'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'plan': plan,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'billing_period': billingPeriod,
      'subscriptionId': subscriptionId,
      'stripeCustomerId': stripeCustomerId,
      'seats': seats,
      'userId': userId,
      'order_number': orderNumber,
      'additional_seats': additionalSeats,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'additional_location': additionalLocation,
    };
  }
}
