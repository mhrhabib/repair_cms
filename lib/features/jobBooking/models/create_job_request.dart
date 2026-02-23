// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:repair_cms/core/helpers/storage.dart';

import '../../myJobs/models/single_job_model.dart';

// Helper function to validate MongoDB ObjectId
bool _isValidObjectId(String? id) {
  if (id == null || id.isEmpty) return false;
  // MongoDB ObjectId is a 24-character hexadecimal string
  final objectIdRegex = RegExp(r'^[0-9a-fA-F]{24}$');
  return objectIdRegex.hasMatch(id);
}

class CreateJobRequest {
  final Job job;
  final Defect defect;
  final Device device;
  final Contact contact;

  CreateJobRequest({required this.job, required this.defect, required this.device, required this.contact});

  Map<String, dynamic> toJson() {
    return {'job': job.toJson(), 'defect': defect.toJson(), 'device': device.toJson(), 'contact': contact.toJson()};
  }
}

class Job {
  final String jobType;
  final String jobTypes;
  final String model;
  final List<String> servicesIds;
  final List<String> assignedItemsIds;
  final String? userId;
  final String? loggedUserId;
  final List<JobStatus> jobStatus;
  final String status;
  final double discount;
  final double vat;
  final double subTotal;
  final double total;
  final String jobNo;
  final String customerId;
  final CustomerDetails customerDetails;
  final List<AvatarFile>? files;
  String? location;
  String? physicalLocation;
  String? signatureFilePath;
  final String salutationHTMLmarkup;
  final String termsAndConditionsHTMLmarkup;
  final ReceiptFooter receiptFooter;
  final String printOption;
  final bool emailConfirmation;
  final bool printDeviceLabel;

  Job({
    required this.jobType,
    required this.jobTypes,
    required this.model,
    required this.servicesIds,
    required this.assignedItemsIds,
    required this.userId,
    required this.loggedUserId,
    required this.jobStatus,
    required this.status,
    required this.discount,
    required this.vat,
    required this.subTotal,
    required this.total,
    required this.jobNo,
    required this.customerId,
    required this.customerDetails,
    this.files,
    this.location,
    this.physicalLocation,
    this.signatureFilePath,
    required this.salutationHTMLmarkup,
    required this.termsAndConditionsHTMLmarkup,
    required this.receiptFooter,
    required this.printOption,
    required this.emailConfirmation,
    required this.printDeviceLabel,
  });

  Map<String, dynamic> toJson() {
    // Get values from storage with validation
    final storedUserId = storage.read('userId');
    final storedLocationId = storage.read('locationId');

    // Only include valid MongoDB ObjectIds
    final validUserId = _isValidObjectId(userId) ? userId : (_isValidObjectId(storedUserId) ? storedUserId : null);
    final validLoggedUserId = _isValidObjectId(loggedUserId)
        ? loggedUserId
        : (_isValidObjectId(storedUserId) ? storedUserId : null);
    final validLocation = _isValidObjectId(location)
        ? location
        : (_isValidObjectId(storedLocationId) ? storedLocationId : null);

    return {
      'jobType': jobType,
      'jobTypes': jobTypes,
      'model': model,
      'servicesIds': servicesIds,
      'assignedItemsIds': assignedItemsIds,
      if (validUserId != null) 'userId': validUserId,
      if (validLoggedUserId != null) 'loggedUserId': validLoggedUserId,
      'jobStatus': jobStatus
          .where((status) => _isValidObjectId(status.userId))
          .map((status) => status.toJson())
          .toList(),
      'status': status,
      'discount': discount,
      'vat': vat,
      'subTotal': subTotal,
      'total': total,
      'jobNo': jobNo,
      if (_isValidObjectId(customerId)) 'customerId': customerId,
      'customerDetails': customerDetails.toJson(),
      'files': files?.map((file) => file.toJson()).toList(),
      if (validLocation != null) 'location': validLocation,
      'physicalLocation': physicalLocation,
      'signatureFilePath': signatureFilePath,
      'salutationHTMLmarkup': salutationHTMLmarkup,
      'termsAndConditionsHTMLmarkup': termsAndConditionsHTMLmarkup,
      'receiptFooter': receiptFooter.toJson(),
      'printOption': printOption,
      'emailConfirmation': emailConfirmation,
      'printDeviceLabel': printDeviceLabel,
    };
  }

