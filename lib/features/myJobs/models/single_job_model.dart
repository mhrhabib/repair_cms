class SingleJobModel {
  bool? success;
  Data? data;

  SingleJobModel({this.success, this.data});

  SingleJobModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? jobType;
  String? jobTypes;
  String? model;
  String? deviceId;
  String? jobContactId;
  String? defectId;
  dynamic subTotal;
  dynamic total;
  dynamic vat;
  dynamic discount;
  String? jobNo;
  bool? emailConfirmation;
  List<File>? files;
  String? printOption;
  bool? printDeviceLabel;
  List<JobStatus>? jobStatus;
  CustomerDetails? customerDetails;
  DeviceData? deviceData;
  String? status;
  String? location;
  String? salutationHTMLmarkup;
  String? termsAndConditionsHTMLmarkup;
  ReceiptFooter? receiptFooter;
  List<LoggedUser>? loggedUserId;
  String? userId;
  String? createdAt;
  String? updatedAt;
  String? jobTrackingNumber;
  String? physicalLocation;
  String? signatureFilePath;
  String? jobPriority;
  List<dynamic>? assignUser;
  String? dueDate;
  bool? isDeviceReturned;
  bool? isJobCompleted;
  List<dynamic>? assignedItems;
  List<dynamic>? services;
  List<Device>? device;
  List<Contact>? contact;
  List<Defect>? defect;
  List<UserData>? userData;

  Data({
    this.sId,
    this.jobType,
    this.jobTypes,
    this.model,
    this.deviceId,
    this.jobContactId,
    this.defectId,
    this.subTotal,
    this.total,
    this.vat,
    this.discount,
    this.jobNo,
    this.emailConfirmation,
    this.files,
    this.printOption,
    this.printDeviceLabel,
    this.jobStatus,
    this.customerDetails,
    this.deviceData,
    this.status,
    this.location,
    this.salutationHTMLmarkup,
    this.termsAndConditionsHTMLmarkup,
    this.receiptFooter,
    this.loggedUserId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.jobTrackingNumber,
    this.physicalLocation,
    this.signatureFilePath,
    this.jobPriority,
    this.assignUser,
    this.dueDate,
    this.isDeviceReturned,
    this.isJobCompleted = false,
    this.assignedItems,
    this.services,
    this.device,
    this.contact,
    this.defect,
    this.userData,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    jobType = json['jobType'];
    jobTypes = json['jobTypes'];
    model = json['model'];
    deviceId = json['deviceId'];
    jobContactId = json['jobContactId'];
    defectId = json['defectId'];
    subTotal = json['subTotal'];
    total = json['total'];
    vat = json['vat'];
    discount = json['discount'];
    jobNo = json['jobNo'];
    emailConfirmation = json['emailConfirmation'];
    if (json['files'] != null) {
      files = <File>[];
      json['files'].forEach((v) {
        files!.add(File.fromJson(v));
      });
    }
    printOption = json['printOption'];
    printDeviceLabel = json['printDeviceLabel'];
    if (json['jobStatus'] != null) {
      jobStatus = <JobStatus>[];
      json['jobStatus'].forEach((v) {
        jobStatus!.add(JobStatus.fromJson(v));
      });
    }
    customerDetails = json['customerDetails'] != null
        ? CustomerDetails.fromJson(json['customerDetails'])
        : null;
    deviceData = json['deviceData'] != null
        ? DeviceData.fromJson(json['deviceData'])
        : null;
    status = json['status'];
    location = json['location'];
    salutationHTMLmarkup = json['salutationHTMLmarkup'];
    termsAndConditionsHTMLmarkup = json['termsAndConditionsHTMLmarkup'];
    receiptFooter = json['receipt_footer'] != null
        ? ReceiptFooter.fromJson(json['receipt_footer'])
        : null;
    if (json['loggedUserId'] != null) {
      loggedUserId = <LoggedUser>[];
      json['loggedUserId'].forEach((v) {
        loggedUserId!.add(LoggedUser.fromJson(v));
      });
    }
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    jobTrackingNumber = json['job_tracking_number'];
    physicalLocation = json['physicalLocation'];
    signatureFilePath = json['signatureFilePath'];
    jobPriority = json['job_priority'];
    assignUser = json['assign_user'];
    dueDate = json['due_date'];
    isDeviceReturned = json['is_device_returned'];
    if (json['is_job_completed'] != null) {
      isJobCompleted = json['is_job_completed'];
    }
    assignedItems = json['assignedItems'];
    services = json['services'];
    if (json['device'] != null) {
      device = <Device>[];
      json['device'].forEach((v) {
        device!.add(Device.fromJson(v));
      });
    }
    if (json['contact'] != null) {
      contact = <Contact>[];
      json['contact'].forEach((v) {
        contact!.add(Contact.fromJson(v));
      });
    }
    if (json['defect'] != null) {
      defect = <Defect>[];
      json['defect'].forEach((v) {
        // Handle both string and map formats for backward compatibility
        if (v is Map<String, dynamic>) {
          defect!.add(Defect.fromJson(v));
        } else if (v is String) {
          // If it's a string, create a Defect with just the ID
          defect!.add(Defect(sId: v));
        }
      });
    }
    if (json['userData'] != null) {
      userData = <UserData>[];
      json['userData'].forEach((v) {
        userData!.add(UserData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['jobType'] = jobType;
    data['jobTypes'] = jobTypes;
    data['model'] = model;
    data['deviceId'] = deviceId;
    data['jobContactId'] = jobContactId;
    data['defectId'] = defectId;
    data['subTotal'] = subTotal;
    data['total'] = total;
    data['vat'] = vat;
    data['discount'] = discount;
    data['jobNo'] = jobNo;
    data['emailConfirmation'] = emailConfirmation;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    data['printOption'] = printOption;
    data['printDeviceLabel'] = printDeviceLabel;
    if (jobStatus != null) {
      data['jobStatus'] = jobStatus!.map((v) => v.toJson()).toList();
    }
    if (customerDetails != null) {
      data['customerDetails'] = customerDetails!.toJson();
    }
    if (deviceData != null) {
      data['deviceData'] = deviceData!.toJson();
    }
    data['status'] = status;
    data['location'] = location;
    data['salutationHTMLmarkup'] = salutationHTMLmarkup;
    data['termsAndConditionsHTMLmarkup'] = termsAndConditionsHTMLmarkup;
    if (receiptFooter != null) {
      data['receipt_footer'] = receiptFooter!.toJson();
    }
    if (loggedUserId != null) {
      data['loggedUserId'] = loggedUserId!.map((v) => v.toJson()).toList();
    }
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['job_tracking_number'] = jobTrackingNumber;
    data['physicalLocation'] = physicalLocation;
    data['signatureFilePath'] = signatureFilePath;
    data['job_priority'] = jobPriority;
    data['assign_user'] = assignUser;
    data['due_date'] = dueDate;
    data['is_device_returned'] = isDeviceReturned;
    if (isJobCompleted != null) {
      data['is_job_completed'] = isJobCompleted;
    }
    data['assignedItems'] = assignedItems;
    data['services'] = services;
    if (device != null) {
      data['device'] = device!.map((v) => v.toJson()).toList();
    }
    if (contact != null) {
      data['contact'] = contact!.map((v) => v.toJson()).toList();
    }
    if (defect != null) {
      data['defect'] = defect!.map((v) => v.toJson()).toList();
    }
    if (userData != null) {
      data['userData'] = userData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class File {
  String? file;
  String? id;
  String? fileName;
  int? size;
  String? url;

  File({this.file, this.id, this.fileName, this.size});

  File.fromJson(Map<String, dynamic> json) {
    if (json['file'] != null) {
      file = json['file'];
    }
    url = json['url'];
    id = json['id'];
    fileName = json['fileName'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (file != null) {
      data['file'] = file;
    }
    data['id'] = id;
    data['fileName'] = fileName;
    data['size'] = size;
    data['url'] = url;
    return data;
  }

  // Getter to construct full image URL
  String? get imageUrl {
    // Priority 1: Use the S3 signed URL if available
    if (url != null && url!.isNotEmpty) {
      return url;
    }

    // Priority 2: If file path is null, return null
    if (file == null) return null;

    // Priority 3: If the file path is already a complete URL, return it as is
    if (file!.startsWith('http://') || file!.startsWith('https://')) {
      return file;
    }

    // Priority 4: Construct the API URL to get signed URL
    return 'https://api.repaircms.com/file-upload/images?imagePath=$file';
  }
}

class JobStatus {
  String? title;
  String? userId;
  String? colorCode;
  String? userName;
  int? createAtStatus;
  dynamic notifications;
  dynamic email;
  String? notes;
  dynamic priority; // Can be String or int

  JobStatus({
    this.title,
    this.userId,
    this.colorCode,
    this.userName,
    this.createAtStatus,
    this.notifications,
    this.email,
    this.notes,
    this.priority,
  });

  JobStatus.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    userId = json['userId'];
    colorCode = json['colorCode'];
    userName = json['userName'];
    createAtStatus = json['createAtStatus'];
    notifications = json['notifications'];
    email = json['email'];
    notes = json['notes'];
    priority = json['priority'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['userId'] = userId;
    data['colorCode'] = colorCode;
    data['userName'] = userName;
    data['createAtStatus'] = createAtStatus;
    data['notifications'] = notifications;
    data['email'] = email;
    data['notes'] = notes;
    data['priority'] = priority;
    return data;
  }
}

class CustomerDetails {
  String? customerId;
  String? organization;
  String? supplierName;
  String? salutation;
  String? title;
  String? customerNo;
  String? firstName;
  String? lastName;
  String? position;
  String? type;
  String? type2;
  String? email;
  String? telephone;
  String? telephonePrefix;
  BillingAddress? billingAddress;
  ShippingAddress? shippingAddress;
  String? vatNo;
  bool? reverseCharge;

  CustomerDetails({
    this.customerId,
    this.organization,
    this.supplierName,
    this.salutation,
    this.title,
    this.customerNo,
    this.firstName,
    this.lastName,
    this.position,
    this.type,
    this.type2,
    this.email,
    this.telephone,
    this.telephonePrefix,
    this.billingAddress,
    this.shippingAddress,
    this.vatNo,
    this.reverseCharge,
  });

  CustomerDetails.fromJson(Map<String, dynamic> json) {
    customerId = json['customerId'];
    organization = json['organization'];
    supplierName = json['supplierName'];
    salutation = json['salutation'];
    title = json['title'];
    customerNo = json['customerNo'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    position = json['position'];
    type = json['type'];
    type2 = json['type2'];
    email = json['email'];
    telephone = json['telephone'];
    telephonePrefix = json['telephone_prefix'];
    billingAddress = json['billing_address'] != null
        ? BillingAddress.fromJson(json['billing_address'])
        : null;
    shippingAddress = json['shipping_address'] != null
        ? ShippingAddress.fromJson(json['shipping_address'])
        : null;
    vatNo = json['vatNo'];
    reverseCharge = json['reverseCharge'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customerId'] = customerId;
    data['organization'] = organization;
    data['supplierName'] = supplierName;
    data['salutation'] = salutation;
    data['title'] = title;
    data['customerNo'] = customerNo;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['position'] = position;
    data['type'] = type;
    data['type2'] = type2;
    data['email'] = email;
    data['telephone'] = telephone;
    data['telephone_prefix'] = telephonePrefix;
    if (billingAddress != null) {
      data['billing_address'] = billingAddress!.toJson();
    }
    if (shippingAddress != null) {
      data['shipping_address'] = shippingAddress!.toJson();
    }
    data['vatNo'] = vatNo;
    data['reverseCharge'] = reverseCharge;
    return data;
  }
}

class BillingAddress {
  String? sId;
  bool? primary;
  String? street;
  String? zip;
  String? city;
  String? country;
  String? customerId;
  int? iV;
  String? state;

  BillingAddress({
    this.sId,
    this.primary,
    this.street,
    this.zip,
    this.city,
    this.country,
    this.customerId,
    this.iV,
    this.state,
  });

  BillingAddress.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    primary = json['primary'];
    street = json['street'];
    zip = json['zip'];
    city = json['city'];
    country = json['country'];
    customerId = json['customerId'];
    iV = json['__v'];
    state = json['state'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['primary'] = primary;
    data['street'] = street;
    data['zip'] = zip;
    data['city'] = city;
    data['country'] = country;
    data['customerId'] = customerId;
    data['__v'] = iV;
    data['state'] = state;
    return data;
  }
}

class ShippingAddress {
  String? sId;
  String? street;
  String? zip;
  String? city;
  String? country;
  bool? primary;
  String? customerId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  ShippingAddress({
    this.sId,
    this.street,
    this.zip,
    this.city,
    this.country,
    this.primary,
    this.customerId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    street = json['street'];
    zip = json['zip'];
    city = json['city'];
    country = json['country'];
    primary = json['primary'];
    customerId = json['customerId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['street'] = street;
    data['zip'] = zip;
    data['city'] = city;
    data['country'] = country;
    data['primary'] = primary;
    data['customerId'] = customerId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class DeviceData {
  String? brand;
  String? brandId;
  String? model;
  String? type;
  List<Condition>? condition;
  String? serialNo;

  DeviceData({
    this.brand,
    this.brandId,
    this.model,
    this.type,
    this.condition,
    this.serialNo,
  });

  DeviceData.fromJson(Map<String, dynamic> json) {
    brand = json['brand'];
    brandId = json['brandId'];
    model = json['model'];
    type = json['type'];
    if (json['condition'] != null) {
      condition = <Condition>[];
      json['condition'].forEach((v) {
        // Handle both string and map formats for backward compatibility
        if (v is Map<String, dynamic>) {
          condition!.add(Condition.fromJson(v));
        } else if (v is String) {
          // If it's a string, create a Condition with the value
          condition!.add(Condition(value: v));
        }
      });
    }
    serialNo = json['serial_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['brand'] = brand;
    data['brandId'] = brandId;
    data['model'] = model;
    data['type'] = type;
    if (condition != null) {
      data['condition'] = condition!.map((v) => v.toJson()).toList();
    }
    data['serial_no'] = serialNo;
    return data;
  }
}

class Condition {
  String? value;
  String? id;

  Condition({this.value, this.id});

  Condition.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['id'] = id;
    return data;
  }
}

class ReceiptFooter {
  String? companyLogo;
  String? companyLogoURL;
  Address? address;
  ContactInfo? contact;
  Bank? bank;
  String? openingHours;

  ReceiptFooter({
    this.companyLogo,
    this.companyLogoURL,
    this.address,
    this.contact,
    this.bank,
    this.openingHours,
  });

  ReceiptFooter.fromJson(Map<String, dynamic> json) {
    companyLogo = json['companyLogo'];
    companyLogoURL = json['companyLogoURL'];
    address = json['address'] != null
        ? Address.fromJson(json['address'])
        : null;
    contact = json['contact'] != null
        ? ContactInfo.fromJson(json['contact'])
        : null;
    bank = json['bank'] != null ? Bank.fromJson(json['bank']) : null;
    openingHours = json['openingHours'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['companyLogo'] = companyLogo;
    data['companyLogoURL'] = companyLogoURL;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    if (contact != null) {
      data['contact'] = contact!.toJson();
    }
    if (bank != null) {
      data['bank'] = bank!.toJson();
    }
    data['openingHours'] = openingHours;
    return data;
  }
}

class Address {
  String? companyName;
  String? street;
  String? num;
  String? zip;
  String? city;
  String? country;

  Address({
    this.companyName,
    this.street,
    this.num,
    this.zip,
    this.city,
    this.country,
  });

  Address.fromJson(Map<String, dynamic> json) {
    companyName = json['companyName'];
    street = json['street'];
    num = json['num'];
    zip = json['zip'];
    city = json['city'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['companyName'] = companyName;
    data['street'] = street;
    data['num'] = num;
    data['zip'] = zip;
    data['city'] = city;
    data['country'] = country;
    return data;
  }
}

class ContactInfo {
  String? ceo;
  String? telephone;
  String? email;
  String? website;

  ContactInfo({this.ceo, this.telephone, this.email, this.website});

  ContactInfo.fromJson(Map<String, dynamic> json) {
    ceo = json['ceo'];
    telephone = json['telephone'];
    email = json['email'];
    website = json['website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ceo'] = ceo;
    data['telephone'] = telephone;
    data['email'] = email;
    data['website'] = website;
    return data;
  }
}

class Bank {
  String? bankName;
  String? iban;
  String? bic;

  Bank({this.bankName, this.iban, this.bic});

  Bank.fromJson(Map<String, dynamic> json) {
    bankName = json['bankName'];
    iban = json['iban'];
    bic = json['bic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bankName'] = bankName;
    data['iban'] = iban;
    data['bic'] = bic;
    return data;
  }
}

class LoggedUser {
  String? email;
  String? fullName;

  LoggedUser({this.email, this.fullName});

  LoggedUser.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    fullName = json['fullName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['fullName'] = fullName;
    return data;
  }
}

class UserData {
  String? email;
  String? fullName;
  String? avatar;
  String? position;
  Currency? currency;
  DateFormat? dateFormat;

  UserData({
    this.email,
    this.fullName,
    this.avatar,
    this.position,
    this.currency,
    this.dateFormat,
  });

  UserData.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    fullName = json['fullName'];
    avatar = json['avatar'];
    position = json['position'];
    currency = json['currency'] != null
        ? Currency.fromJson(json['currency'])
        : null;
    dateFormat = json['dateFormat'] != null
        ? DateFormat.fromJson(json['dateFormat'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['fullName'] = fullName;
    data['avatar'] = avatar;
    data['position'] = position;
    if (currency != null) {
      data['currency'] = currency!.toJson();
    }
    if (dateFormat != null) {
      data['dateFormat'] = dateFormat!.toJson();
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
    final Map<String, dynamic> data = <String, dynamic>{};
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['name'] = name;
    data['format'] = format;
    return data;
  }
}

// Updated Device class to match your JSON structure
class Device {
  String? sId;
  String? brand;
  String? brandId;
  String? model;
  List<Condition>? condition;
  List<dynamic>? accessories;
  List<dynamic>? securityLock;
  String? serialNo;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Device({
    this.sId,
    this.brand,
    this.brandId,
    this.model,
    this.condition,
    this.accessories,
    this.securityLock,
    this.serialNo,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Device.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    brand = json['brand'];
    brandId = json['brandId'];
    model = json['model'];
    if (json['condition'] != null) {
      condition = <Condition>[];
      json['condition'].forEach((v) {
        // Handle both string and map formats for backward compatibility
        if (v is Map<String, dynamic>) {
          condition!.add(Condition.fromJson(v));
        } else if (v is String) {
          // If it's a string, create a Condition with the value
          condition!.add(Condition(value: v));
        }
      });
    }
    accessories = json['accessories'];
    securityLock = json['securityLock'];
    serialNo = json['serial_no'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['brand'] = brand;
    data['brandId'] = brandId;
    data['model'] = model;
    if (condition != null) {
      data['condition'] = condition!.map((v) => v.toJson()).toList();
    }
    data['accessories'] = accessories;
    data['securityLock'] = securityLock;
    data['serial_no'] = serialNo;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

// Updated Contact class to match your JSON structure
class Contact {
  String? sId;
  String? type;
  String? type2;
  String? salutation;
  String? firstName;
  String? lastName;
  String? telephone;
  String? email;
  String? customerId;
  String? organization;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Contact({
    this.sId,
    this.type,
    this.type2,
    this.salutation,
    this.firstName,
    this.lastName,
    this.telephone,
    this.email,
    this.customerId,
    this.organization,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Contact.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    type2 = json['type2'];
    salutation = json['salutation'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    telephone = json['telephone'];
    email = json['email'];
    customerId = json['customerId'];
    organization = json['organization'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['type2'] = type2;
    data['salutation'] = salutation;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['telephone'] = telephone;
    data['email'] = email;
    data['customerId'] = customerId;
    data['organization'] = organization;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

// Updated Defect class to match your JSON structure
class Defect {
  String? sId;
  List<DefectItem>? defect;
  String? jobType;
  String? reference;
  String? description;
  List<InternalNote>? internalNote;
  List<dynamic>? assignItems;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Defect({
    this.sId,
    this.defect,
    this.jobType,
    this.reference,
    this.description,
    this.internalNote,
    this.assignItems,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Defect.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['defect'] != null) {
      defect = <DefectItem>[];
      json['defect'].forEach((v) {
        // Handle both string and map formats for backward compatibility
        if (v is Map<String, dynamic>) {
          defect!.add(DefectItem.fromJson(v));
        } else if (v is String) {
          // If it's a string, create a DefectItem with the value
          defect!.add(DefectItem(value: v));
        }
      });
    }
    jobType = json['jobType'];
    reference = json['reference'];
    description = json['description'];
    if (json['internalNote'] != null) {
      internalNote = <InternalNote>[];
      if (json['internalNote'] is List) {
        for (var v in json['internalNote']) {
          if (v is Map<String, dynamic>) {
            internalNote!.add(InternalNote.fromJson(v));
          } else if (v is String) {
            internalNote!.add(InternalNote(text: v, userName: 'System'));
          }
        }
      }
    }
    assignItems = json['assignItems'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (defect != null) {
      data['defect'] = defect!.map((v) => v.toJson()).toList();
    }
    data['jobType'] = jobType;
    data['reference'] = reference;
    data['description'] = description;
    if (internalNote != null) {
      data['internalNote'] = internalNote!.map((v) => v.toJson()).toList();
    }
    data['assignItems'] = assignItems;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class DefectItem {
  String? value;
  String? id;

  DefectItem({this.value, this.id});

  DefectItem.fromJson(Map<String, dynamic> json) {
    value = json['value'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['value'] = value;
    data['id'] = id;
    return data;
  }
}

class InternalNote {
  String? text;
  String? userId;
  dynamic createdAt;
  String? userName;
  String? id;

  InternalNote({
    this.text,
    this.userId,
    this.createdAt,
    this.userName,
    this.id,
  });

  InternalNote.fromJson(Map<String, dynamic> json) {
    text = json['text'] is List
        ? json['text'].isEmpty
              ? ''
              : json['text'][0] ?? ''
        : json['text'] ?? '';
    userId = json['userId'];
    createdAt = json['createdAt'];
    userName = json['userName'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['userName'] = userName;
    data['id'] = id;
    return data;
  }
}
