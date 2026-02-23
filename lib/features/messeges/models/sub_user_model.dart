class SubUser {
  String? sId;
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
  List<String>? accessList;
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
  String? id;
  String? subUserId;
  String? ownerId;
  String? salutation;
  String? title;
  String? subUserVerificationCode;
  String? userStatus;
  bool? crossLocationJobAccess;
  JobRights? jobRights;

  SubUser({
    this.sId,
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
    this.id,
    this.subUserId,
    this.ownerId,
    this.salutation,
    this.title,
    this.subUserVerificationCode,
    this.userStatus,
    this.crossLocationJobAccess,
    this.jobRights,
  });

  SubUser.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    getFeatureUpdate = json['getFeatureUpdate'];
    avatar = json['avatar'];
    isVerified = json['isVerified'];
    isNew = json['isNew'];
    kindOfWork = json['kindOfWork'];
    v = json['__v'];
    updatedAt = json['updatedAt'];
    position = json['position'];
    shortName = json['shortName'];
    currency = json['currency'] != null ? Currency.fromJson(json['currency']) : null;
    dateFormat = json['dateFormat'] != null ? DateFormat.fromJson(json['dateFormat']) : null;
    language = json['language'] != null ? Language.fromJson(json['language']) : null;
    timeFormat = json['timeFormat'] != null ? TimeFormat.fromJson(json['timeFormat']) : null;
    timeZone = json['timeZone'] != null ? TimeZone.fromJson(json['timeZone']) : null;
    repaircmsAccess = json['repaircms_access'];
    userType = json['userType'];
    isSubUser = json['isSubUser'];
    location = json['location'] != null ? Location.fromJson(json['location']) : null;
    repairTrackingId = json['repair_tracking_id'];
    accessList = json['accessList'] != null ? List<String>.from(json['accessList']) : null;
    appStoreAccess = json['app_store_access'];
    companyAccess = json['company_access'];
    contactsAccess = json['contacts_access'];
    ecommerceAccess = json['ecommerce_access'];
    emailTemplateAccess = json['email_template_access'];
    exportDataAccess = json['export_data_access'];
    invoiceAccess = json['invoice_access'];
    jobsAccess = json['jobs_access'];
    labelAccess = json['label_access'];
    paymentMethodAccess = json['payment_method_access'];
    receiptAccess = json['receipt_access'];
    servicesAccess = json['services_access'];
    settingsAccess = json['settings_access'];
    statusAccess = json['status_access'];
    stockAccess = json['stock_access'];
    stripeOnboardingComplete = json['stripeOnboardingComplete'];
    textTemplateAccess = json['text_template_access'];
    turnoverAccess = json['turnover_access'];
    isEmailChanged = json['isEmailChanged'];
    stripeAccountId = json['stripeAccountId'];
    forceUpgrade = json['force_upgrade'];
    role = json['role'];
    twoFactorEmail = json['two_factor_email'];
    emailBasedAuthEnabled = json['email_based_auth_enabled'];
    appBasedAuthEnabled = json['app_based_auth_enabled'];
    subscription = json['subscription'] != null ? Subscription.fromJson(json['subscription']) : null;
    id = json['id'];
    subUserId = json['sub_user_id'];
    ownerId = json['ownerId'];
    salutation = json['salutation'];
    title = json['title'];
    subUserVerificationCode = json['sub_user_verification_code'];
    userStatus = json['user_status'];
    crossLocationJobAccess = json['cross_location_job_access'];
    jobRights = json['job_rights'] != null ? JobRights.fromJson(json['job_rights']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['email'] = email;
    data['fullName'] = fullName;
    data['getFeatureUpdate'] = getFeatureUpdate;
    data['avatar'] = avatar;
    data['isVerified'] = isVerified;
    data['isNew'] = isNew;
    data['kindOfWork'] = kindOfWork;
    data['__v'] = v;
    data['updatedAt'] = updatedAt;
    data['position'] = position;
    data['shortName'] = shortName;
    if (currency != null) {
      data['currency'] = currency!.toJson();
    }
    if (dateFormat != null) {
      data['dateFormat'] = dateFormat!.toJson();
    }
    if (language != null) {
      data['language'] = language!.toJson();
    }
    if (timeFormat != null) {
      data['timeFormat'] = timeFormat!.toJson();
    }
    if (timeZone != null) {
      data['timeZone'] = timeZone!.toJson();
    }
    data['repaircms_access'] = repaircmsAccess;
    data['userType'] = userType;
    data['isSubUser'] = isSubUser;
    if (location != null) {
      data['location'] = location!.toJson();
    }
    data['repair_tracking_id'] = repairTrackingId;
    data['accessList'] = accessList;
    data['app_store_access'] = appStoreAccess;
    data['company_access'] = companyAccess;
    data['contacts_access'] = contactsAccess;
    data['ecommerce_access'] = ecommerceAccess;
    data['email_template_access'] = emailTemplateAccess;
    data['export_data_access'] = exportDataAccess;
    data['invoice_access'] = invoiceAccess;
    data['jobs_access'] = jobsAccess;
    data['label_access'] = labelAccess;
    data['payment_method_access'] = paymentMethodAccess;
    data['receipt_access'] = receiptAccess;
    data['services_access'] = servicesAccess;
    data['settings_access'] = settingsAccess;
    data['status_access'] = statusAccess;
    data['stock_access'] = stockAccess;
    data['stripeOnboardingComplete'] = stripeOnboardingComplete;
    data['text_template_access'] = textTemplateAccess;
    data['turnover_access'] = turnoverAccess;
    data['isEmailChanged'] = isEmailChanged;
    data['stripeAccountId'] = stripeAccountId;
    data['force_upgrade'] = forceUpgrade;
    data['role'] = role;
    data['two_factor_email'] = twoFactorEmail;
    data['email_based_auth_enabled'] = emailBasedAuthEnabled;
    data['app_based_auth_enabled'] = appBasedAuthEnabled;
    if (subscription != null) {
      data['subscription'] = subscription!.toJson();
    }
    data['id'] = id;
    data['sub_user_id'] = subUserId;
    data['ownerId'] = ownerId;
    data['salutation'] = salutation;
    data['title'] = title;
    data['sub_user_verification_code'] = subUserVerificationCode;
    data['user_status'] = userStatus;
    data['cross_location_job_access'] = crossLocationJobAccess;
    if (jobRights != null) {
      data['job_rights'] = jobRights!.toJson();
    }
    return data;
  }
}