  Job copyWith({
    String? jobType,
    String? jobTypes,
    String? model,
    List<String>? servicesIds,
    List<String>? assignedItemsIds,
    String? userId,
    String? loggedUserId,
    List<JobStatus>? jobStatus,
    String? status,
    double? discount,
    double? vat,
    double? subTotal,
    double? total,
    String? jobNo,
    String? customerId,
    CustomerDetails? customerDetails,
    List<AvatarFile>? files,
    String? location,
    String? physicalLocation,
    String? signatureFilePath,
    String? salutationHTMLmarkup,
    String? termsAndConditionsHTMLmarkup,
    ReceiptFooter? receiptFooter,
    String? printOption,
    bool? emailConfirmation,
    bool? printDeviceLabel,
  }) {
    return Job(
      jobType: jobType ?? this.jobType,
      jobTypes: jobTypes ?? this.jobTypes,
      model: model ?? this.model,
      servicesIds: servicesIds ?? this.servicesIds,
      assignedItemsIds: assignedItemsIds ?? this.assignedItemsIds,
      userId: userId ?? this.userId,
      loggedUserId: loggedUserId ?? this.loggedUserId,
      jobStatus: jobStatus ?? this.jobStatus,
      status: status ?? this.status,
      discount: discount ?? this.discount,
      vat: vat ?? this.vat,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      jobNo: jobNo ?? this.jobNo,
      customerId: customerId ?? this.customerId,
      customerDetails: customerDetails ?? this.customerDetails,
      files: files ?? this.files,
      location: location ?? this.location,
      physicalLocation: physicalLocation ?? this.physicalLocation,
      signatureFilePath: signatureFilePath ?? this.signatureFilePath,
      salutationHTMLmarkup: salutationHTMLmarkup ?? this.salutationHTMLmarkup,
      termsAndConditionsHTMLmarkup: termsAndConditionsHTMLmarkup ?? this.termsAndConditionsHTMLmarkup,
      receiptFooter: receiptFooter ?? this.receiptFooter,
      printOption: printOption ?? this.printOption,
      emailConfirmation: emailConfirmation ?? this.emailConfirmation,
      printDeviceLabel: printDeviceLabel ?? this.printDeviceLabel,
    );
  }
}

class Files {
  List<AvatarFile>? files;

  Files({this.files});

