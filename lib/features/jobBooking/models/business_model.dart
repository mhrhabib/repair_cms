class BusinessModel {
  int? totalCustomersOrSupplier;
  List<Customersorsuppliers>? customersorsuppliers;

  BusinessModel({this.totalCustomersOrSupplier, this.customersorsuppliers});

  BusinessModel.fromJson(Map<String, dynamic> json) {
    totalCustomersOrSupplier = json['totalCustomersOrSupplier'];
    if (json['customersorsuppliers'] != null) {
      customersorsuppliers = <Customersorsuppliers>[];
      json['customersorsuppliers'].forEach((v) {
        customersorsuppliers!.add(Customersorsuppliers.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalCustomersOrSupplier'] = totalCustomersOrSupplier;
    if (customersorsuppliers != null) {
      data['customersorsuppliers'] = customersorsuppliers!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Customersorsuppliers {
  String? sId;
  String? type;
  String? type2;
  String? customerNumber;
  String? firstName;
  String? lastName;
  String? organization;
  String? position;
  String? location;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<BillingAddresses>? billingAddresses;
  List<ShippingAddresses>? shippingAddresses;
  List<CustomerBankDetails>? customerBankDetails;
  List<CustomerContactDetail>? customerContactDetail;

  String? supplierName;

  Customersorsuppliers({
    this.sId,
    this.type,
    this.type2,
    this.customerNumber,
    this.firstName,
    this.lastName,
    this.organization,
    this.position,
    this.location,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.billingAddresses,
    this.shippingAddresses,
    this.customerBankDetails,
    this.customerContactDetail,
  });

  Customersorsuppliers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    type2 = json['type2'];
    customerNumber = json['customerNumber'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    organization = json['organization'];
    position = json['position'];
    location = json['location'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    if (json['billing_addresses'] != null) {
      billingAddresses = <BillingAddresses>[];
      json['billing_addresses'].forEach((v) {
        billingAddresses!.add(BillingAddresses.fromJson(v));
      });
    }
    if (json['shipping_addresses'] != null) {
      shippingAddresses = <ShippingAddresses>[];
      json['shipping_addresses'].forEach((v) {
        shippingAddresses!.add(ShippingAddresses.fromJson(v));
      });
    }
    if (json['customer_bank_details'] != null) {
      customerBankDetails = <CustomerBankDetails>[];
      json['customer_bank_details'].forEach((v) {
        customerBankDetails!.add(CustomerBankDetails.fromJson(v));
      });
    }
    if (json['CustomerContactDetail'] != null) {
      customerContactDetail = <CustomerContactDetail>[];
      json['CustomerContactDetail'].forEach((v) {
        customerContactDetail!.add(CustomerContactDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['type2'] = type2;
    data['customerNumber'] = customerNumber;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['organization'] = organization;
    data['position'] = position;
    data['location'] = location;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (billingAddresses != null) {
      data['billing_addresses'] = billingAddresses!.map((v) => v.toJson()).toList();
    }
    if (shippingAddresses != null) {
      data['shipping_addresses'] = shippingAddresses!.map((v) => v.toJson()).toList();
    }
    if (customerBankDetails != null) {
      data['customer_bank_details'] = customerBankDetails!.map((v) => v.toJson()).toList();
    }
    if (customerContactDetail != null) {
      data['CustomerContactDetail'] = customerContactDetail!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class BillingAddresses {
  String? sId;
  bool? primary;
  String? street;
  String? zip;
  String? city;
  String? country;
  String? customerId;
  int? iV;

  BillingAddresses({this.sId, this.primary, this.street, this.zip, this.city, this.country, this.customerId, this.iV});

  BillingAddresses.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    primary = json['primary'];
    street = json['street'];
    zip = json['zip'];
    city = json['city'];
    country = json['country'];
    customerId = json['customerId'];
    iV = json['__v'];
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
    return data;
  }
}

class ShippingAddresses {
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

  ShippingAddresses({
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

  ShippingAddresses.fromJson(Map<String, dynamic> json) {
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

class CustomerBankDetails {
  String? sId;
  String? iban;
  String? bic;
  String? vatNo;
  bool? reverseCharge;
  String? customerId;
  int? iV;

  CustomerBankDetails({this.sId, this.iban, this.bic, this.vatNo, this.reverseCharge, this.customerId, this.iV});

  CustomerBankDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    iban = json['iban'];
    bic = json['bic'];
    vatNo = json['vatNo'];
    reverseCharge = json['reverseCharge'];
    customerId = json['customerId'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['iban'] = iban;
    data['bic'] = bic;
    data['vatNo'] = vatNo;
    data['reverseCharge'] = reverseCharge;
    data['customerId'] = customerId;
    data['__v'] = iV;
    return data;
  }
}

class CustomerContactDetail {
  String? sId;
  String? customerId;
  int? iV;
  List<CustomerTelephones>? customerTelephones;
  List<CustomerEmails>? customerEmails;

  CustomerContactDetail({this.sId, this.customerId, this.iV, this.customerTelephones, this.customerEmails});

  CustomerContactDetail.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    customerId = json['customerId'];
    iV = json['__v'];
    if (json['customer_telephones'] != null) {
      customerTelephones = <CustomerTelephones>[];
      json['customer_telephones'].forEach((v) {
        customerTelephones!.add(CustomerTelephones.fromJson(v));
      });
    }
    if (json['CustomerEmails'] != null) {
      customerEmails = <CustomerEmails>[];
      json['CustomerEmails'].forEach((v) {
        customerEmails!.add(CustomerEmails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['customerId'] = customerId;
    data['__v'] = iV;
    if (customerTelephones != null) {
      data['customer_telephones'] = customerTelephones!.map((v) => v.toJson()).toList();
    }
    if (customerEmails != null) {
      data['CustomerEmails'] = customerEmails!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class CustomerTelephones {
  String? sId;
  String? number;
  String? phonePrefix;
  String? type;
  bool? isPrimary;
  String? customerContactId;
  int? iV;

  CustomerTelephones({
    this.sId,
    this.number,
    this.phonePrefix,
    this.type,
    this.isPrimary,
    this.customerContactId,
    this.iV,
  });

  CustomerTelephones.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    number = json['number'];
    phonePrefix = json['phone_prefix'];
    type = json['type'];
    isPrimary = json['is_primary'];
    customerContactId = json['customerContactId'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['number'] = number;
    data['phone_prefix'] = phonePrefix;
    data['type'] = type;
    data['is_primary'] = isPrimary;
    data['customerContactId'] = customerContactId;
    data['__v'] = iV;
    return data;
  }
}

class CustomerEmails {
  String? sId;
  String? email;
  bool? isPrimary;
  String? customerContactId;
  int? iV;

  CustomerEmails({this.sId, this.email, this.isPrimary, this.customerContactId, this.iV});

  CustomerEmails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    isPrimary = json['is_primary'];
    customerContactId = json['customerContactId'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['is_primary'] = isPrimary;
    data['customerContactId'] = customerContactId;
    data['__v'] = iV;
    return data;
  }
}
