// Job Receipt Model
class JobReceiptModel {
  final String sId;
  final ReceiptAddress? address;
  final String salutation;
  final String termsAndConditions;
  final bool qrCodeEnabled;
  final String footer;
  final String userId;
  final String createdAt;
  final String updatedAt;
  final bool? enableTelephoneNumber;

  JobReceiptModel({
    required this.sId,
    this.address,
    required this.salutation,
    required this.termsAndConditions,
    required this.qrCodeEnabled,
    required this.footer,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.enableTelephoneNumber,
  });

  factory JobReceiptModel.fromJson(Map<String, dynamic> json) {
    return JobReceiptModel(
      sId: json['_id'] ?? json['id'] ?? '',
      address: json['address'] != null ? ReceiptAddress.fromJson(json['address']) : null,
      salutation: json['salutation'] ?? '',
      termsAndConditions: json['termsAndConditions'] ?? '',
      qrCodeEnabled: json['qrCodeEnabled'] ?? false,
      footer: json['footer'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      enableTelephoneNumber: json['enableTelephoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'address': address?.toJson(),
      'salutation': salutation,
      'termsAndConditions': termsAndConditions,
      'qrCodeEnabled': qrCodeEnabled,
      'footer': footer,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'enableTelephoneNumber': enableTelephoneNumber,
    };
  }
}

class ReceiptAddress {
  final String sId;
  final String country;
  final String companyId;
  final String createdAt;
  final String updatedAt;
  final String? city;
  final String? num;
  final String? organization;
  final String? street;
  final String? zip;

  ReceiptAddress({
    required this.sId,
    required this.country,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.city,
    this.num,
    this.organization,
    this.street,
    this.zip,
  });

  factory ReceiptAddress.fromJson(Map<String, dynamic> json) {
    return ReceiptAddress(
      sId: json['_id'] ?? '',
      country: json['country'] ?? '',
      companyId: json['companyId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      city: json['city'],
      num: json['num'],
      organization: json['organization'],
      street: json['street'],
      zip: json['zip'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'country': country,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'city': city,
      'num': num,
      'organization': organization,
      'street': street,
      'zip': zip,
    };
  }
}