  Files.fromJson(Map<String, dynamic> json) {
    if (json['files'] != null) {
      files = <AvatarFile>[];
      json['files'].forEach((v) {
        files!.add(AvatarFile.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AvatarFile {
  String? id;
  String? file;

  AvatarFile({this.id, this.file});

  AvatarFile.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    file = json['file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['file'] = file;
    return data;
  }
}

class JobStatus {
  final String title;
  final String userId;
  final String colorCode;
  final String userName;
  final int createAtStatus;
  final bool notifications;
  final String notes;
  final String? email;

  JobStatus({
    required this.title,
    required this.userId,
    required this.colorCode,
    required this.userName,
    required this.createAtStatus,
    required this.notifications,
    required this.notes,
    this.email,
  });

  factory JobStatus.fromJson(Map<String, dynamic> json) {
    return JobStatus(
      title: json['title'] ?? '',
      userId: json['userId'] ?? '',
      colorCode: json['colorCode'] ?? '',
      userName: json['userName'] ?? '',
      createAtStatus: json['createAtStatus'] ?? 0,
      notifications: json['notifications'] ?? false,
      notes: json['notes'] ?? '',
      email: json['email'],
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
      'notes': notes,
      if (email != null) 'email': email,
    };
  }
}

class CustomerDetails {
  final String customerId;
  final String type;
  final String type2;
  final String organization;
  final String customerNo;
  final String email;
  final String telephone;
  final String telephonePrefix;
  final CustomerAddress shippingAddress;
  final CustomerAddress billingAddress;
  final String salutation;
  final String firstName;
  final String lastName;
  final String position;
  final String vatNo;
  final bool reverseCharge;

  CustomerDetails({
    required this.customerId,
    required this.type,
    required this.type2,
    required this.organization,
    required this.customerNo,
    required this.email,
    required this.telephone,
    required this.telephonePrefix,
    required this.shippingAddress,
    required this.billingAddress,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.vatNo,
    required this.reverseCharge,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      customerId: json['customerId'] ?? '',
      type: json['type'] ?? 'Personal',
      type2: json['type2'] ?? 'personal',
      organization: json['organization'] ?? '',
      customerNo: json['customerNo'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      telephonePrefix: json['telephone_prefix'] ?? '+1',
      shippingAddress: json['shipping_address'] != null
          ? CustomerAddress.fromJson(json['shipping_address'])
          : CustomerAddress(street: '', no: '', zip: '', city: '', state: '', country: ''),
      billingAddress: json['billing_address'] != null
          ? CustomerAddress.fromJson(json['billing_address'])
          : CustomerAddress(street: '', no: '', zip: '', city: '', state: '', country: ''),
      salutation: json['salutation'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      position: json['position'] ?? '',
      vatNo: json['vatNo'] ?? '',
      reverseCharge: json['reverseCharge'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (_isValidObjectId(customerId)) 'customerId': customerId,
      'type': type,
      'type2': type2,
      'organization': organization,
      'customerNo': customerNo,
      'email': email,
      'telephone': telephone,
      'telephone_prefix': telephonePrefix,
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress.toJson(),
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'vatNo': vatNo,
      'reverseCharge': reverseCharge,
    };
  }

  CustomerDetails copyWith({
    String? customerId,
    String? type,
    String? type2,
    String? organization,
    String? customerNo,
    String? email,
    String? telephone,
    String? telephonePrefix,
    CustomerAddress? shippingAddress,
    CustomerAddress? billingAddress,
    String? salutation,
    String? firstName,
    String? lastName,
    String? position,
    String? vatNo,
    bool? reverseCharge,
  }) {
    return CustomerDetails(
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      type2: type2 ?? this.type2,
      organization: organization ?? this.organization,
      customerNo: customerNo ?? this.customerNo,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      telephonePrefix: telephonePrefix ?? this.telephonePrefix,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      salutation: salutation ?? this.salutation,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      position: position ?? this.position,
      vatNo: vatNo ?? this.vatNo,
      reverseCharge: reverseCharge ?? this.reverseCharge,
    );
  }
}

class CustomerAddress {
  final String? id;
  final String? street;
  final String? no;
  final String? zip;
  final String? city;
  final String? state;
  final String? country;

  CustomerAddress({this.id, this.street, this.no, this.zip, this.city, this.state, this.country});

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['_id'],
      street: json['street'] ?? '',
      no: json['no'] ?? '',
      zip: json['zip'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'street': street,
      'no': no,
      'zip': zip,
      'city': city,
      'state': state,
      'country': country,
    };
  }

  CustomerAddress copyWith({
    String? id,
    String? street,
    String? no,
    String? zip,
    String? city,
    String? state,
    String? country,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      street: street ?? this.street,
      no: no ?? this.no,
      zip: zip ?? this.zip,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
    );
  }
}

class ReceiptFooter {
  final String companyLogo;
  final String companyLogoURL;
  final CompanyAddress address;
  final CompanyContact contact;
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
      address: json['address'] != null
          ? CompanyAddress.fromJson(json['address'])
          : CompanyAddress(companyName: '', street: '', num: '', zip: '', city: '', country: ''),
      contact: json['contact'] != null
          ? CompanyContact.fromJson(json['contact'])
          : CompanyContact(ceo: '', telephone: '', email: '', website: ''),
      bank: json['bank'] != null ? BankDetails.fromJson(json['bank']) : BankDetails(bankName: '', iban: '', bic: ''),
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

  ReceiptFooter copyWith({
    String? companyLogo,
    String? companyLogoURL,
    CompanyAddress? address,
    CompanyContact? contact,
    BankDetails? bank,
  }) {
    return ReceiptFooter(
      companyLogo: companyLogo ?? this.companyLogo,
      companyLogoURL: companyLogoURL ?? this.companyLogoURL,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      bank: bank ?? this.bank,
    );
  }
}

class CompanyAddress {
  final String companyName;
  final String street;
  final String num;
  final String zip;
  final String city;
  final String country;

  CompanyAddress({
    required this.companyName,
    required this.street,
    required this.num,
    required this.zip,
    required this.city,
    required this.country,
  });

  factory CompanyAddress.fromJson(Map<String, dynamic> json) {
    return CompanyAddress(
      companyName: json['companyName'] ?? '',
      street: json['street'] ?? '',
      num: json['num'] ?? '',
      zip: json['zip'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'companyName': companyName, 'street': street, 'num': num, 'zip': zip, 'city': city, 'country': country};
  }

  CompanyAddress copyWith({
    String? companyName,
    String? street,
    String? num,
    String? zip,
    String? city,
    String? country,
  }) {
    return CompanyAddress(
      companyName: companyName ?? this.companyName,
      street: street ?? this.street,
      num: num ?? this.num,
      zip: zip ?? this.zip,
      city: city ?? this.city,
      country: country ?? this.country,
    );
  }
}

class CompanyContact {
  final String ceo;
  final String telephone;
  final String email;
  final String website;

  CompanyContact({required this.ceo, required this.telephone, required this.email, required this.website});

  factory CompanyContact.fromJson(Map<String, dynamic> json) {
    return CompanyContact(
      ceo: json['ceo'] ?? '',
      telephone: json['telephone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ceo': ceo, 'telephone': telephone, 'email': email, 'website': website};
  }

  CompanyContact copyWith({String? ceo, String? telephone, String? email, String? website}) {
    return CompanyContact(
      ceo: ceo ?? this.ceo,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      website: website ?? this.website,
    );
  }
}

class BankDetails {
  final String bankName;
  final String iban;
  final String bic;

  BankDetails({required this.bankName, required this.iban, required this.bic});

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(bankName: json['bankName'] ?? '', iban: json['iban'] ?? '', bic: json['bic'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'bankName': bankName, 'iban': iban, 'bic': bic};
  }

  BankDetails copyWith({String? bankName, String? iban, String? bic}) {
    return BankDetails(bankName: bankName ?? this.bankName, iban: iban ?? this.iban, bic: bic ?? this.bic);
  }
}

class Defect {
  final String jobType;
  final List<DefectItem> defect;
  final List<dynamic> internalNote;

  Defect({required this.jobType, required this.defect, required this.internalNote});

  Map<String, dynamic> toJson() {
    return {'jobType': jobType, 'defect': defect.map((item) => item.toJson()).toList(), 'internalNote': internalNote};
  }

  Defect copyWith({String? jobType, List<DefectItem>? defect, List<dynamic>? internalNote}) {
    return Defect(
      jobType: jobType ?? this.jobType,
      defect: defect ?? this.defect,
      internalNote: internalNote ?? this.internalNote,
    );
  }
}

class DefectItem {
  final String value;
  final String id;

  DefectItem({required this.value, required this.id});

  Map<String, dynamic> toJson() {
    return {'value': value, 'id': id};
  }

  factory DefectItem.fromJson(Map<String, dynamic> json) {
    return DefectItem(value: json['value'] ?? '', id: json['id'] ?? '');
  }

  DefectItem copyWith({String? value, String? id}) {
    return DefectItem(value: value ?? this.value, id: id ?? this.id);
  }
}

class Device {
  final String category;
  final String brand;
  final String model;
  final String imei;
  final List<ConditionItem> condition;
  final String deviceSecurity;

  Device({
    required this.category,
    required this.brand,
    required this.model,
    required this.imei,
    required this.condition,
    required this.deviceSecurity,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'brand': brand,
      'model': model,
      'imei': imei,
      'condition': condition.map((item) => item.toJson()).toList(),
      'deviceSecurity': deviceSecurity,
    };
  }

  Device copyWith({
    String? category,
    String? brand,
    String? model,
    String? imei,
    List<ConditionItem>? condition,
    String? deviceSecurity,
  }) {
    return Device(
      category: category ?? this.category,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      imei: imei ?? this.imei,
      condition: condition ?? this.condition,
      deviceSecurity: deviceSecurity ?? this.deviceSecurity,
    );
  }
}

class ConditionItem {
  final String value;
  final String id;

  ConditionItem({required this.value, required this.id});

  factory ConditionItem.fromJson(Map<String, dynamic> json) {
    return ConditionItem(value: json['value'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'id': id};
  }

  ConditionItem copyWith({String? value, String? id}) {
    return ConditionItem(value: value ?? this.value, id: id ?? this.id);
  }
}

class Contact {
  final String type;
  final String customerId;
  final String type2;
  final String organization;
  final String customerNo;
  final String email;
  final String telephone;
  final String telephonePrefix;
  final CustomerAddress shippingAddress;
  final CustomerAddress billingAddress;
  final String salutation;
  final String firstName;
  final String lastName;
  final String position;
  final String vatNo;
  final bool reverseCharge;

  Contact({
    required this.type,
    required this.customerId,
    required this.type2,
    required this.organization,
    required this.customerNo,
    required this.email,
    required this.telephone,
    required this.telephonePrefix,
    required this.shippingAddress,
    required this.billingAddress,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.position,
    required this.vatNo,
    required this.reverseCharge,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'type': type,
      'customerId': customerId,
      'type2': type2,
      'organization': organization,
      'customerNo': customerNo,
      'telephone': telephone,
      'telephone_prefix': telephonePrefix,
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress.toJson(),
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'vatNo': vatNo,
      'reverseCharge': reverseCharge,
    };

    // Only include email if it's not empty and contains @
    if (email.isNotEmpty && email.contains('@')) {
      data['email'] = email;
    }

    return data;
  }

  Contact copyWith({
    String? type,
    String? customerId,
    String? type2,
    String? organization,
    String? customerNo,
    String? email,
    String? telephone,
    String? telephonePrefix,
    CustomerAddress? shippingAddress,
    CustomerAddress? billingAddress,
    String? salutation,
    String? firstName,
    String? lastName,
    String? position,
    String? vatNo,
    bool? reverseCharge,
  }) {
    return Contact(
      type: type ?? this.type,
      customerId: customerId ?? this.customerId,
      type2: type2 ?? this.type2,
      organization: organization ?? this.organization,
      customerNo: customerNo ?? this.customerNo,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      telephonePrefix: telephonePrefix ?? this.telephonePrefix,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      billingAddress: billingAddress ?? this.billingAddress,
      salutation: salutation ?? this.salutation,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      position: position ?? this.position,
      vatNo: vatNo ?? this.vatNo,
      reverseCharge: reverseCharge ?? this.reverseCharge,
    );
  }
}

class CreateJobResponse {
  final bool success;
  final JobData? data;

  CreateJobResponse({required this.success, this.data});

  factory CreateJobResponse.fromJson(Map<String, dynamic> json) {
    return CreateJobResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? JobData.fromJson(json['data']) : null,
    );
  }
}

class JobData {
  final String? sId;
  final String? jobNo;
  final String? jobType;
  final String? deviceType;
  final String? model;
  final List<String>? servicesIds;
  final String? deviceId;
  final String? jobContactId;
  final String? defectId;
  final List<String>? assignedItemsIds;
  final String? physicalLocation;
  final bool? emailConfirmation;
  final List<File>? files;
  final String? signatureFilePath;
  final String? printOption;
  final bool? printDeviceLabel;
  final List<JobStatus>? jobStatus;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final List<ServiceData>? services;
  final List<AssignedItemData>? assignedItems;
  final List<DeviceData>? device;
  final List<ContactData>? contact;
  final List<DefectData>? defect;
  final ReceiptFooter? receiptFooter;
  final CustomerDetails? customerDetails;
  final String? jobTrackingNumber;
  final String? salutationHTMLmarkup;
  final String? termsAndConditionsHTMLmarkup;

  JobData({
    this.sId,
    this.jobNo,
    this.jobType,
    this.deviceType,
    this.model,
    this.servicesIds,
    this.deviceId,
    this.jobContactId,
    this.defectId,
    this.assignedItemsIds,
    this.physicalLocation,
    this.emailConfirmation,
    this.files,
    this.signatureFilePath,
    this.printOption,
    this.printDeviceLabel,
    this.jobStatus,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.services,
    this.assignedItems,
    this.device,
    this.contact,
    this.defect,
    this.receiptFooter,
    this.customerDetails,
    this.jobTrackingNumber,
    this.salutationHTMLmarkup,
    this.termsAndConditionsHTMLmarkup,
  });

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(
      sId: json['_id'],
      jobNo: json['jobNo'],
      jobType: json['jobType'],
      deviceType: json['deviceType'],
      model: json['model'],
      servicesIds: json['servicesIds'] != null ? List<String>.from(json['servicesIds']) : null,
      deviceId: json['deviceId'],
      jobContactId: json['jobContactId'],
      defectId: json['defectId'],
      assignedItemsIds: json['assignedItemsIds'] != null ? List<String>.from(json['assignedItemsIds']) : null,
      physicalLocation: json['physicalLocation'],
      emailConfirmation: json['emailConfirmation'],
      files: json['files'] != null ? (json['files'] as List).map((file) => File.fromJson(file)).toList() : null,
      signatureFilePath: json['signatureFilePath'],
      printOption: json['printOption'],
      printDeviceLabel: json['printDeviceLabel'],
      jobStatus: json['jobStatus'] != null
          ? (json['jobStatus'] as List).map((status) => JobStatus.fromJson(status)).toList()
          : null,
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      services: json['services'] != null
          ? (json['services'] as List).map((service) => ServiceData.fromJson(service)).toList()
          : null,
      assignedItems: json['assignedItems'] != null
          ? (json['assignedItems'] as List).map((item) => AssignedItemData.fromJson(item)).toList()
          : null,
      device: json['device'] != null
          ? (json['device'] as List).map((device) => DeviceData.fromJson(device)).toList()
          : null,
      contact: json['contact'] != null
          ? (json['contact'] as List).map((contact) => ContactData.fromJson(contact)).toList()
          : null,
      defect: json['defect'] != null
          ? (json['defect'] as List).map((defect) => DefectData.fromJson(defect)).toList()
          : null,
      receiptFooter: json['receiptFooter'] != null || json['receipt_footer'] != null
          ? ReceiptFooter.fromJson(json['receiptFooter'] ?? json['receipt_footer'])
          : null,
      customerDetails: json['customerDetails'] != null ? CustomerDetails.fromJson(json['customerDetails']) : null,
      jobTrackingNumber: json['jobTrackingNumber'],
      salutationHTMLmarkup: json['salutationHTMLmarkup'],
      termsAndConditionsHTMLmarkup: json['termsAndConditionsHTMLmarkup'],
    );
  }
}

class ServiceData {
  final String? sId;
  final String? name;
  final String? serviceId;
  final String? description;
  final String? manufacturer;
  final String? model;
  final List<String>? tags;
  final List<ServiceImage>? images;
  final List<dynamic>? assignedItems;
  final String? userId;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? category;
  final dynamic priceExclVat;
  final dynamic priceInclVat;
  final dynamic vat;

  ServiceData({
    this.sId,
    this.name,
    this.serviceId,
    this.description,
    this.manufacturer,
    this.model,
    this.tags,
    this.images,
    this.assignedItems,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.category,
    this.priceExclVat,
    this.priceInclVat,
    this.vat,
  });

  factory ServiceData.fromJson(Map<String, dynamic> json) {
    return ServiceData(
      sId: json['_id'],
      name: json['name'],
      serviceId: json['serviceId'],
      description: json['description'],
      manufacturer: json['manufacturer'],
      model: json['model'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      images: json['images'] != null
          ? (json['images'] as List).map((image) => ServiceImage.fromJson(image)).toList()
          : null,
      assignedItems: json['assignedItems'],
      userId: json['userId'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      category: json['category'],
      priceExclVat: json['price_excl_vat'],
      priceInclVat: json['price_incl_vat'],
      vat: json['vat'],
    );
  }
}

class ServiceImage {
  final String? path;
  final bool? favourite;

  ServiceImage({this.path, this.favourite});

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(path: json['path'], favourite: json['favourite']);
  }
}

class AssignedItemData {
  final String? sId;
  final String? productName;
  final String? itemNumber;
  final int? stockValue;
  final String? stockUnit;
  final String? manufacturer;
  final String? category;
  final String? manufacturerNumber;
  final String? physicalLocation;
  final String? color;
  final List<ConditionItem>? condition;
  final dynamic vatPercent;
  final dynamic profitMarkup;
  final String? description;
  final dynamic purchasePriceExlVat;
  final dynamic purchasePriceIncVat;
  final dynamic salePriceExlVat;
  final dynamic salePriceIncVat;
  final int? v;
  final String? updatedAt;
  final String? userId;

  AssignedItemData({
    this.sId,
    this.productName,
    this.itemNumber,
    this.stockValue,
    this.stockUnit,
    this.manufacturer,
    this.category,
    this.manufacturerNumber,
    this.physicalLocation,
    this.color,
    this.condition,
    this.vatPercent,
    this.profitMarkup,
    this.description,
    this.purchasePriceExlVat,
    this.purchasePriceIncVat,
    this.salePriceExlVat,
    this.salePriceIncVat,
    this.v,
    this.updatedAt,
    this.userId,
  });

  factory AssignedItemData.fromJson(Map<String, dynamic> json) {
    return AssignedItemData(
      sId: json['_id'],
      productName: json['productName'],
      itemNumber: json['itemNumber'],
      stockValue: json['stockValue'],
      stockUnit: json['stockUnit'],
      manufacturer: json['manufacturer'],
      category: json['category'],
      manufacturerNumber: json['manufacturerNumber'],
      physicalLocation: json['physicalLocation'],
      color: json['color'],
      condition: json['condition'] != null
          ? json['condition'] is List
                ? (json['condition'] as List).map((item) => ConditionItem.fromJson(item)).toList()
                : [ConditionItem(value: json['condition'].toString(), id: '')]
          : null,
      vatPercent: json['vatPercent'],
      profitMarkup: json['profitMarkup'],
      description: json['description'],
      purchasePriceExlVat: json['purchasePriceExlVat'],
      purchasePriceIncVat: json['purchasePriceIncVat'],
      salePriceExlVat: json['salePriceExlVat'],
      salePriceIncVat: json['salePriceIncVat'],
      v: json['__v'],
      updatedAt: json['updatedAt'],
      userId: json['userId'],
    );
  }
}

class DeviceData {
  final String? sId;
  final String? brand;
  final String? model;
  final String? imei;
  final List<ConditionItem>? condition;
  final String? deviceSecurity;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  DeviceData({
    this.sId,
    this.brand,
    this.model,
    this.imei,
    this.condition,
    this.deviceSecurity,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      sId: json['_id'],
      brand: json['brand'],
      model: json['model'],
      imei: json['imei'],
      condition: json['condition'] != null
          ? (json['condition'] as List).map((item) => ConditionItem.fromJson(item)).toList()
          : null,
      deviceSecurity: json['deviceSecurity'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class ContactData {
  final String? sId;
  final String? type;
  final String? salutation;
  final String? title;
  final String? firstName;
  final String? lastName;
  final String? telephone;
  final String? email;
  final String? street;
  final String? streetNum;
  final String? zip;
  final String? city;
  final String? country;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  ContactData({
    this.sId,
    this.type,
    this.salutation,
    this.title,
    this.firstName,
    this.lastName,
    this.telephone,
    this.email,
    this.street,
    this.streetNum,
    this.zip,
    this.city,
    this.country,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ContactData.fromJson(Map<String, dynamic> json) {
    return ContactData(
      sId: json['_id'],
      type: json['type'],
      salutation: json['salutation'],
      title: json['title'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      telephone: json['telephone'],
      email: json['email'],
      street: json['street'],
      streetNum: json['streetNum'],
      zip: json['zip'],
      city: json['city'],
      country: json['country'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}

class DefectData {
  final String? sId;
  final List<DefectItem>? defect;
  final String? description;
  final List<dynamic>? internalNote;
  final List<String>? assignItems;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  DefectData({
    this.sId,
    this.defect,
    this.description,
    this.internalNote,
    this.assignItems,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory DefectData.fromJson(Map<String, dynamic> json) {
    return DefectData(
      sId: json['_id'],
      defect: json['defect'] != null
          ? json['defect'] is List
                ? (json['defect'] as List).map((item) => DefectItem.fromJson(item)).toList()
                : [DefectItem(value: json['defect'].toString(), id: '')]
          : null,
      description: json['description'],
      internalNote: json['internalNote'] != null ? List<dynamic>.from(json['internalNote']) : null,
      assignItems: json['assignItems'] != null ? List<String>.from(json['assignItems']) : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}
