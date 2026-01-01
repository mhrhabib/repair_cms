import 'package:repair_cms/core/app_exports.dart';

class JobListResponse {
  final bool success;
  final List<Job> jobs;
  final int currentTotalJobs;
  final int pages;
  final int totalJobs;
  final int serviceRequestJobs;
  final int inProgressJobs;
  final int readyToReturnJobs;
  final int acceptedQuoetsJobs;
  final int rejectQuoetsJobs;
  final int partsNotAvailableJobs;
  final int totalServiceRequestArchive;

  JobListResponse({
    required this.success,
    required this.jobs,
    required this.currentTotalJobs,
    required this.pages,
    required this.totalJobs,
    required this.serviceRequestJobs,
    required this.inProgressJobs,
    required this.readyToReturnJobs,
    required this.acceptedQuoetsJobs,
    required this.rejectQuoetsJobs,
    required this.partsNotAvailableJobs,
    required this.totalServiceRequestArchive,
  });

  factory JobListResponse.fromJson(Map<String, dynamic> json) {
    return JobListResponse(
      success: json['success'] ?? false,
      jobs: (json['jobs'] as List<dynamic>?)?.map((job) => Job.fromJson(job)).toList() ?? [],
      currentTotalJobs: json['currentTotalJobs'] ?? 0,
      pages: json['pages'] ?? 0,
      totalJobs: json['totalJobs'] ?? 0,
      serviceRequestJobs: json['serviceRequestJobs'] ?? 0,
      inProgressJobs: json['inProgressJobs'] ?? 0,
      readyToReturnJobs: json['readyToReturnJobs'] ?? 0,
      acceptedQuoetsJobs: json['acceptedQuoetsJobs'] ?? 0,
      rejectQuoetsJobs: json['rejectQuoetsJobs'] ?? 0,
      partsNotAvailableJobs: json['partsNotAvailableJobs'] ?? 0,
      totalServiceRequestArchive: json['totalServiceRequestArchive'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'jobs': jobs.map((job) => job.toJson()).toList(),
      'currentTotalJobs': currentTotalJobs,
      'pages': pages,
      'totalJobs': totalJobs,
      'serviceRequestJobs': serviceRequestJobs,
      'inProgressJobs': inProgressJobs,
      'readyToReturnJobs': readyToReturnJobs,
      'acceptedQuoetsJobs': acceptedQuoetsJobs,
      'rejectQuoetsJobs': rejectQuoetsJobs,
      'partsNotAvailableJobs': partsNotAvailableJobs,
      'totalServiceRequestArchive': totalServiceRequestArchive,
    };
  }
}

class Job {
  final String id;
  final String jobType;
  final String jobTypes;
  final String? model;
  final List<String> servicesIds;
  final String deviceId;
  final String jobContactId;
  final String defectId;
  final dynamic subTotal;
  final dynamic total;
  final dynamic vat;
  final dynamic discount;
  final String jobNo;
  final String customerId;
  final List<String> assignedItemsIds;
  final bool emailConfirmation;
  final List<JobFile> files;
  final String printOption;
  final bool printDeviceLabel;
  final List<JobStatus> jobStatus;
  final CustomerDetails customerDetails;
  final DeviceData deviceData;
  final String status;
  final String assignerName;
  final String location;
  final String salutationHTMLmarkup;
  final String termsAndConditionsHTMLmarkup;
  final ReceiptFooter receiptFooter;
  final List<LoggedUser> loggedUserId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String jobTrackingNumber;
  final String physicalLocation;
  final String? signatureFilePath;
  final String? jobPriority;
  final List<dynamic> assignUser;
  final DateTime? dueDate;
  final String? lastReminderSent;
  final bool? isDeviceReturned;
  final bool? isJobCompleted;
  final int? prioritySort;
  final List<Service> services;
  final List<AssignedItem> assignedItems;
  final List<Device> device;
  final List<Contact> contact;
  final List<Defect> defect;
  final List<UserData> userData;
  final List<LocationData> locationData;
  final String? b2bpartnerId;
  final String? jobSource;

