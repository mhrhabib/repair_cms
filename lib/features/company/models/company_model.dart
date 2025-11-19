// Company Model
class CompanyModel {
  final String sId;
  final String name;
  final String companyEmail;
  final String companyName;
  final String telephone;
  final int employees;
  final String describeKindOf;
  final String kindOfService;
  final int numberOfUsers;
  final int numberOfLocations;
  final bool recurringPayment;
  final bool improveInventory;
  final String timeZone;
  final String dateFormat;
  final String timeFormat;
  final String currency;
  final String userId;
  final String createdAt;
  final String updatedAt;
  final int? defaultRejectAmount;
  final List<CompanyAddress>? companyAddress;
  final List<CompanyLogo>? companyLogo;
  final List<CompanyContactDetail>? companyContactDetail;
  final List<CompanyTaxDetail>? companyTaxDetail;
  final List<CompanyBankDetail>? companyBankDetail;

  CompanyModel({
    required this.sId,
    required this.name,
    required this.companyEmail,
    required this.companyName,
    required this.telephone,
    required this.employees,
    required this.describeKindOf,
    required this.kindOfService,
    required this.numberOfUsers,
    required this.numberOfLocations,
    required this.recurringPayment,
    required this.improveInventory,
    required this.timeZone,
    required this.dateFormat,
    required this.timeFormat,
    required this.currency,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.defaultRejectAmount,
    this.companyAddress,
    this.companyLogo,
    this.companyContactDetail,
    this.companyTaxDetail,
    this.companyBankDetail,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      sId: json['_id'] ?? '',
      name: json['name'] ?? '',
      companyEmail: json['companyEmail'] ?? '',
      companyName: json['companyName'] ?? '',
      telephone: json['telephone'] ?? '',
      employees: json['employees'] ?? 0,
      describeKindOf: json['describeKindOf'] ?? '',
      kindOfService: json['kindOfService'] ?? '',
      numberOfUsers: json['numberOfUsers'] ?? 0,
      numberOfLocations: json['numberOfLocations'] ?? 0,
      recurringPayment: json['recurringPayment'] ?? false,
      improveInventory: json['improveInventory'] ?? false,
      timeZone: json['timeZone'] ?? '',
      dateFormat: json['dateFormat'] ?? '',
      timeFormat: json['timeFormat'] ?? '',
      currency: json['currency'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      defaultRejectAmount: json['default_reject_amount'],
      companyAddress: json['company_address'] != null
          ? (json['company_address'] as List).map((e) => CompanyAddress.fromJson(e)).toList()
          : null,
      companyLogo: json['company_logo'] != null
          ? (json['company_logo'] as List).map((e) => CompanyLogo.fromJson(e)).toList()
          : null,
      companyContactDetail: json['company_contact_detail'] != null
          ? (json['company_contact_detail'] as List).map((e) => CompanyContactDetail.fromJson(e)).toList()
          : null,
      companyTaxDetail: json['company_tax_detail'] != null
          ? (json['company_tax_detail'] as List).map((e) => CompanyTaxDetail.fromJson(e)).toList()
          : null,
      companyBankDetail: json['company_bank_detail'] != null
          ? (json['company_bank_detail'] as List).map((e) => CompanyBankDetail.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'name': name,
      'companyEmail': companyEmail,
      'companyName': companyName,
      'telephone': telephone,
      'employees': employees,
      'describeKindOf': describeKindOf,
      'kindOfService': kindOfService,
      'numberOfUsers': numberOfUsers,
      'numberOfLocations': numberOfLocations,
      'recurringPayment': recurringPayment,
      'improveInventory': improveInventory,
      'timeZone': timeZone,
      'dateFormat': dateFormat,
      'timeFormat': timeFormat,
      'currency': currency,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'default_reject_amount': defaultRejectAmount,
      'company_address': companyAddress?.map((e) => e.toJson()).toList(),
      'company_logo': companyLogo?.map((e) => e.toJson()).toList(),
      'company_contact_detail': companyContactDetail?.map((e) => e.toJson()).toList(),
      'company_tax_detail': companyTaxDetail?.map((e) => e.toJson()).toList(),
      'company_bank_detail': companyBankDetail?.map((e) => e.toJson()).toList(),
    };
  }
}

class CompanyAddress {
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

  CompanyAddress({
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

  factory CompanyAddress.fromJson(Map<String, dynamic> json) {
    return CompanyAddress(
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

class CompanyLogo {
  final String sId;
  final String image;
  final String openingHours;
  final String companyId;
  final String createdAt;
  final String updatedAt;

  CompanyLogo({
    required this.sId,
    required this.image,
    required this.openingHours,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyLogo.fromJson(Map<String, dynamic> json) {
    return CompanyLogo(
      sId: json['_id'] ?? '',
      image: json['image'] ?? '',
      openingHours: json['openingHours'] ?? '',
      companyId: json['companyId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'image': image,
      'openingHours': openingHours,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CompanyContactDetail {
  final String sId;
  final String telephone;
  final String fax;
  final String email;
  final String website;
  final String companyId;
  final String createdAt;
  final String updatedAt;

  CompanyContactDetail({
    required this.sId,
    required this.telephone,
    required this.fax,
    required this.email,
    required this.website,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyContactDetail.fromJson(Map<String, dynamic> json) {
    return CompanyContactDetail(
      sId: json['_id'] ?? '',
      telephone: json['telephone'] ?? '',
      fax: json['fax'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      companyId: json['companyId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'telephone': telephone,
      'fax': fax,
      'email': email,
      'website': website,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CompanyTaxDetail {
  final String sId;
  final String registrationNum;
  final String uidTaxId;
  final String taxIdentification;
  final String defaultTax;
  final String ceo;
  final String companyId;
  final String createdAt;
  final String updatedAt;

  CompanyTaxDetail({
    required this.sId,
    required this.registrationNum,
    required this.uidTaxId,
    required this.taxIdentification,
    required this.defaultTax,
    required this.ceo,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyTaxDetail.fromJson(Map<String, dynamic> json) {
    return CompanyTaxDetail(
      sId: json['_id'] ?? '',
      registrationNum: json['registrationNum'] ?? '',
      uidTaxId: json['uidTaxId'] ?? '',
      taxIdentification: json['taxIdentification'] ?? '',
      defaultTax: json['default'] ?? '',
      ceo: json['ceo'] ?? '',
      companyId: json['companyId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'registrationNum': registrationNum,
      'uidTaxId': uidTaxId,
      'taxIdentification': taxIdentification,
      'default': defaultTax,
      'ceo': ceo,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class CompanyBankDetail {
  final String sId;
  final String bankName;
  final String iban;
  final String bic;
  final String companyId;
  final String createdAt;
  final String updatedAt;

  CompanyBankDetail({
    required this.sId,
    required this.bankName,
    required this.iban,
    required this.bic,
    required this.companyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CompanyBankDetail.fromJson(Map<String, dynamic> json) {
    return CompanyBankDetail(
      sId: json['_id'] ?? '',
      bankName: json['bankName'] ?? '',
      iban: json['iban'] ?? '',
      bic: json['bic'] ?? '',
      companyId: json['companyId'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'bankName': bankName,
      'iban': iban,
      'bic': bic,
      'companyId': companyId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
