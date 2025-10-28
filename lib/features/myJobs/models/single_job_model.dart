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
  String? deviceType;
  String? model;
  List<String>? servicesIds;
  String? deviceId;
  String? jobContactId;
  String? defectId;
  List<String>? assignedItemsIds;
  String? physicalLocation;
  bool? emailConfirmation;
  List<String>? files;
  String? signatureFilePath;
  String? printOption;
  bool? printDeviceLabel;
  String? jobStatus;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  List<Services>? services;
  List<String>? assignedItems;
  List<Device>? device;
  List<Contact>? contact;
  List<Defect>? defect;

  Data({
    this.sId,
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
    this.iV,
    this.services,
    this.assignedItems,
    this.device,
    this.contact,
    this.defect,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    jobType = json['jobType'];
    deviceType = json['deviceType'];
    model = json['model'];
    servicesIds = json['servicesIds'].cast<String>();
    deviceId = json['deviceId'];
    jobContactId = json['jobContactId'];
    defectId = json['defectId'];
    assignedItemsIds = List<String>.from(json['assignedItemsIds'] ?? []);
    physicalLocation = json['physicalLocation'];
    emailConfirmation = json['emailConfirmation'];
    files = json['files'].cast<String>();
    signatureFilePath = json['signatureFilePath'];
    printOption = json['printOption'];
    printDeviceLabel = json['printDeviceLabel'];
    jobStatus = json['jobStatus'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(Services.fromJson(v));
      });
    }
    assignedItems = json['assignedItems'] != null ? List<String>.from(json['assignedItems']) : [];
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
        defect!.add(Defect.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['jobType'] = jobType;
    data['deviceType'] = deviceType;
    data['model'] = model;
    data['servicesIds'] = servicesIds;
    data['deviceId'] = deviceId;
    data['jobContactId'] = jobContactId;
    data['defectId'] = defectId;
    data['assignedItemsIds'] = assignedItemsIds;
    data['physicalLocation'] = physicalLocation;
    data['emailConfirmation'] = emailConfirmation;
    data['files'] = files;
    data['signatureFilePath'] = signatureFilePath;
    data['printOption'] = printOption;
    data['printDeviceLabel'] = printDeviceLabel;
    data['jobStatus'] = jobStatus;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    data['assignedItems'] = assignedItems;
    if (device != null) {
      data['device'] = device!.map((v) => v.toJson()).toList();
    }
    if (contact != null) {
      data['contact'] = contact!.map((v) => v.toJson()).toList();
    }
    if (defect != null) {
      data['defect'] = defect!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  String? sId;
  String? name;
  String? serviceId;
  String? description;
  String? manufacturer;
  String? model;
  List<String>? tags;
  List<Images>? images;
  List<String>? assignedItems;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? category;
  String? priceExclVat;
  String? priceInclVat;
  String? vat;

  Services({
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
    this.iV,
    this.category,
    this.priceExclVat,
    this.priceInclVat,
    this.vat,
  });

  Services.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    serviceId = json['serviceId'];
    description = json['description'];
    manufacturer = json['manufacturer'];
    model = json['model'];
    if (json['tags'] != null) {
      tags = <String>[];
      json['tags'].forEach((v) {
        tags!.add(v);
      });
    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
    if (json['assignedItems'] != null) {
      assignedItems = <String>[];
      json['assignedItems'].forEach((v) {
        assignedItems!.add(v);
      });
    }
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    category = json['category'];
    priceExclVat = json['price_excl_vat'];
    priceInclVat = json['price_incl_vat'];
    vat = json['vat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['serviceId'] = serviceId;
    data['description'] = description;
    data['manufacturer'] = manufacturer;
    data['model'] = model;
    if (tags != null) {
      data['tags'] = tags!.map((v) => v).toList();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    if (assignedItems != null) {
      data['assignedItems'] = assignedItems!.map((v) => v).toList();
    }
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['category'] = category;
    data['price_excl_vat'] = priceExclVat;
    data['price_incl_vat'] = priceInclVat;
    data['vat'] = vat;
    return data;
  }
}

class Images {
  String? path;
  bool? favourite;

  Images({this.path, this.favourite});

  Images.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    favourite = json['favourite'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    data['favourite'] = favourite;
    return data;
  }
}

class Device {
  String? sId;
  String? brand;
  String? model;
  String? imei;
  String? condition;
  String? deviceSecurity;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Device({
    this.sId,
    this.brand,
    this.model,
    this.imei,
    this.condition,
    this.deviceSecurity,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Device.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    brand = json['brand'];
    model = json['model'];
    imei = json['imei'];
    condition = json['condition'];
    deviceSecurity = json['deviceSecurity'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['brand'] = brand;
    data['model'] = model;
    data['imei'] = imei;
    data['condition'] = condition;
    data['deviceSecurity'] = deviceSecurity;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Contact {
  String? sId;
  String? type;
  String? salutation;
  String? title;
  String? firstName;
  String? lastName;
  String? telephone;
  String? email;
  String? street;
  String? streetNum;
  String? zip;
  String? city;
  String? country;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Contact({
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
    this.iV,
  });

  Contact.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    type = json['type'];
    salutation = json['salutation'];
    title = json['title'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    telephone = json['telephone'];
    email = json['email'];
    street = json['street'];
    streetNum = json['streetNum'];
    zip = json['zip'];
    city = json['city'];
    country = json['country'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['type'] = type;
    data['salutation'] = salutation;
    data['title'] = title;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['telephone'] = telephone;
    data['email'] = email;
    data['street'] = street;
    data['streetNum'] = streetNum;
    data['zip'] = zip;
    data['city'] = city;
    data['country'] = country;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class Defect {
  String? sId;
  String? defect;
  String? description;
  String? internalNote;
  List<String>? assignItems;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Defect({
    this.sId,
    this.defect,
    this.description,
    this.internalNote,
    this.assignItems,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  Defect.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    defect = json['defect'];
    description = json['description'];
    internalNote = json['internalNote'];
    assignItems = json['assignItems'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['defect'] = defect;
    data['description'] = description;
    data['internalNote'] = internalNote;
    data['assignItems'] = assignItems;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}