  Job({
    required this.id,
    required this.jobType,
    required this.jobTypes,
    this.model,
    required this.servicesIds,
    required this.deviceId,
    required this.jobContactId,
    required this.defectId,
    required this.subTotal,
    required this.total,
    required this.vat,
    required this.discount,
    required this.jobNo,
    required this.customerId,
    required this.assignedItemsIds,
    required this.emailConfirmation,
    required this.files,
    required this.printOption,
    required this.printDeviceLabel,
    required this.jobStatus,
    required this.customerDetails,
    required this.deviceData,
    required this.status,
    required this.assignerName,
    required this.location,
    required this.salutationHTMLmarkup,
    required this.termsAndConditionsHTMLmarkup,
    required this.receiptFooter,
    required this.loggedUserId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.jobTrackingNumber,
    required this.physicalLocation,
    this.signatureFilePath,
    this.jobPriority,
    required this.assignUser,
    this.dueDate,
    this.lastReminderSent,
    this.isDeviceReturned,
    this.isJobCompleted,
    this.prioritySort,
    required this.services,
    required this.assignedItems,
    required this.device,
    required this.contact,
    required this.defect,
    required this.userData,
    required this.locationData,
    this.b2bpartnerId,
    this.jobSource,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? '',
      jobType: json['jobType'] ?? '',
      jobTypes: json['jobTypes'] ?? '',
      model: json['model'],
      servicesIds: List<String>.from(json['servicesIds'] ?? []),
      deviceId: json['deviceId'] ?? '',
      jobContactId: json['jobContactId'] ?? '',
      defectId: json['defectId'] ?? '',
      subTotal: (json['subTotal'] ?? 0),
      total: (json['total'] ?? 0),
      vat: (json['vat'] ?? 0),
      discount: (json['discount'] ?? 0),
      jobNo: json['jobNo'] ?? '',
      customerId: json['customerId'] ?? '',
      assignedItemsIds: List<String>.from(json['assignedItemsIds'] ?? []),
      emailConfirmation: json['emailConfirmation'] ?? false,
      files: (json['files'] as List<dynamic>?)?.map((file) => JobFile.fromJson(file)).toList() ?? [],
      printOption: json['printOption'] ?? '',
      printDeviceLabel: json['printDeviceLabel'] ?? false,
      jobStatus: (json['jobStatus'] as List<dynamic>?)?.map((status) => JobStatus.fromJson(status)).toList() ?? [],
      customerDetails: CustomerDetails.fromJson(json['customerDetails'] ?? {}),
      deviceData: DeviceData.fromJson(json['deviceData'] ?? {}),
      status: json['status'] ?? '',
      assignerName: json['assigner_name'] ?? '',
      location: json['location'] ?? '',
      salutationHTMLmarkup: json['salutationHTMLmarkup'] ?? '',
      termsAndConditionsHTMLmarkup: json['termsAndConditionsHTMLmarkup'] ?? '',
      receiptFooter: ReceiptFooter.fromJson(json['receipt_footer'] ?? {}),
      loggedUserId: (json['loggedUserId'] as List<dynamic>?)?.map((user) => LoggedUser.fromJson(user)).toList() ?? [],
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? '2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse(json['updatedAt'] ?? '2023-01-01T00:00:00.000Z'),
      version: json['__v'] ?? 0,
      jobTrackingNumber: json['job_tracking_number'] ?? '',
      physicalLocation: json['physicalLocation'] ?? '',
      signatureFilePath: json['signatureFilePath'],
      jobPriority: json['job_priority'],
      assignUser: json['assign_user'] ?? [],
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      lastReminderSent: json['lastReminderSent'],
      isDeviceReturned: json['is_device_returned'],
      isJobCompleted: json['is_job_completed'],
      prioritySort: json['prioritySort'],
      services: (json['services'] as List<dynamic>?)?.map((service) => Service.fromJson(service)).toList() ?? [],
      assignedItems:
          (json['assignedItems'] as List<dynamic>?)?.map((item) => AssignedItem.fromJson(item)).toList() ?? [],
      device: (json['device'] as List<dynamic>?)?.map((device) => Device.fromJson(device)).toList() ?? [],
      contact: (json['contact'] as List<dynamic>?)?.map((contact) => Contact.fromJson(contact)).toList() ?? [],
      defect: (json['defect'] as List<dynamic>?)?.map((defect) => Defect.fromJson(defect)).toList() ?? [],
      userData: (json['userData'] as List<dynamic>?)?.map((user) => UserData.fromJson(user)).toList() ?? [],
      locationData:
          (json['locationData'] as List<dynamic>?)?.map((location) => LocationData.fromJson(location)).toList() ?? [],
      b2bpartnerId: json['b2bpartnerId'],
      jobSource: json['jobSource'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'jobType': jobType,
      'jobTypes': jobTypes,
      'model': model,
      'servicesIds': servicesIds,
      'deviceId': deviceId,
      'jobContactId': jobContactId,
      'defectId': defectId,
      'subTotal': subTotal,
      'total': total,
      'vat': vat,
      'discount': discount,
      'jobNo': jobNo,
      'customerId': customerId,
      'assignedItemsIds': assignedItemsIds,
      'emailConfirmation': emailConfirmation,
      'files': files.map((file) => file.toJson()).toList(),
      'printOption': printOption,
      'printDeviceLabel': printDeviceLabel,
      'jobStatus': jobStatus.map((status) => status.toJson()).toList(),
      'customerDetails': customerDetails.toJson(),
      'deviceData': deviceData.toJson(),
      'status': status,
      'assigner_name': assignerName,
      'location': location,
      'salutationHTMLmarkup': salutationHTMLmarkup,
      'termsAndConditionsHTMLmarkup': termsAndConditionsHTMLmarkup,
      'receipt_footer': receiptFooter.toJson(),
      'loggedUserId': loggedUserId.map((user) => user.toJson()).toList(),
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'job_tracking_number': jobTrackingNumber,
      'physicalLocation': physicalLocation,
      'signatureFilePath': signatureFilePath,
      'job_priority': jobPriority,
      'assign_user': assignUser,
      'due_date': dueDate?.toIso8601String(),
      'lastReminderSent': lastReminderSent,
      'is_device_returned': isDeviceReturned,
      'is_job_completed': isJobCompleted,
      'prioritySort': prioritySort,
      'services': services.map((service) => service.toJson()).toList(),
      'assignedItems': assignedItems.map((item) => item.toJson()).toList(),
      'device': device.map((device) => device.toJson()).toList(),
      'contact': contact.map((contact) => contact.toJson()).toList(),
      'defect': defect.map((defect) => defect.toJson()).toList(),
      'userData': userData.map((user) => user.toJson()).toList(),
      'locationData': locationData.map((location) => location.toJson()).toList(),
      'b2bpartnerId': b2bpartnerId,
      'jobSource': jobSource,
    };
  }
}

class JobFile {
  final dynamic file;
  final String id;
  final String fileName;
  final int size;
  final String? url;

