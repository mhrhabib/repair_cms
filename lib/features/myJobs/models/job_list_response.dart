// models/job_model.dart
import 'package:repair_cms/core/app_exports.dart';

class JobListResponse {
  final bool success;
  final dynamic totalJobs;
  final dynamic serviceRequestJobs;
  final dynamic total;
  final dynamic pages;
  final dynamic page;
  final dynamic limit;
  final List<Job> results;

  JobListResponse({
    required this.success,
    required this.totalJobs,
    required this.serviceRequestJobs,
    required this.total,
    required this.pages,
    required this.page,
    required this.limit,
    required this.results,
  });

  factory JobListResponse.fromJson(Map<String, dynamic> json) {
    return JobListResponse(
      success: json['success'] ?? false,
      totalJobs: json['totalJobs'] ?? 0,
      serviceRequestJobs: json['serviceRequestJobs'] ?? 0,
      total: json['total'] ?? 0,
      pages: json['pages'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      results: (json['results'] as List<dynamic>?)?.map((job) => Job.fromJson(job)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'totalJobs': totalJobs,
      'serviceRequestJobs': serviceRequestJobs,
      'total': total,
      'pages': pages,
      'page': page,
      'limit': limit,
      'results': results.map((job) => job.toJson()).toList(),
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
  final dynamic jobNo;
  final String? customerId;
  final List<String> assignedItemsIds;
  final bool emailConfirmation;
  // final List<JobFile> files;
  final bool printDeviceLabel;
  final List<JobStatus> jobStatus;
  final CustomerDetails customerDetails;
  final String status;
  final String? location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;
  final String? jobTrackingNumber;
  final String? physicalLocation;
  final String? printOption;
  final String? signatureFilePath;
  final DeviceData deviceData;
  final List<Service> services;
  final List<AssignedItem> assignedItems;
  final List<Device> device;
  final List<Contact> contact;
  final List<Defect> defect;

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
    this.customerId,
    required this.assignedItemsIds,
    required this.emailConfirmation,
    // required this.files,
    required this.printDeviceLabel,
    required this.jobStatus,
    required this.customerDetails,
    required this.status,
    this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.jobTrackingNumber,
    this.physicalLocation,
    this.printOption,
    this.signatureFilePath,
    required this.deviceData,
    required this.services,
    required this.assignedItems,
    required this.device,
    required this.contact,
    required this.defect,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['_id'] ?? '',
      jobType: json['jobType'] ?? '',
      jobTypes: json['jobTypes'] ?? '',
      model: json['model'],
      servicesIds: (json['servicesIds'] as List<dynamic>?)?.cast<String>() ?? [],
      deviceId: json['deviceId'] ?? '',
      jobContactId: json['jobContactId'] ?? '',
      defectId: json['defectId'] ?? '',
      subTotal: json['subTotal'] ?? '0',
      total: json['total'] ?? '0',
      vat: json['vat'] ?? '0',
      discount: json['discount'] ?? '0',
      jobNo: json['jobNo'] ?? '',
      customerId: json['customerId'],
      assignedItemsIds: (json['assignedItemsIds'] as List<dynamic>?)?.cast<String>() ?? [],
      emailConfirmation: json['emailConfirmation'] ?? false,
      // files: (json['files'] as List<dynamic>?)?.map((file) => JobFile.fromJson(file)).toList() ?? [],
      printDeviceLabel: json['printDeviceLabel'] ?? false,
      jobStatus: (json['jobStatus'] as List<dynamic>?)?.map((status) => JobStatus.fromJson(status)).toList() ?? [],
      customerDetails: CustomerDetails.fromJson(json['customerDetails'] ?? {}),
      status: json['status'] ?? '',
      location: json['location'],
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
      jobTrackingNumber: json['job_tracking_number'],
      physicalLocation: json['physicalLocation'],
      printOption: json['printOption'],
      signatureFilePath: json['signatureFilePath'],
      deviceData: DeviceData.fromJson(json['deviceData'] ?? {}),
      services: (json['services'] as List<dynamic>?)?.map((service) => Service.fromJson(service)).toList() ?? [],
      assignedItems:
          (json['assignedItems'] as List<dynamic>?)?.map((item) => AssignedItem.fromJson(item)).toList() ?? [],
      device: (json['device'] as List<dynamic>?)?.map((device) => Device.fromJson(device)).toList() ?? [],
      contact: (json['contact'] as List<dynamic>?)?.map((contact) => Contact.fromJson(contact)).toList() ?? [],
      defect: (json['defect'] as List<dynamic>?)?.map((defect) => Defect.fromJson(defect)).toList() ?? [],
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
      // 'files': files.map((file) => file.toJson()).toList(),
      'printDeviceLabel': printDeviceLabel,
      'jobStatus': jobStatus.map((status) => status.toJson()).toList(),
      'customerDetails': customerDetails.toJson(),
      'status': status,
      'location': location,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'job_tracking_number': jobTrackingNumber,
      'physicalLocation': physicalLocation,
      'printOption': printOption,
      'signatureFilePath': signatureFilePath,
      'deviceData': deviceData.toJson(),
      'services': services.map((service) => service.toJson()).toList(),
      'assignedItems': assignedItems.map((item) => item.toJson()).toList(),
      'device': device.map((device) => device.toJson()).toList(),
      'contact': contact.map((contact) => contact.toJson()).toList(),
      'defect': defect.map((defect) => defect.toJson()).toList(),
    };
  }

  // Helper methods
  String get customerName {
    return '${customerDetails.firstName} ${customerDetails.lastName}'.trim();
  }

  String get deviceInfo {
    return '${deviceData.brand} ${model ?? deviceData.model}'.trim();
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  String get formattedAmount {
    return '€$total';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'complete':
        return Colors.green;
      case 'in progress':
        return Colors.orange;
      case 'booked':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// class JobFile {
//   final String file;
//   final String id;
//   final String? fileName;
//   final int? size;

//   JobFile({required this.file, required this.id, this.fileName, this.size});

//   factory JobFile.fromJson(Map<String, dynamic> json) {
//     return JobFile(file: json['file'], id: json['id'] ?? '', fileName: json['fileName'], size: json['size']);
//   }

//   Map<String, dynamic> toJson() {
//     return {'file': file, 'id': id, 'fileName': fileName, 'size': size};
//   }
// }

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
    this.priority,
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
  final String type;
  final String type2;
  final String organization;
  final String customerNo;
  final String email;
  final String telephone;
  final Address shippingAddress;
  final Address billingAddress;
  final String salutation;
  final String firstName;
  final String lastName;
  final String position;
  final List<ContactPerson>? contactPersons;

  CustomerDetails({
    required this.customerId,
    required this.type,
    required this.type2,
    required this.organization,
    required this.customerNo,
    required this.email,
    required this.telephone,
    required this.shippingAddress,
    required this.billingAddress,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.position,
    this.contactPersons,
  });

  factory CustomerDetails.fromJson(Map<String, dynamic> json) {
    return CustomerDetails(
      customerId: json['customerId'] ?? '',
      type: json['type'] ?? '',
      type2: json['type2'] ?? '',
      organization: json['organization'] ?? '',
      customerNo: json['customerNo'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      shippingAddress: Address.fromJson(json['shipping_address'] ?? {}),
      billingAddress: Address.fromJson(json['billing_address'] ?? {}),
      salutation: json['salutation'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      position: json['position'] ?? '',
      contactPersons: (json['contact_persons'] as List<dynamic>?)
          ?.map((person) => ContactPerson.fromJson(person))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'type': type,
      'type2': type2,
      'organization': organization,
      'customerNo': customerNo,
      'email': email,
      'telephone': telephone,
      'shipping_address': shippingAddress.toJson(),
      'billing_address': billingAddress.toJson(),
      'salutation': salutation,
      'firstName': firstName,
      'lastName': lastName,
      'position': position,
      'contact_persons': contactPersons?.map((person) => person.toJson()).toList(),
    };
  }
}

class Address {
  final String id;
  final String street;
  final String num;
  final String zip;
  final String city;
  final String country;
  final bool primary;
  final String customerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int v;

  Address({
    required this.id,
    required this.street,
    required this.num,
    required this.zip,
    required this.city,
    required this.country,
    required this.primary,
    required this.customerId,
    this.createdAt,
    this.updatedAt,
    required this.v,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'] ?? '',
      street: json['street'] ?? '',
      num: json['num'] ?? json['street_no'] ?? '',
      zip: json['zip'] ?? json['zip_code'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      primary: json['primary'] ?? false,
      customerId: json['customerId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'street': street,
      'num': num,
      'zip': zip,
      'city': city,
      'country': country,
      'primary': primary,
      'customerId': customerId,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }

  String get formattedAddress {
    return '$street $num, $zip $city, $country';
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
  final String id;
  final String brand;
  final String? model;
  final String? category;
  final String? imei;
  final List<Condition> condition;
  final List<Accessory> accessories;
  final List<SecurityLock> securityLock;
  final String? color;
  final String? serialNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  DeviceData({
    required this.id,
    required this.brand,
    this.model,
    this.category,
    this.imei,
    required this.condition,
    required this.accessories,
    required this.securityLock,
    this.color,
    this.serialNo,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory DeviceData.fromJson(Map<String, dynamic> json) {
    return DeviceData(
      id: json['_id'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'],
      category: json['category'],
      imei: json['imei'],
      condition: (json['condition'] as List<dynamic>?)?.map((cond) => Condition.fromJson(cond)).toList() ?? [],
      accessories: (json['accessories'] as List<dynamic>?)?.map((acc) => Accessory.fromJson(acc)).toList() ?? [],
      securityLock: (json['securityLock'] as List<dynamic>?)?.map((lock) => SecurityLock.fromJson(lock)).toList() ?? [],
      color: json['color'],
      serialNo: json['serial_no'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
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
      'accessories': accessories.map((acc) => acc.toJson()).toList(),
      'securityLock': securityLock.map((lock) => lock.toJson()).toList(),
      'color': color,
      'serial_no': serialNo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Condition {
  final String value;
  final String id;

  Condition({required this.value, required this.id});

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(value: json['value'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'id': id};
  }
}

class Accessory {
  final String value;
  final String id;

  Accessory({required this.value, required this.id});

  factory Accessory.fromJson(Map<String, dynamic> json) {
    return Accessory(value: json['value'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'id': id};
  }
}

class SecurityLock {
  final String value;
  final String id;

  SecurityLock({required this.value, required this.id});

  factory SecurityLock.fromJson(Map<String, dynamic> json) {
    return SecurityLock(value: json['value'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'id': id};
  }
}

class Service {
  final String id;
  final String name;
  final String serviceId;
  final String? description;
  final dynamic vat;
  final dynamic priceInclVat;
  final dynamic priceExclVat;
  final String? manufacturer;
  final String? model;
  final String? category;
  final List<dynamic> tags;
  final List<ServiceImage> images;
  final List<AssignedItem> assignedItems;
  final String? location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Service({
    required this.id,
    required this.name,
    required this.serviceId,
    this.description,
    required this.vat,
    required this.priceInclVat,
    required this.priceExclVat,
    this.manufacturer,
    this.model,
    this.category,
    required this.tags,
    required this.images,
    required this.assignedItems,
    this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      serviceId: json['serviceId'] ?? '',
      description: json['description'],
      vat: json['vat'] ?? '',
      priceInclVat: json['price_incl_vat'] ?? '',
      priceExclVat: json['price_excl_vat'] ?? '',
      manufacturer: json['manufacturer'],
      model: json['model'],
      category: json['category'],
      tags: json['tags'] ?? [],
      images: (json['images'] as List<dynamic>?)?.map((image) => ServiceImage.fromJson(image)).toList() ?? [],
      assignedItems:
          (json['assignedItems'] as List<dynamic>?)?.map((item) => AssignedItem.fromJson(item)).toList() ?? [],
      location: json['location'],
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'serviceId': serviceId,
      'description': description,
      'vat': vat,
      'price_incl_vat': priceInclVat,
      'price_excl_vat': priceExclVat,
      'manufacturer': manufacturer,
      'model': model,
      'category': category,
      'tags': tags,
      'images': images.map((image) => image.toJson()).toList(),
      'assignedItems': assignedItems.map((item) => item.toJson()).toList(),
      'location': location,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class ServiceImage {
  final bool favourite;
  final String path;
  final String id;

  ServiceImage({required this.favourite, required this.path, required this.id});

  factory ServiceImage.fromJson(Map<String, dynamic> json) {
    return ServiceImage(favourite: json['favourite'] ?? false, path: json['path'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'favourite': favourite, 'path': path, 'id': id};
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
  final dynamic manufacturerNumber;
  final String physicalLocation;
  final String color;
  final String condition;
  final dynamic vatPercent;
  final int profitMarkup;
  final String profitMarkupSymbol;
  final String description;
  final double purchasePriceExlVat;
  final double purchasePriceIncVat;
  final double salePriceExlVat;
  final double salePriceIncVat;
  final List<dynamic> barcode;
  final List<dynamic> supplierPriceList;
  final List<dynamic> supplierList;
  final bool serialNoManagement;
  final String location;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  AssignedItem({
    required this.id,
    required this.productName,
    required this.itemNumber,
    required this.stockValue,
    required this.stockUnit,
    required this.manufacturer,
    required this.category,
    required this.manufacturerNumber,
    required this.physicalLocation,
    required this.color,
    required this.condition,
    required this.vatPercent,
    required this.profitMarkup,
    required this.profitMarkupSymbol,
    required this.description,
    required this.purchasePriceExlVat,
    required this.purchasePriceIncVat,
    required this.salePriceExlVat,
    required this.salePriceIncVat,
    required this.barcode,
    required this.supplierPriceList,
    required this.supplierList,
    required this.serialNoManagement,
    required this.location,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory AssignedItem.fromJson(Map<String, dynamic> json) {
    return AssignedItem(
      id: json['_id'] ?? '',
      productName: json['productName'] ?? '',
      itemNumber: json['itemNumber'],
      stockValue: json['stockValue'] ?? 0,
      stockUnit: json['stockUnit'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      category: json['category'] ?? '',
      manufacturerNumber: json['manufacturerNumber'],
      physicalLocation: json['physicalLocation'] ?? '',
      color: json['color'] ?? '',
      condition: json['condition'] ?? '',
      vatPercent: json['vatPercent'] ?? 0,
      profitMarkup: json['profitMarkup'] ?? 0,
      profitMarkupSymbol: json['profitMarkupSymbol'] ?? '%',
      description: json['description'] ?? '',
      purchasePriceExlVat: (json['purchasePriceExlVat'] ?? 0).toDouble(),
      purchasePriceIncVat: (json['purchasePriceIncVat'] ?? 0).toDouble(),
      salePriceExlVat: (json['salePriceExlVat'] ?? 0).toDouble(),
      salePriceIncVat: (json['salePriceIncVat'] ?? 0).toDouble(),
      barcode: json['barcode'] ?? [],
      supplierPriceList: json['supplierPriceList'] ?? [],
      supplierList: json['supplierList'] ?? [],
      serialNoManagement: json['serialNoManagement'] ?? false,
      location: json['location'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
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
      'manufacturerNumber': manufacturerNumber,
      'physicalLocation': physicalLocation,
      'color': color,
      'condition': condition,
      'vatPercent': vatPercent,
      'profitMarkup': profitMarkup,
      'profitMarkupSymbol': profitMarkupSymbol,
      'description': description,
      'purchasePriceExlVat': purchasePriceExlVat,
      'purchasePriceIncVat': purchasePriceIncVat,
      'salePriceExlVat': salePriceExlVat,
      'salePriceIncVat': salePriceIncVat,
      'barcode': barcode,
      'supplierPriceList': supplierPriceList,
      'supplierList': supplierList,
      'serialNoManagement': serialNoManagement,
      'location': location,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Device {
  final String id;
  final String brand;
  final String? model;
  final String? category;
  final String? imei;
  final List<Condition> condition;
  final List<Accessory> accessories;
  final List<SecurityLock> securityLock;
  final String? color;
  final String? serialNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Device({
    required this.id,
    required this.brand,
    this.model,
    this.category,
    this.imei,
    required this.condition,
    required this.accessories,
    required this.securityLock,
    this.color,
    this.serialNo,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['_id'] ?? '',
      brand: json['brand'] ?? '',
      model: json['model'],
      category: json['category'],
      imei: json['imei'],
      condition: (json['condition'] as List<dynamic>?)?.map((cond) => Condition.fromJson(cond)).toList() ?? [],
      accessories: (json['accessories'] as List<dynamic>?)?.map((acc) => Accessory.fromJson(acc)).toList() ?? [],
      securityLock: (json['securityLock'] as List<dynamic>?)?.map((lock) => SecurityLock.fromJson(lock)).toList() ?? [],
      color: json['color'],
      serialNo: json['serial_no'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
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
      'accessories': accessories.map((acc) => acc.toJson()).toList(),
      'securityLock': securityLock.map((lock) => lock.toJson()).toList(),
      'color': color,
      'serial_no': serialNo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
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
  final int v;

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
    required this.v,
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
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
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
      '__v': v,
    };
  }
}

class Defect {
  final String id;
  final List<DefectItem> defect;
  final String jobType;
  final String? reference;
  final String? description;
  final List<InternalNote> internalNote;
  final List<String> assignItems;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Defect({
    required this.id,
    required this.defect,
    required this.jobType,
    this.reference,
    this.description,
    required this.internalNote,
    required this.assignItems,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Defect.fromJson(Map<String, dynamic> json) {
    return Defect(
      id: json['_id'] ?? '',
      defect: (json['defect'] as List<dynamic>?)?.map((defect) => DefectItem.fromJson(defect)).toList() ?? [],
      jobType: json['jobType'] ?? '',
      reference: json['reference'],
      description: json['description'],
      internalNote: (json['internalNote'] as List<dynamic>?)?.map((note) => InternalNote.fromJson(note)).toList() ?? [],
      assignItems: (json['assignItems'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'defect': defect.map((defect) => defect.toJson()).toList(),
      'jobType': jobType,
      'reference': reference,
      'description': description,
      'internalNote': internalNote.map((note) => note.toJson()).toList(),
      'assignItems': assignItems,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class DefectItem {
  final String value;
  final String id;

  DefectItem({required this.value, required this.id});

  factory DefectItem.fromJson(Map<String, dynamic> json) {
    return DefectItem(value: json['value'] ?? '', id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'value': value, 'id': id};
  }
}

class InternalNote {
  final String text;
  final String userName;
  final String id;
  final int createdAt;
  final String userId;

  InternalNote({
    required this.text,
    required this.userName,
    required this.id,
    required this.createdAt,
    required this.userId,
  });

  factory InternalNote.fromJson(Map<String, dynamic> json) {
    return InternalNote(
      text: json['text'] ?? '',
      userName: json['userName'] ?? '',
      id: json['id'] ?? '',
      createdAt: json['createdAt'] ?? 0,
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'userName': userName, 'id': id, 'createdAt': createdAt, 'userId': userId};
  }
}
