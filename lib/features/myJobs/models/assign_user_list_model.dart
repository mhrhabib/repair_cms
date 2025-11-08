class AssignUserListModel {
  final bool success;
  final List<User> data;

  AssignUserListModel({required this.success, required this.data});

  factory AssignUserListModel.fromJson(Map<String, dynamic> json) {
    return AssignUserListModel(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>).map((e) => User.fromJson(e)).toList(),
    );
  }
}

// ================== USER =====================
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? avatar;
  final bool isVerified;
  final bool isNew;
  final String? kindOfWork;
  final bool? getFeatureUpdate;
  final String? position;
  final String? shortName;

  final Currency? currency;
  // final DateFormatModel? dateFormat;
  // final TimeFormatModel? timeFormat;
  // final TimeZoneModel? timeZone;

  final bool repaircmsAccess;
  final String? userType;
  final bool isSubUser;

  final Location? location;
  final String? repairTrackingId;

  final bool? appStoreAccess;
  final bool? companyAccess;
  final bool? contactsAccess;
  final bool? ecommerceAccess;
  final bool? emailTemplateAccess;
  final bool? exportDataAccess;
  final bool? invoiceAccess;
  final bool? jobsAccess;
  final bool? labelAccess;
  final bool? paymentMethodAccess;
  final bool? receiptAccess;
  final bool? servicesAccess;
  final bool? settingsAccess;
  final bool? statusAccess;
  final bool? stockAccess;
  final bool? textTemplateAccess;
  final bool? turnoverAccess;

  final String? stripeAccountId;
  final bool? stripeOnboardingComplete;

  final bool? isEmailChanged;
  final bool? forceUpgrade;
  final bool? appBasedAuthEnabled;
  final bool? emailBasedAuthEnabled;

  final String? twoFactorEmail;
  final Subscription? subscription;

  final List<String>? accessList;
  final bool? getFeature;

  final JobRights? jobRights;

  User({
    required this.id,
    required this.email,
    this.fullName,
    this.avatar,
    required this.isVerified,
    required this.isNew,
    this.kindOfWork,
    this.getFeatureUpdate,
    this.position,
    this.shortName,
    this.currency,
    // this.dateFormat,
    // this.timeFormat,
    // this.timeZone,
    required this.repaircmsAccess,
    this.userType,
    required this.isSubUser,
    this.location,
    this.repairTrackingId,
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
    this.textTemplateAccess,
    this.turnoverAccess,
    this.stripeAccountId,
    this.stripeOnboardingComplete,
    this.isEmailChanged,
    this.forceUpgrade,
    this.appBasedAuthEnabled,
    this.emailBasedAuthEnabled,
    this.twoFactorEmail,
    this.subscription,
    this.accessList,
    this.getFeature,
    this.jobRights,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      fullName: json['fullName'],
      avatar: json['avatar'],
      isVerified: json['isVerified'] ?? false,
      isNew: json['isNew'] ?? false,
      kindOfWork: json['kindOfWork'],
      getFeatureUpdate: json['getFeatureUpdate'],
      position: json['position'],
      shortName: json['shortName'],

      currency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,

      // dateFormat: json['dateFormat'] != null ? DateFormatModel.fromJson(json['dateFormat']) : null,
      // timeFormat: json['timeFormat'] != null ? TimeFormatModel.fromJson(json['timeFormat']) : null,
      // timeZone: json['timeZone'] != null ? TimeZoneModel.fromJson(json['timeZone']) : null,
      repaircmsAccess: json['repaircms_access'] ?? false,
      userType: json['userType'],
      isSubUser: json['isSubUser'] ?? false,

      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      repairTrackingId: json['repair_tracking_id'],

      appStoreAccess: json['app_store_access'],
      companyAccess: json['company_access'],
      contactsAccess: json['contacts_access'],
      ecommerceAccess: json['ecommerce_access'],
      emailTemplateAccess: json['email_template_access'],
      exportDataAccess: json['export_data_access'],
      invoiceAccess: json['invoice_access'],
      jobsAccess: json['jobs_access'],
      labelAccess: json['label_access'],
      paymentMethodAccess: json['payment_method_access'],
      receiptAccess: json['receipt_access'],
      servicesAccess: json['services_access'],
      settingsAccess: json['settings_access'],
      statusAccess: json['status_access'],
      stockAccess: json['stock_access'],
      textTemplateAccess: json['text_template_access'],
      turnoverAccess: json['turnover_access'],

      stripeAccountId: json['stripeAccountId'],
      stripeOnboardingComplete: json['stripeOnboardingComplete'],

      isEmailChanged: json['isEmailChanged'],
      forceUpgrade: json['force_upgrade'],
      appBasedAuthEnabled: json['app_based_auth_enabled'],
      emailBasedAuthEnabled: json['email_based_auth_enabled'],
      twoFactorEmail: json['two_factor_email'],

      subscription: json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null,

      accessList: json['accessList'] != null ? List<String>.from(json['accessList']) : [],

      getFeature: json['getFeatureUpdate'],

      jobRights: json['job_rights'] != null ? JobRights.fromJson(json['job_rights']) : null,
    );
  }
}