  JobFile({required this.file, required this.id, required this.fileName, required this.size, this.url});

  factory JobFile.fromJson(Map<String, dynamic> json) {
    return JobFile(
      file: json['file'] ?? '',
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      size: json['size'] ?? 0,
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'file': file, 'id': id, 'fileName': fileName, 'size': size, 'url': url};
  }

  /// Get the full image URL for displaying the file
  /// Priority: S3 signed URL > file path > constructed API URL
  String get imageUrl {
    // Priority 1: Use the S3 signed URL if available
    if (url != null && url!.isNotEmpty) {
      return url!;
    }

    // Priority 2: If file is null or empty, return empty string
    if (file == null || file.toString().isEmpty) return '';

    // Priority 3: If file already contains full URL, return it
    if (file.toString().startsWith('http://') || file.toString().startsWith('https://')) {
      return file.toString();
    }

    // Priority 4: Construct the API URL to get signed URL
    const baseImageUrl = 'https://api.repaircms.com/file-upload/images?imagePath=';
    return baseImageUrl + file.toString();
  }
}

class JobStatus {
  final String title;
  final String userId;
  final String colorCode;
  final String userName;
  final int createAtStatus;
  final bool notifications;
  final String email;
  final String notes;
  final dynamic priority;

  JobStatus({
    required this.title,
    required this.userId,
    required this.colorCode,
    required this.userName,
    required this.createAtStatus,
    required this.notifications,
    required this.email,
    required this.notes,
    required this.priority,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) {
    return JobStatus(
      title: json['title'] ?? '',
      userId: json['userId'] ?? '',
      colorCode: json['colorCode'] ?? '',
      userName: json['userName'] ?? '',
      createAtStatus: json['createAtStatus'] ?? 0,
      notifications: json['notifications'] ?? false,
      email: json['email'] ?? '',
      notes: json['notes'] ?? '',
      priority: json['priority'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'userId': userId,
      'colorCode': colorCode,
      'userName': userName,
      'createAtStatus': createAtStatus,
      'notifications': notifications,
      'email': email,
      'notes': notes,
      'priority': priority,
    };
  }
}

class CustomerDetails {
  final String customerId;
  final String organization;
  final String supplierName;
  final String salutation;
  final String title;
  final String customerNo;
  final String firstName;
  final String lastName;
  final String position;
  final String type;
  final String type2;
  final String email;
  final String telephone;
  final String telephonePrefix;
  final Address billingAddress;
  final Address shippingAddress;
  final String vatNo;
  final bool reverseCharge;
  final List<ContactPerson>? contactPersons;

  CustomerDetails({
    required this.customerId,
    required this.organization,
    required this.supplierName,
    required this.salutation,
    required this.title,
    required this.customerNo,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.type,
    required this.type2,
    required this.email,
    required this.telephone,
    required this.telephonePrefix,
    required this.billingAddress,
    required this.shippingAddress,
    required this.vatNo,
    required this.reverseCharge,
    this.contactPersons,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      customerId: json['customerId'] ?? '',
      organization: json['organization'] ?? '',
      supplierName: json['supplierName'] ?? '',
      salutation: json['salutation'] ?? '',
      title: json['title'] ?? '',
      customerNo: json['customerNo'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      position: json['position'] ?? '',
      type: json['type'] ?? '',
      type2: json['type2'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      telephonePrefix: json['telephone_prefix'] ?? '',
      billingAddress: Address.fromJson(json['billing_address'] ?? {}),
      shippingAddress: Address.fromJson(json['shipping_address'] ?? {}),
      vatNo: json['vatNo'] ?? '',
      reverseCharge: json['reverseCharge'] ?? false,
      contactPersons: (json['contact_persons'] as List<dynamic>?)
          ?.map((person) => ContactPerson.fromJson(person))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'organization': organization,
      'supplierName': supplierName,
      'salutation': salutation,
      'title': title,
      'customerNo': customerNo,
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'type': type,
      'type2': type2,
      'email': email,
      'telephone': telephone,
      'telephone_prefix': telephonePrefix,
      'billing_address': billingAddress.toJson(),
      'shipping_address': shippingAddress.toJson(),
      'vatNo': vatNo,
      'reverseCharge': reverseCharge,
      'contact_persons': contactPersons?.map((person) => person.toJson()).toList(),
    };
  }
}

class Address {
  final String id;
  final bool primary;
  final String street;
  final String zip;
  final String city;
  final String country;
  final String customerId;
  final int version;
  final String? state;
  final String? num;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    required this.id,
    required this.primary,
    required this.street,
    required this.zip,
    required this.city,
    required this.country,
    required this.customerId,
    required this.version,
    this.state,
    this.num,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? '',
      primary: json['primary'] ?? false,
      street: json['street'] ?? '',
      zip: json['zip'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      customerId: json['customerId'] ?? '',
      version: json['__v'] ?? 0,
      state: json['state'],
      num: json['num'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.parse('2023-01-01T00:00:00.000Z'),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'primary': primary,
      'street': street,
      'zip': zip,
      'city': city,
      'country': country,
      'customerId': customerId,
      '__v': version,
      'state': state,
      'num': num,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ContactPerson {
  final String salutation;
  final String firstName;
  final String lastName;
  final String position;
  final String email;
  final String telephone;

  ContactPerson({
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.email,
    required this.telephone,
  });

  factory ContactPerson.fromJson(Map<String, dynamic> json) {
    return ContactPerson(
      salutation: json['salutation'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      position: json['position'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'email': email,
      'telephone': telephone,
    };
  }
}

class DeviceData {
  final String? brand;
  final String? brandId;
  final String? model;
  final String? type;
  final List<Condition> condition;
  final String? serialNo;
  final String? category;
  final String? imei;
  final String? deviceSecurity;
  final String? length;

  DeviceData({
    this.brand,
    this.brandId,
    this.model,
    this.type,
    required this.condition,
    this.serialNo,
    this.category,
    this.imei,
    this.deviceSecurity,
    this.length,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      brand: json['brand'],
      brandId: json['brandId'],
      model: json['model'],
      type: json['type'],
      condition: (json['condition'] as List<dynamic>?)?.map((cond) => Condition.fromJson(cond)).toList() ?? [],
      serialNo: json['serial_no'],
      category: json['category'],
      imei: json['imei'],
      deviceSecurity: json['deviceSecurity'],
      length: json['Length'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'brandId': brandId,
      'model': model,
      'type': type,
      'condition': condition.map((cond) => cond.toJson()).toList(),
      'serial_no': serialNo,
      'category': category,
      'imei': imei,
      'deviceSecurity': deviceSecurity,
      'Length': length,
    };
  }
}

class Condition {
  final String value;
  final String id;
  final String? label;
  final bool? isAdmin;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  Condition({
    required this.value,
    required this.id,
    this.label,
    this.isAdmin,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      value: json['value'] ?? '',
      id: json['id'] ?? json['_id'] ?? '',
      label: json['label'],
      isAdmin: json['isAdmin'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'id': id,
      'label': label,
      'isAdmin': isAdmin,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

class ReceiptFooter {
  final String companyLogo;
  final String companyLogoURL;
  final ReceiptAddress address;
  final ReceiptContact contact;
  final BankDetails bank;

  ReceiptFooter({
    required this.companyLogo,
    required this.companyLogoURL,
    required this.address,
    required this.contact,
    required this.bank,
  });

  factory ReceiptFooter.fromJson(Map<String, dynamic> json) {
    return ReceiptFooter(
      companyLogo: json['companyLogo'] ?? '',
      companyLogoURL: json['companyLogoURL'] ?? '',
      address: ReceiptAddress.fromJson(json['address'] ?? {}),
      contact: ReceiptContact.fromJson(json['contact'] ?? {}),
      bank: BankDetails.fromJson(json['bank'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyLogo': companyLogo,
      'companyLogoURL': companyLogoURL,
      'address': address.toJson(),
      'contact': contact.toJson(),
      'bank': bank.toJson(),
    };
  }
}

class ReceiptAddress {
  final String companyName;
  final String street;
  final String num;
  final String zip;
  final String city;
  final String country;
  final String? id;
  final String? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;
  final String? organization;

  ReceiptAddress({
    required this.companyName,
    required this.street,
    required this.num,
    required this.zip,
    required this.city,
    required this.country,
    this.id,
    this.companyId,
    this.createdAt,
    this.updatedAt,
    this.version,
    this.organization,
  });

  factory ReceiptAddress.fromJson(Map<String, dynamic> json) {
    return ReceiptAddress(
      companyName: json['companyName'] ?? '',
      street: json['street'] ?? '',
      num: json['num'] ?? '',
      zip: json['zip'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      id: json['_id'],
      companyId: json['companyId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['__v'],
      organization: json['organization'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyName': companyName,
      'street': street,
      'num': num,
      'zip': zip,
      'city': city,
      'country': country,
      '_id': id,
      'companyId': companyId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
      'organization': organization,
    };
  }
}

class ReceiptContact {
  final String ceo;
  final String telephone;
  final String email;
  final String website;
  final String? id;
  final String? fax;
  final String? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  ReceiptContact({
    required this.ceo,
    required this.telephone,
    required this.email,
    required this.website,
    this.id,
    this.fax,
    this.companyId,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory ReceiptContact.fromJson(Map<String, dynamic> json) {
    return ReceiptContact(
      ceo: json['ceo'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      id: json['_id'],
      fax: json['fax'],
      companyId: json['companyId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ceo': ceo,
      'telephone': telephone,
      'email': email,
      'website': website,
      '_id': id,
      'fax': fax,
      'companyId': companyId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

class BankDetails {
  final String bankName;
  final String iban;
  final String bic;
  final String? id;
  final String? companyId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  BankDetails({
    required this.bankName,
    required this.iban,
    required this.bic,
    this.id,
    this.companyId,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bankName'] ?? '',
      iban: json['iban'] ?? '',
      bic: json['bic'] ?? '',
      id: json['_id'],
      companyId: json['companyId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'iban': iban,
      'bic': bic,
      '_id': id,
      'companyId': companyId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

class LoggedUser {
  final String id;
  final String email;
  final String fullName;

  LoggedUser({required this.id, required this.email, required this.fullName});

  factory LoggedUser.fromJson(Map<String, dynamic> json) {
    return LoggedUser(id: json['_id'] ?? '', email: json['email'] ?? '', fullName: json['fullName'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'email': email, 'fullName': fullName};
  }
}

class Service {
  final String id;
  final String serviceId;
  final String name;
  final String category;
  final String model;
  final String manufacturer;
  final dynamic vat;
  final dynamic priceInclVat;
  final dynamic priceExclVat;
  final dynamic partCostExclVat;
  final dynamic partCostInclVat;
  final bool enableDeviceDetails;
  final bool enableSearchInExpress;
  final String userId;
  final String location;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final List<ServiceImage>? images;
  final List<dynamic>? assignedItems;
  final List<String>? assignedItemIds;
  final double? laborRate;
  final double? profitMarkup;
  final int? serviceTimeInMinutes;
  final bool? enableServiceDetails;
  final bool? labourCalculator;

  Service({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.category,
    required this.model,
    required this.manufacturer,
    required this.vat,
    required this.priceInclVat,
    required this.priceExclVat,
    required this.partCostExclVat,
    required this.partCostInclVat,
    required this.enableDeviceDetails,
    required this.enableSearchInExpress,
    required this.userId,
    required this.location,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.images,
    this.assignedItems,
    this.assignedItemIds,
    this.laborRate,
    this.profitMarkup,
    this.serviceTimeInMinutes,
    this.enableServiceDetails,
    this.labourCalculator,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      model: json['model'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      vat: (json['vat'] ?? 0),
      priceInclVat: (json['price_incl_vat'] ?? 0),
      priceExclVat: (json['price_excl_vat'] ?? 0),
      partCostExclVat: (json['part_cost_excl_vat'] ?? 0),
      partCostInclVat: (json['part_cost_incl_vat'] ?? 0).toDouble(),
      enableDeviceDetails: json['enable_device_details'] ?? false,
      enableSearchInExpress: json['enable_search_in_express'] ?? false,
      userId: json['userId'] ?? '',
      location: json['location'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? '2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse(json['updatedAt'] ?? '2023-01-01T00:00:00.000Z'),
      description: json['description'],
      images: (json['images'] as List<dynamic>?)?.map((image) => ServiceImage.fromJson(image)).toList(),
      assignedItems: json['assignedItems'],
      assignedItemIds: json['assignedItemIds'] != null ? List<String>.from(json['assignedItemIds']) : null,
      laborRate: (json['labor_rate'] ?? 0).toDouble(),
      profitMarkup: (json['profitMarkup'] ?? 0).toDouble(),
      serviceTimeInMinutes: json['service_time_in_minutes'],
      enableServiceDetails: json['enable_service_details'],
      labourCalculator: json['labour_calculator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serviceId': serviceId,
      'name': name,
      'category': category,
      'model': model,
      'manufacturer': manufacturer,
      'vat': vat,
      'price_incl_vat': priceInclVat,
      'price_excl_vat': priceExclVat,
      'part_cost_excl_vat': partCostExclVat,
      'part_cost_incl_vat': partCostInclVat,
      'enable_device_details': enableDeviceDetails,
      'enable_search_in_express': enableSearchInExpress,
      'userId': userId,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'images': images?.map((image) => image.toJson()).toList(),
      'assignedItems': assignedItems,
      'assignedItemIds': assignedItemIds,
      'labor_rate': laborRate,
      'profitMarkup': profitMarkup,
      'service_time_in_minutes': serviceTimeInMinutes,
      'enable_service_details': enableServiceDetails,
      'labour_calculator': labourCalculator,
    };
  }
}

class ServiceImage {
  final bool favorite;
  final String path;
  final String id;
  final String? url;

  ServiceImage({required this.favorite, required this.path, required this.id, this.url});

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(
      favorite: json['favorite'] ?? json['favourite'] ?? false,
      path: json['path'] ?? '',
      id: json['id'] ?? '',
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'favorite': favorite, 'path': path, 'id': id, 'url': url};
  }
}

class AssignedItem {
  final String id;
  final String productName;
  final dynamic itemNumber;
  final int stockValue;
  final String stockUnit;
  final String manufacturer;
  final String category;
  final String condition;
  final double vatPercent;
  final double profitMarkup;
  final String profitMarkupSymbol;
  final double purchasePriceExlVat;
  final double purchasePriceIncVat;
  final double salePriceExlVat;
  final double salePriceIncVat;
  final List<Barcode> barcode;
  final List<SupplierPrice> supplierPriceList;
  final List<Supplier> supplierList;
  final bool serialNoManagement;
  final bool pricingCalculator;
  final String location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String? physicalLocation;

  AssignedItem({
    required this.id,
    required this.productName,
    required this.itemNumber,
    required this.stockValue,
    required this.stockUnit,
    required this.manufacturer,
    required this.category,
    required this.condition,
    required this.vatPercent,
    required this.profitMarkup,
    required this.profitMarkupSymbol,
    required this.purchasePriceExlVat,
    required this.purchasePriceIncVat,
    required this.salePriceExlVat,
    required this.salePriceIncVat,
    required this.barcode,
    required this.supplierPriceList,
    required this.supplierList,
    required this.serialNoManagement,
    required this.pricingCalculator,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.physicalLocation,
  });

  factory AssignedItem.fromJson(Map<String, dynamic> json) {
    return AssignedItem(
      id: json['_id'] ?? '',
      productName: json['productName'] ?? '',
      itemNumber: json['itemNumber'] ?? '',
      stockValue: json['stockValue'] ?? 0,
      stockUnit: json['stockUnit'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      category: json['category'] ?? '',
      condition: json['condition'] ?? '',
      vatPercent: (json['vatPercent'] ?? 0).toDouble(),
      profitMarkup: (json['profitMarkup'] ?? 0).toDouble(),
      profitMarkupSymbol: json['profitMarkupSymbol'] ?? '',
      purchasePriceExlVat: (json['purchasePriceExlVat'] ?? 0).toDouble(),
      purchasePriceIncVat: (json['purchasePriceIncVat'] ?? 0).toDouble(),
      salePriceExlVat: (json['salePriceExlVat'] ?? 0).toDouble(),
      salePriceIncVat: (json['salePriceIncVat'] ?? 0).toDouble(),
      barcode: (json['barcode'] as List<dynamic>?)?.map((barcode) => Barcode.fromJson(barcode)).toList() ?? [],
      supplierPriceList:
          (json['supplierPriceList'] as List<dynamic>?)?.map((supplier) => SupplierPrice.fromJson(supplier)).toList() ??
          [],
      supplierList:
          (json['supplierList'] as List<dynamic>?)?.map((supplier) => Supplier.fromJson(supplier)).toList() ?? [],
      serialNoManagement: json['serialNoManagement'] ?? false,
      pricingCalculator: json['pricingCalculator'] ?? false,
      location: json['location'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? '2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse(json['updatedAt'] ?? '2023-01-01T00:00:00.000Z'),
      version: json['__v'] ?? 0,
      physicalLocation: json['physicalLocation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productName': productName,
      'itemNumber': itemNumber,
      'stockValue': stockValue,
      'stockUnit': stockUnit,
      'manufacturer': manufacturer,
      'category': category,
      'condition': condition,
      'vatPercent': vatPercent,
      'profitMarkup': profitMarkup,
      'profitMarkupSymbol': profitMarkupSymbol,
      'purchasePriceExlVat': purchasePriceExlVat,
      'purchasePriceIncVat': purchasePriceIncVat,
      'salePriceExlVat': salePriceExlVat,
      'salePriceIncVat': salePriceIncVat,
      'barcode': barcode.map((barcode) => barcode.toJson()).toList(),
      'supplierPriceList': supplierPriceList.map((supplier) => supplier.toJson()).toList(),
      'supplierList': supplierList.map((supplier) => supplier.toJson()).toList(),
      'serialNoManagement': serialNoManagement,
      'pricingCalculator': pricingCalculator,
      'location': location,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'physicalLocation': physicalLocation,
    };
  }
}

class Barcode {
  final String id;
  final String barcode;

  Barcode({required this.id, required this.barcode});

  factory Barcode.fromJson(Map<String, dynamic> json) {
    return Barcode(id: json['id'] ?? '', barcode: json['barcode'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'barcode': barcode};
  }
}

class SupplierPrice {
  final String supplierId;
  final bool defaultSupplier;
  final String lastChange;
  final String priceExclVat;
  final double salesPriceExclVat;
  final String profitMarkup;

  SupplierPrice({
    required this.supplierId,
    required this.defaultSupplier,
    required this.lastChange,
    required this.priceExclVat,
    required this.salesPriceExclVat,
    required this.profitMarkup,
  });

  factory SupplierPrice.fromJson(Map<String, dynamic> json) {
    return SupplierPrice(
      supplierId: json['supplierId'] ?? '',
      defaultSupplier: json['default'] ?? false,
      lastChange: json['lastChange'] ?? '',
      priceExclVat: json['priceExclVat'] ?? '',
      salesPriceExclVat: (json['salesPriceExclVat'] ?? 0).toDouble(),
      profitMarkup: json['profitMarkup'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'default': defaultSupplier,
      'lastChange': lastChange,
      'priceExclVat': priceExclVat,
      'salesPriceExclVat': salesPriceExclVat,
      'profitMarkup': profitMarkup,
    };
  }
}

class Supplier {
  final String fullName;
  final String email;
  final String id;
  final String supplierName;
  final double salePriceExlVat;
  final double salePriceIncVat;
  final double purchasePriceExlVat;
  final double purchasePriceIncVat;
  final String profitMarkupSymbol;
  final double profitMarkup;
  final double vatPercent;
  final bool primary;

  Supplier({
    required this.fullName,
    required this.email,
    required this.id,
    required this.supplierName,
    required this.salePriceExlVat,
    required this.salePriceIncVat,
    required this.purchasePriceExlVat,
    required this.purchasePriceIncVat,
    required this.profitMarkupSymbol,
    required this.profitMarkup,
    required this.vatPercent,
    required this.primary,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      id: json['id'] ?? '',
      supplierName: json['supplierName'] ?? '',
      salePriceExlVat: (json['salePriceExlVat'] ?? 0).toDouble(),
      salePriceIncVat: (json['salePriceIncVat'] ?? 0).toDouble(),
      purchasePriceExlVat: (json['purchasePriceExlVat'] ?? 0).toDouble(),
      purchasePriceIncVat: (json['purchasePriceIncVat'] ?? 0).toDouble(),
      profitMarkupSymbol: json['profitMarkupSymbol'] ?? '',
      profitMarkup: (json['profitMarkup'] ?? 0).toDouble(),
      vatPercent: (json['vatPercent'] ?? 0).toDouble(),
      primary: json['primary'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'id': id,
      'supplierName': supplierName,
      'salePriceExlVat': salePriceExlVat,
      'salePriceIncVat': salePriceIncVat,
      'purchasePriceExlVat': purchasePriceExlVat,
      'purchasePriceIncVat': purchasePriceIncVat,
      'profitMarkupSymbol': profitMarkupSymbol,
      'profitMarkup': profitMarkup,
      'vatPercent': vatPercent,
      'primary': primary,
    };
  }
}

class Device {
  final String id;
  final String brand;
  final String model;
  final String? category;
  final String? imei;
  final List<Condition> condition;
  final List<dynamic> accessories;
  final String? deviceSecurity;
  final List<dynamic> securityLock;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String? brandId;
  final String? serialNo;
  final String? type;
  final String? length;

  Device({
    required this.id,
    required this.brand,
    required this.model,
    this.category,
    this.imei,
    required this.condition,
    required this.accessories,
    this.deviceSecurity,
    required this.securityLock,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.brandId,
    this.serialNo,
    this.type,
    this.length,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['_id'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'] ?? '',
      category: json['category'],
      imei: json['imei'],
      condition: (json['condition'] as List<dynamic>?)?.map((cond) => Condition.fromJson(cond)).toList() ?? [],
      accessories: json['accessories'] ?? [],
      deviceSecurity: json['deviceSecurity'],
      securityLock: json['securityLock'] ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? '2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse(json['updatedAt'] ?? '2023-01-01T00:00:00.000Z'),
      version: json['__v'] ?? 0,
      brandId: json['brandId'],
      serialNo: json['serial_no'],
      type: json['type'],
      length: json['Length'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'brand': brand,
      'model': model,
      'category': category,
      'imei': imei,
      'condition': condition.map((cond) => cond.toJson()).toList(),
      'accessories': accessories,
      'deviceSecurity': deviceSecurity,
      'securityLock': securityLock,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'brandId': brandId,
      'serial_no': serialNo,
      'type': type,
      'Length': length,
    };
  }
}

class Contact {
  final String id;
  final String type;
  final String type2;
  final String salutation;
  final String firstName;
  final String lastName;
  final String telephone;
  final String email;
  final String customerId;
  final String organization;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String? title;

  Contact({
    required this.id,
    required this.type,
    required this.type2,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.telephone,
    required this.email,
    required this.customerId,
    required this.organization,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.title,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['_id'] ?? '',
      type: json['type'] ?? '',
      type2: json['type2'] ?? '',
      salutation: json['salutation'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      customerId: json['customerId'] ?? '',
      organization: json['organization'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? '2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse(json['updatedAt'] ?? '2023-01-01T00:00:00.000Z'),
      version: json['__v'] ?? 0,
      title: json['title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'type': type,
      'type2': type2,
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'telephone': telephone,
      'email': email,
      'customerId': customerId,
      'organization': organization,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'title': title,
    };
  }
}

class Defect {
  final String id;
  final List<DefectItem> defect;
  final String jobType;
  final String reference;
  final String description;
  List<InternalNote>? internalNote;
  final List<dynamic> assignItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  Defect({
    required this.id,
    required this.defect,
    required this.jobType,
    required this.reference,
    required this.description,
    this.internalNote,
    required this.assignItems,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory Defect.fromJson(Map<String, dynamic> json) {
    return Defect(
      id: json['_id'] ?? '',
      defect: (json['defect'] as List<dynamic>?)?.map((defect) => DefectItem.fromJson(defect)).toList() ?? [],
      jobType: json['jobType'] ?? '',
      reference: json['reference'] ?? '',
      description: json['description'] ?? '',
      // internalNote: json['internalNote'] is List
      //     ? (json['internalNote'] as List<dynamic>?)?.map((note) => InternalNote.fromJson(note)).toList() ?? []
      //     : [],
      assignItems: json['assignItems'] ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? '2023-01-01T00:00:00.000Z'),
      updatedAt: DateTime.parse(json['updatedAt'] ?? '2023-01-01T00:00:00.000Z'),
      version: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'defect': defect.map((defect) => defect.toJson()).toList(),
      'jobType': jobType,
      'reference': reference,
      'description': description,
      'internalNote': internalNote?.map((note) => note.toJson()).toList(),
      'assignItems': assignItems,
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
    };
  }
}

class DefectItem {
  final String value;
  final String id;
  final String? label;
  final bool? isAdmin;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? version;

  DefectItem({
    required this.value,
    required this.id,
    this.label,
    this.isAdmin,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory DefectItem.fromJson(Map<String, dynamic> json) {
    return DefectItem(
      value: json['value'] ?? '',
      id: json['id'] ?? json['_id'] ?? '',
      label: json['label'],
      isAdmin: json['isAdmin'],
      userId: json['userId'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      version: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'id': id,
      'label': label,
      'isAdmin': isAdmin,
      'userId': userId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

class InternalNote {
  final String text;
  final String userId;
  final DateTime createdAt;
  final String userName;
  final String id;

  InternalNote({
    required this.text,
    required this.userId,
    required this.createdAt,
    required this.userName,
    required this.id,
  });

  factory InternalNote.fromJson(Map<String, dynamic> json) {
    return InternalNote(
      text: json['text'] is List
          ? json['text'].isEmpty
                ? ''
                : json['text'][0] ?? ''
          : json['text'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: _parseDateTime(json['createdAt']),
      userName: json['userName'] ?? '',
      id: json['id'] ?? '',
    );
  }

  static DateTime _parseDateTime(dynamic dateTimeValue) {
    try {
      if (dateTimeValue == null) {
        return DateTime.now();
      }

      if (dateTimeValue is DateTime) {
        return dateTimeValue;
      }

      if (dateTimeValue is String) {
        // Try parsing ISO string first
        if (dateTimeValue.contains('T')) {
          return DateTime.parse(dateTimeValue);
        }

        // Try parsing milliseconds since epoch
        if (dateTimeValue.length > 10) {
          final milliseconds = int.tryParse(dateTimeValue);
          if (milliseconds != null) {
            return DateTime.fromMillisecondsSinceEpoch(milliseconds);
          }
        }

        // Try parsing as regular date string
        return DateTime.parse(dateTimeValue);
      }

      if (dateTimeValue is int) {
        // Handle milliseconds since epoch
        return DateTime.fromMillisecondsSinceEpoch(dateTimeValue);
      }

      // Fallback to current time
      return DateTime.now();
    } catch (e) {
      debugPrint('⚠️ Error parsing DateTime: $dateTimeValue, error: $e');
      return DateTime.now(); // Fallback to current time
    }
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'userId': userId, 'createdAt': createdAt.toIso8601String(), 'userName': userName, 'id': id};
  }
}

class UserData {
  final String id;
  final String email;
  final String fullName;
  final String avatar;
  final String position;
  final Currency currency;
  final DateFormat dateFormat;

  UserData({
    required this.id,
    required this.email,
    required this.fullName,
    required this.avatar,
    required this.position,
    required this.currency,
    required this.dateFormat,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      avatar: json['avatar'] ?? '',
      position: json['position'] ?? '',
      currency: Currency.fromJson(json['currency'] ?? {}),
      dateFormat: DateFormat.fromJson(json['dateFormat'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
      'position': position,
      'currency': currency.toJson(),
      'dateFormat': dateFormat.toJson(),
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

class LocationData {
  final String id;
  final String locationId;
  final String locationName;
  final String street;
  final String city;
  final String country;

  LocationData({
    required this.id,
    required this.locationId,
    required this.locationName,
    required this.street,
    required this.city,
    required this.country,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['_id'] ?? '',
      locationId: json['location_id'] ?? '',
      locationName: json['location_name'] ?? '',
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'location_id': locationId,
      'location_name': locationName,
      'street': street,
      'city': city,
      'country': country,
    };
  }
}