class Currency {
  String? value;
  String? name;
  String? code;
  String? symbol;

  Currency({this.value, this.name, this.code, this.symbol});

  Currency.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    name = json['name'];
    code = json['code'];
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['value'] = value;
    data['name'] = name;
    data['code'] = code;
    data['symbol'] = symbol;
    return data;
  }
}

class DateFormat {
  String? value;
  String? name;
  String? format;

  DateFormat({this.value, this.name, this.format});

  DateFormat.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    name = json['name'];
    format = json['format'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['value'] = value;
    data['name'] = name;
    data['format'] = format;
    return data;
  }
}

class Language {
  String? value;
  String? name;
  String? code;

  Language({this.value, this.name, this.code});

  Language.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    name = json['name'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['value'] = value;
    data['name'] = name;
    data['code'] = code;
    return data;
  }
}

class TimeFormat {
  String? value;
  String? name;
  String? format;
  bool? hour12;

  TimeFormat({this.value, this.name, this.format, this.hour12});

  TimeFormat.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    name = json['name'];
    format = json['format'];
    hour12 = json['hour12'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['value'] = value;
    data['name'] = name;
    data['format'] = format;
    data['hour12'] = hour12;
    return data;
  }
}

class TimeZone {
  String? value;
  String? name;
  String? code;
  int? offset;
  String? label;
  String? timeZone;

  TimeZone({this.value, this.name, this.code, this.offset, this.label, this.timeZone});