// ================== SUB MODELS =====================

class Currency {
  final String value;
  final String name;
  final String code;
  final String symbol;

  Currency({required this.value, required this.name, required this.code, required this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(value: json['value'], name: json['name'], code: json['code'], symbol: json['symbol']);
  }
}

class DateFormatModel {
  final String value;
  final String name;
  final String format;

  DateFormatModel({required this.value, required this.name, required this.format});

  factory DateFormatModel.fromJson(Map<String, dynamic> json) {
    return DateFormatModel(value: json['value'], name: json['name'], format: json['format']);
  }
}

class TimeFormatModel {
  final String value;
  final String name;
  final String format;
  final bool hour12;

  TimeFormatModel({required this.value, required this.name, required this.format, required this.hour12});

  factory TimeFormatModel.fromJson(Map<String, dynamic> json) {
    return TimeFormatModel(
      value: json['value'],
      name: json['name'],
      format: json['format'],
      hour12: json['hour12'] ?? false,
    );
  }
}

class TimeZoneModel {
  final String value;
  final String name;
  final String code;
  final int offset;
  final String timeZone;

  TimeZoneModel({
    required this.value,
    required this.name,
    required this.code,
    required this.offset,
    required this.timeZone,
  });

  factory TimeZoneModel.fromJson(Map<String, dynamic> json) {
    return TimeZoneModel(
      value: json['value'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      offset: json['offset'] ?? '',
      timeZone: json['timeZone'] ?? '',
    );
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

  Location({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.street,
    required this.streetNo,
    required this.zipCode,
    required this.city,
    required this.country,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['_id'],
      locationId: json['location_id'],
      locationName: json['location_name'],
      street: json['street'],
      streetNo: json['street_no'],
      zipCode: json['zip_code'],
      city: json['city'],
      country: json['country'],
    );
  }
}

class Subscription {
  final String id;
  final String plan;
  final String status;
  final String startDate;
  final String endDate;
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
      id: json['_id'],
      plan: json['plan'],
      status: json['status'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      billingPeriod: json['billing_period'],
      seats: json['seats'],
    );
  }
}

class JobRights {
  final bool creatingReceipts;
  final bool completingJob;
  final bool returnDevice;
  final bool updatingJob;

  JobRights({
    required this.creatingReceipts,
    required this.completingJob,
    required this.returnDevice,
    required this.updatingJob,
  });

  factory JobRights.fromJson(Map<String, dynamic> json) {
    return JobRights(
      creatingReceipts: json['creating_receipts'] ?? false,
      completingJob: json['completing_job'] ?? false,
      returnDevice: json['return_device'] ?? false,
      updatingJob: json['updating_job'] ?? false,
    );
  }
}
