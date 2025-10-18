// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:repair_cms/core/helpers/storage.dart';

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
  final String userId;
  final String loggedUserId;
  final List<JobStatus> jobStatus;
  final String status;
  final double discount;
  final double vat;
  final double subTotal;
  final double total;
  final String jobNo;
  final String customerId;
  final CustomerDetails customerDetails;
  final List<File>? files;
  String? location;
  String? physicalLocation;
  String? signatureFilePath;
  final String salutationHTMLmarkup;
  final String termsAndConditionsHTMLmarkup;
  final ReceiptFooter receiptFooter;
  final String printOption;

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
  });

  Map<String, dynamic> toJson() {
    return {
      'jobType': jobType,
      'jobTypes': jobTypes,
      'model': model,
      'servicesIds': servicesIds,
      'assignedItemsIds': assignedItemsIds,
      'userId': userId,
      'loggedUserId': loggedUserId,
      'jobStatus': jobStatus.map((status) => status.toJson()).toList(),
      'status': status,
      'discount': discount,
      'vat': vat,
      'subTotal': subTotal,
      'total': total,
      'jobNo': jobNo,
      'customerId': customerId,
      'customerDetails': customerDetails.toJson(),
      'files': files?.map((file) => file.toJson()).toList(),
      'location': location ?? storage.read('locationId'),
      'physicalLocation': physicalLocation,
      'signatureFilePath': signatureFilePath,
      'salutationHTMLmarkup': salutationHTMLmarkup,
      'termsAndConditionsHTMLmarkup': termsAndConditionsHTMLmarkup,
      'receiptFooter': receiptFooter.toJson(),
      'printOption': printOption,
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
    List<File>? files,
    String? location,
    String? physicalLocation,
    String? signatureFilePath,
    String? salutationHTMLmarkup,
    String? termsAndConditionsHTMLmarkup,
    ReceiptFooter? receiptFooter,
    String? printOption,
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
    );
  }
}

class Files {
  List<File>? files;

  Files({this.files});

  Files.fromJson(Map<String, dynamic> json) {
    if (json['files'] != null) {
      files = <File>[];
      json['files'].forEach((v) {
        files!.add(File.fromJson(v));
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

class File {
  String? id;
  String? file;

  File({this.id, this.file});

  File.fromJson(Map<String, dynamic> json) {
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

  JobStatus({
    required this.title,
    required this.userId,
    required this.colorCode,
    required this.userName,
    required this.createAtStatus,
    required this.notifications,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'userId': userId,
      'colorCode': colorCode,
      'userName': userName,
      'createAtStatus': createAtStatus,
      'notifications': notifications,
      'notes': notes,
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

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
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
    return {
      'type': type,
      'customerId': customerId,
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
  final String message;
  final JobData? data;

  CreateJobResponse({required this.success, required this.message, this.data});

  factory CreateJobResponse.fromJson(Map<String, dynamic> json) {
    return CreateJobResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? JobData.fromJson(json['data']) : null,
    );
  }
}

class JobData {
  final String id;
  final String jobNo;

  JobData({required this.id, required this.jobNo});

  factory JobData.fromJson(Map<String, dynamic> json) {
    return JobData(id: json['_id'] ?? json['id'] ?? '', jobNo: json['jobNo'] ?? '');
  }

  JobData copyWith({String? id, String? jobNo}) {
    return JobData(id: id ?? this.id, jobNo: jobNo ?? this.jobNo);
  }
}