  TimeZone.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    name = json['name'];
    code = json['code'];
    offset = json['offset'];
    label = json['label'];
    timeZone = json['timeZone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['value'] = value;
    data['name'] = name;
    data['code'] = code;
    data['offset'] = offset;
    data['label'] = label;
    data['timeZone'] = timeZone;
    return data;
  }
}

class Location {
  String? sId;
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
  String? id;

  Location({
    this.sId,
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
    this.id,
  });

  Location.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    locationId = json['location_id'];
    locationName = json['location_name'];
    street = json['street'];
    streetNo = json['street_no'];
    zipCode = json['zip_code'];
    city = json['city'];
    country = json['country'];
    email = json['email'];
    telephone = json['telephone'];
    allowEcommerceSendIn = json['allow_ecommerce_send_in'];
    allowContacts = json['allow_contacts'];
    allowServicesStocks = json['allow_services_stocks'];
    allowJobsInvoices = json['allow_jobs_invoices'];
    allowMultiClient = json['allow_multi_client'];
    defaultLocation = json['default'];
    companyId = json['companyId'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
    openingHours = json['openingHours'];
    locationPrefix = json['location_prefix'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['location_id'] = locationId;
    data['location_name'] = locationName;
    data['street'] = street;
    data['street_no'] = streetNo;
    data['zip_code'] = zipCode;
    data['city'] = city;
    data['country'] = country;
    data['email'] = email;
    data['telephone'] = telephone;
    data['allow_ecommerce_send_in'] = allowEcommerceSendIn;
    data['allow_contacts'] = allowContacts;
    data['allow_services_stocks'] = allowServicesStocks;
    data['allow_jobs_invoices'] = allowJobsInvoices;
    data['allow_multi_client'] = allowMultiClient;
    data['default'] = defaultLocation;
    data['companyId'] = companyId;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    data['openingHours'] = openingHours;
    data['location_prefix'] = locationPrefix;
    data['id'] = id;
    return data;
  }
}

class Subscription {
  String? sId;
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
  bool? isBlocked;
  bool? isWarning;
  String? failedDate;
  String? id;

  Subscription({
    this.sId,
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
    this.isBlocked,
    this.isWarning,
    this.failedDate,
    this.id,
  });

  Subscription.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    plan = json['plan'];
    status = json['status'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    billingPeriod = json['billing_period'];
    subscriptionId = json['subscriptionId'];
    stripeCustomerId = json['stripeCustomerId'];
    seats = json['seats'];
    userId = json['userId'];
    orderNumber = json['order_number'];
    additionalSeats = json['additional_seats'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
    additionalLocation = json['additional_location'];
    isBlocked = json['isBlocked'];
    isWarning = json['isWarning'];
    failedDate = json['failedDate'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['plan'] = plan;
    data['status'] = status;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['billing_period'] = billingPeriod;
    data['subscriptionId'] = subscriptionId;
    data['stripeCustomerId'] = stripeCustomerId;
    data['seats'] = seats;
    data['userId'] = userId;
    data['order_number'] = orderNumber;
    data['additional_seats'] = additionalSeats;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    data['additional_location'] = additionalLocation;
    data['isBlocked'] = isBlocked;
    data['isWarning'] = isWarning;
    data['failedDate'] = failedDate;
    data['id'] = id;
    return data;
  }
}

class JobRights {
  bool? creatingReceipts;
  bool? completingJob;
  bool? returnDevice;
  bool? updatingJob;
  bool? crossLocationJobAccess;

  JobRights({
    this.creatingReceipts,
    this.completingJob,
    this.returnDevice,
    this.updatingJob,
    this.crossLocationJobAccess,
  });

  JobRights.fromJson(Map<String, dynamic> json) {
    creatingReceipts = json['creating_receipts'];
    completingJob = json['completing_job'];
    returnDevice = json['return_device'];
    updatingJob = json['updating_job'];
    crossLocationJobAccess = json['cross_location_job_access'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['creating_receipts'] = creatingReceipts;
    data['completing_job'] = completingJob;
    data['return_device'] = returnDevice;
    data['updating_job'] = updatingJob;
    data['cross_location_job_access'] = crossLocationJobAccess;
    return data;
  }
}
