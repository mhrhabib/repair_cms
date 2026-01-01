import 'package:repair_cms/features/myJobs/models/single_job_model.dart';

class ConversationModel {
  bool? success;
  List<Conversation>? data;
  dynamic pages;
  dynamic total;
  String? error;
  String? message;

  ConversationModel({this.success, this.data, this.pages, this.total, this.error, this.message});

  ConversationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Conversation>[];
      json['data'].forEach((v) {
        data!.add(Conversation.fromJson(v));
      });
    }
    pages = json['pages'];
    total = json['total'];
    error = json['error'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['pages'] = pages;
    data['total'] = total;
    data['error'] = error;
    data['message'] = message;
    return data;
  }
}

class Conversation {
  String? sId;
  Sender? sender;
  Sender? receiver;
  String? conversationId;
  Message? message;
  Comment? comment;
  List<Comment>? comments;
  bool? seen;
  List<ServiceItemList>? serviceItemList;
  String? participants;
  String? loggedUserId;
  UserId? userId;
  String? createdAt;
  String? updatedAt;
  dynamic iV;
  String? id;

  Conversation({
    this.sId,
    this.sender,
    this.receiver,
    this.conversationId,
    this.message,
    this.comment,
    this.seen,
    this.serviceItemList,
    this.participants,
    this.loggedUserId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
  });

  Conversation.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    sender = json['sender'] != null ? Sender.fromJson(json['sender']) : null;
    receiver = json['receiver'] != null ? Sender.fromJson(json['receiver']) : null;
    conversationId = json['conversationId'];
    message = json['message'] != null ? Message.fromJson(json['message']) : null;
    comment = json['comment'] != null ? Comment.fromJson(json['comment']) : null;
    if (json['comments'] != null) {
      comments = <Comment>[];
      try {
        for (var v in (json['comments'] as List)) {
          comments!.add(Comment.fromJson(v as Map<String, dynamic>));
        }
      } catch (_) {
        // ignore malformed comments
      }
    }
    seen = json['seen'];
    if (json['serviceItemList'] != null) {
      serviceItemList = <ServiceItemList>[];
      json['serviceItemList'].forEach((v) {
        serviceItemList!.add(ServiceItemList.fromJson(v));
      });
    }
    participants = json['participants'];
    loggedUserId = json['loggedUserId'];
    userId = json['userId'] != null ? UserId.fromJson(json['userId']) : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (sender != null) {
      data['sender'] = sender!.toJson();
    }
    if (receiver != null) {
      data['receiver'] = receiver!.toJson();
    }
    data['conversationId'] = conversationId;
    if (message != null) {
      data['message'] = message!.toJson();
    }
    if (comment != null) {
      data['comment'] = comment!.toJson();
    }
    if (comments != null) {
      data['comments'] = comments!.map((c) => c.toJson()).toList();
    }
    data['seen'] = seen;
    if (serviceItemList != null) {
      data['serviceItemList'] = serviceItemList!.map((v) => v.toJson()).toList();
    }
    data['participants'] = participants;
    data['loggedUserId'] = loggedUserId;
    if (userId != null) {
      data['userId'] = userId!.toJson();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}

class Sender {
  String? email;
  String? name;

  Sender({this.email, this.name});

  Sender.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    return data;
  }
}

class Message {
  String? message;
  String? messageType;
  String? jobId;
  String? progress;
  List<Services>? services;
  String? file;
  Invoice? invoice;
  String? quotationNo;
  String? quotationId;
  Quotation? quotation;
  Notification? notification;
  Comment? comment;

  Message({
    this.message,
    this.messageType,
    this.jobId,
    this.progress,
    this.services,
    this.file,
    this.invoice,
    this.quotationNo,
    this.quotationId,
    this.quotation,
    this.notification,
    this.comment,
  });

  Message.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    messageType = json['messageType'];
    jobId = json['jobId'];
    progress = json['progress'];
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(Services.fromJson(v));
      });
    }
    file = json['file'];
    invoice = json['invoice'] != null ? Invoice.fromJson(json['invoice']) : null;
    quotationNo = json['quotationNo'];
    quotationId = json['quotationId'];
    quotation = json['quotation'] != null ? Quotation.fromJson(json['quotation']) : null;
    notification = json['notification'] != null ? Notification.fromJson(json['notification']) : null;
    comment = json['comment'] != null ? Comment.fromJson(json['comment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['messageType'] = messageType;
    data['jobId'] = jobId;
    data['progress'] = progress;
    if (services != null) {
      data['services'] = services!.map((v) => v.toJson()).toList();
    }
    data['file'] = file;
    if (invoice != null) {
      data['invoice'] = invoice!.toJson();
    }
    data['quotationNo'] = quotationNo;
    data['quotationId'] = quotationId;
    if (quotation != null) {
      data['quotation'] = quotation!.toJson();
    }
    if (notification != null) {
      data['notification'] = notification!.toJson();
    }
    if (comment != null) {
      data['comment'] = comment!.toJson();
    }
    return data;
  }
}

class Comment {
  String? text;
  String? authorId;
  String? userId;
  String? messageId;
  String? conversationId;
  String? parentCommentId;
  List<String>? mentions;

  Comment({
    this.text,
    this.authorId,
    this.userId,
    this.messageId,
    this.conversationId,
    this.parentCommentId,
    this.mentions,
  });

  Comment.fromJson(Map<String, dynamic> json) {
    // Flexible parsing: API may return nested objects for some fields.
    dynamic text = json['text'];
    if (text is String) {
      text = text;
    } else if (text is Map) {
      text = text['text'] ?? text['message'] ?? text['html'] ?? text.toString();
    } else if (text != null) {
      text = text.toString();
    }

    dynamic author = json['authorId'];
    if (author is String) {
      authorId = author;
    } else if (author is Map) {
      authorId = author['_id'] ?? author['id'] ?? author['sId'] ?? author['userId'] ?? author['email']?.toString();
    }

    dynamic user = json['userId'];
    if (user is String) {
      userId = user;
    } else if (user is Map) {
      userId = user['_id'] ?? user['id'] ?? user['sId'] ?? user['userId'] ?? user['email']?.toString();
    }

    dynamic messageId = json['messageId'];
    if (messageId is String) {
      messageId = messageId;
    } else if (messageId is Map) {
      messageId = messageId['_id'] ?? messageId['id'] ?? messageId['sId'] ?? messageId.toString();
    }

    dynamic conversationId = json['conversationId'];
    if (conversationId is String) {
      conversationId = conversationId;
    } else if (conversationId is Map) {
      conversationId =
          conversationId['_id'] ?? conversationId['id'] ?? conversationId['sId'] ?? conversationId.toString();
    }

    dynamic parent = json['parentCommentId'];
    if (parent is String) {
      parentCommentId = parent;
    } else if (parent is Map) {
      parentCommentId = parent['_id'] ?? parent['id'] ?? parent['sId'] ?? parent.toString();
    }

    // Mentions may be list of ids or list of objects
    if (json['mentions'] != null) {
      try {
        final raw = json['mentions'];
        if (raw is List) {
          mentions = raw.map<String>((m) {
            if (m is String) return m;
            if (m is Map) return m['_id'] ?? m['id'] ?? m['sId'] ?? m['email'] ?? m.toString();
            return m.toString();
          }).toList();
        }
      } catch (_) {
        mentions = null;
      }
    } else {
      mentions = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    data['authorId'] = authorId;
    data['userId'] = userId;
    data['messageId'] = messageId;
    data['conversationId'] = conversationId;
    data['parentCommentId'] = parentCommentId;
    data['mentions'] = mentions;
    return data;
  }
}

class Services {
  String? productName;
  dynamic priceExclVat;
  dynamic vat;
  dynamic priceInclVat;
  String? id;
  String? itemNumber;
  dynamic unit;
  String? physicalLocation;
  dynamic stockQty;
  dynamic amount;
  String? description;
  String? manufacturer;
  String? manufacturerNumber;
  String? color;
  String? condition;
  String? category;
  bool? serialNoManagement;
  String? lineItemId;
  dynamic discountedIncl;
  dynamic discountedExcl;
  String? serviceId;
  List<AssignedItems>? assignedItems;

  Services({
    this.productName,
    this.priceExclVat,
    this.vat,
    this.priceInclVat,
    this.id,
    this.itemNumber,
    this.unit,
    this.physicalLocation,
    this.stockQty,
    this.amount,
    this.description,
    this.manufacturer,
    this.manufacturerNumber,
    this.color,
    this.condition,
    this.category,
    this.serialNoManagement,
    this.lineItemId,
    this.discountedIncl,
    this.discountedExcl,
    this.serviceId,
    this.assignedItems,
  });

  Services.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    priceExclVat = json['price_excl_vat'];
    vat = json['vat'];
    priceInclVat = json['price_incl_vat'];
    id = json['id'];
    itemNumber = json['itemNumber'];
    unit = json['unit'];
    physicalLocation = json['physicalLocation'];
    stockQty = json['stockQty'];
    amount = json['amount'];
    description = json['description'];
    manufacturer = json['manufacturer'];
    manufacturerNumber = json['manufacturerNumber'];
    color = json['color'];
    condition = json['condition'];
    category = json['category'];
    serialNoManagement = json['serialNoManagement'];
    lineItemId = json['lineItemId'];
    discountedIncl = json['discounted_incl'];
    discountedExcl = json['discounted_excl'];
    serviceId = json['serviceId'];
    if (json['assignedItems'] != null) {
      assignedItems = <AssignedItems>[];
      json['assignedItems'].forEach((v) {
        assignedItems!.add(AssignedItems.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['price_excl_vat'] = priceExclVat;
    data['vat'] = vat;
    data['price_incl_vat'] = priceInclVat;
    data['id'] = id;
    data['itemNumber'] = itemNumber;
    data['unit'] = unit;
    data['physicalLocation'] = physicalLocation;
    data['stockQty'] = stockQty;
    data['amount'] = amount;
    data['description'] = description;
    data['manufacturer'] = manufacturer;
    data['manufacturerNumber'] = manufacturerNumber;
    data['color'] = color;
    data['condition'] = condition;
    data['category'] = category;
    data['serialNoManagement'] = serialNoManagement;
    data['lineItemId'] = lineItemId;
    data['discounted_incl'] = discountedIncl;
    data['discounted_excl'] = discountedExcl;
    data['serviceId'] = serviceId;
    if (assignedItems != null) {
      data['assignedItems'] = assignedItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AssignedItems {
  String? productName;
  dynamic priceExclVat;
  dynamic vat;
  dynamic priceInclVat;
  String? id;
  String? itemNumber;
  dynamic unit;
  String? physicalLocation;
  dynamic stockQty;
  dynamic amount;
  String? description;
  String? manufacturer;
  String? manufacturerNumber;
  String? color;
  String? condition;
  String? category;
  bool? serialNoManagement;

  AssignedItems({
    this.productName,
    this.priceExclVat,
    this.vat,
    this.priceInclVat,
    this.id,
    this.itemNumber,
    this.unit,
    this.physicalLocation,
    this.stockQty,
    this.amount,
    this.description,
    this.manufacturer,
    this.manufacturerNumber,
    this.color,
    this.condition,
    this.category,
    this.serialNoManagement,
  });

  AssignedItems.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    priceExclVat = json['price_excl_vat'];
    vat = json['vat'];
    priceInclVat = json['price_incl_vat'];
    id = json['id'];
    itemNumber = json['itemNumber'];
    unit = json['unit'];
    physicalLocation = json['physicalLocation'];
    stockQty = json['stockQty'];
    amount = json['amount'];
    description = json['description'];
    manufacturer = json['manufacturer'];
    manufacturerNumber = json['manufacturerNumber'];
    color = json['color'];
    condition = json['condition'];
    category = json['category'];
    serialNoManagement = json['serialNoManagement'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['price_excl_vat'] = priceExclVat;
    data['vat'] = vat;
    data['price_incl_vat'] = priceInclVat;
    data['id'] = id;
    data['itemNumber'] = itemNumber;
    data['unit'] = unit;
    data['physicalLocation'] = physicalLocation;
    data['stockQty'] = stockQty;
    data['amount'] = amount;
    data['description'] = description;
    data['manufacturer'] = manufacturer;
    data['manufacturerNumber'] = manufacturerNumber;
    data['color'] = color;
    data['condition'] = condition;
    data['category'] = category;
    data['serialNoManagement'] = serialNoManagement;
    return data;
  }
}

class Invoice {
  String? companyId;
  JobId? jobId;
  String? jobNo;
  String? text;
  dynamic subTotal;
  dynamic discount;
  String? discountPercent;
  dynamic vat;
  dynamic total;
  dynamic backAmount;
  List<ServiceItemList>? serviceItemList;
  String? paymentMethod;
  String? paymentStatus;
  String? invoiceNo;
  String? invoiceStatus;
  List<Status>? status;
  List<Files>? files;
  CustomerDetails? customerDetails;
  String? paymentNote;
  dynamic paymentDueDate;
  bool? isSend;
  bool? isRevoked;
  bool? isCreditInvoice;
  bool? paid;
  String? invoicePrdynamicType;
  String? invoiceType;
  String? userName;
  String? salutationHTMLmarkup;
  String? termsAndConditionsHTMLmarkup;
  ReceiptFooter? receiptFooter;
  String? location;
  LoggedUserId? loggedUserId;
  String? userId;
  bool? isIncludingVat;
  String? customerReference;
  String? sId;
  String? createdAt;
  String? updatedAt;
  dynamic iV;
  String? id;

  Invoice({
    this.companyId,
    this.jobId,
    this.jobNo,
    this.text,
    this.subTotal,
    this.discount,
    this.discountPercent,
    this.vat,
    this.total,
    this.backAmount,
    this.serviceItemList,
    this.paymentMethod,
    this.paymentStatus,
    this.invoiceNo,
    this.invoiceStatus,
    this.status,
    this.files,
    this.customerDetails,
    this.paymentNote,
    this.paymentDueDate,
    this.isSend,
    this.isRevoked,
    this.isCreditInvoice,
    this.paid,
    this.invoicePrdynamicType,
    this.invoiceType,
    this.userName,
    this.salutationHTMLmarkup,
    this.termsAndConditionsHTMLmarkup,
    this.receiptFooter,
    this.location,
    this.loggedUserId,
    this.userId,
    this.isIncludingVat,
    this.customerReference,
    this.sId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
  });

  Invoice.fromJson(Map<String, dynamic> json) {
    companyId = json['companyId'];
    jobId = json['jobId'] != null ? JobId.fromJson(json['jobId']) : null;
    jobNo = json['jobNo'];
    text = json['text'];
    subTotal = json['subTotal'];
    discount = json['discount'];
    discountPercent = json['discountPercent'];
    vat = json['vat'];
    total = json['total'];
    backAmount = json['backAmount'];
    if (json['serviceItemList'] != null) {
      serviceItemList = <ServiceItemList>[];
      json['serviceItemList'].forEach((v) {
        serviceItemList!.add(ServiceItemList.fromJson(v));
      });
    }
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    invoiceNo = json['invoiceNo'];
    invoiceStatus = json['invoiceStatus'];
    if (json['status'] != null) {
      status = <Status>[];
      json['status'].forEach((v) {
        status!.add(Status.fromJson(v));
      });
    }
    if (json['files'] != null) {
      files = <Files>[];
      json['files'].forEach((v) {
        files!.add(Files.fromJson(v));
      });
    }

    customerDetails = json['customerDetails'] != null ? CustomerDetails.fromJson(json['customerDetails']) : null;
    paymentNote = json['paymentNote'];
    paymentDueDate = json['paymentDueDate'];
    isSend = json['isSend'];
    isRevoked = json['isRevoked'];
    isCreditInvoice = json['isCreditInvoice'];
    paid = json['paid'];
    invoicePrdynamicType = json['invoicePrdynamicType'];
    invoiceType = json['invoiceType'];
    userName = json['userName'];
    salutationHTMLmarkup = json['salutationHTMLmarkup'];
    termsAndConditionsHTMLmarkup = json['termsAndConditionsHTMLmarkup'];
    receiptFooter = json['receipt_footer'] != null ? ReceiptFooter.fromJson(json['receipt_footer']) : null;
    location = json['location'];
    loggedUserId = json['loggedUserId'] != null ? LoggedUserId.fromJson(json['loggedUserId']) : null;
    userId = json['userId'];
    isIncludingVat = json['isIncludingVat'];
    customerReference = json['customerReference'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['companyId'] = companyId;
    if (jobId != null) {
      data['jobId'] = jobId!.toJson();
    }
    data['jobNo'] = jobNo;
    data['text'] = text;
    data['subTotal'] = subTotal;
    data['discount'] = discount;
    data['discountPercent'] = discountPercent;
    data['vat'] = vat;
    data['total'] = total;
    data['backAmount'] = backAmount;
    if (serviceItemList != null) {
      data['serviceItemList'] = serviceItemList!.map((v) => v.toJson()).toList();
    }
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
    data['invoiceNo'] = invoiceNo;
    data['invoiceStatus'] = invoiceStatus;
    if (status != null) {
      data['status'] = status!.map((v) => v.toJson()).toList();
    }
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    if (customerDetails != null) {
      data['customerDetails'] = customerDetails!.toJson();
    }
    data['paymentNote'] = paymentNote;
    data['paymentDueDate'] = paymentDueDate;
    data['isSend'] = isSend;
    data['isRevoked'] = isRevoked;
    data['isCreditInvoice'] = isCreditInvoice;
    data['paid'] = paid;
    data['invoicePrdynamicType'] = invoicePrdynamicType;
    data['invoiceType'] = invoiceType;
    data['userName'] = userName;
    data['salutationHTMLmarkup'] = salutationHTMLmarkup;
    data['termsAndConditionsHTMLmarkup'] = termsAndConditionsHTMLmarkup;
    if (receiptFooter != null) {
      data['receipt_footer'] = receiptFooter!.toJson();
    }
    data['location'] = location;
    if (loggedUserId != null) {
      data['loggedUserId'] = loggedUserId!.toJson();
    }
    data['userId'] = userId;
    data['isIncludingVat'] = isIncludingVat;
    data['customerReference'] = customerReference;
    data['_id'] = sId;

    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}

class JobId {
  String? salutationHTMLmarkup;
  String? termsAndConditionsHTMLmarkup;
  bool? isJobCompleted;
  bool? isDeviceReturned;
  String? jobSource;
  String? sId;
  String? jobType;
  String? jobTypes;
  String? model;
  List<String>? servicesIds;
  DeviceId? deviceId;
  String? jobContactId;
  DefectId? defectId;
  dynamic subTotal;
  dynamic total;
  dynamic vat;
  dynamic discount;
  String? jobNo;
  String? customerId;
  List<AssignedItems>? assignedItemsIds;
  bool? emailConfirmation;
  List<Files>? files;
  bool? prdynamicDeviceLabel;
  List<JobStatus>? jobStatus;
  CustomerDetails? customerDetails;
  String? status;
  String? location;
  String? userId;
  String? createdAt;
  String? updatedAt;
  dynamic iV;
  String? jobTrackingNumber;
  String? physicalLocation;
  String? prdynamicOption;
  String? signatureFilePath;
  DeviceData? deviceData;
  String? jobPriority;
  String? assignUser;
  String? assignerName;
  String? id;

  JobId({
    this.salutationHTMLmarkup,
    this.termsAndConditionsHTMLmarkup,
    this.isJobCompleted,
    this.isDeviceReturned,
    this.jobSource,
    this.sId,
    this.jobType,
    this.jobTypes,
    this.model,
    this.servicesIds,
    this.deviceId,
    this.jobContactId,
    this.defectId,
    this.subTotal,
    this.total,
    this.vat,
    this.discount,
    this.jobNo,
    this.customerId,
    this.assignedItemsIds,
    this.emailConfirmation,
    this.files,
    this.prdynamicDeviceLabel,
    this.jobStatus,
    this.customerDetails,
    this.status,
    this.location,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.jobTrackingNumber,
    this.physicalLocation,
    this.prdynamicOption,
    this.signatureFilePath,
    this.deviceData,
    this.jobPriority,
    this.assignUser,
    this.assignerName,
    this.id,
  });

  JobId.fromJson(Map<String, dynamic> json) {
    salutationHTMLmarkup = json['salutationHTMLmarkup'];
    termsAndConditionsHTMLmarkup = json['termsAndConditionsHTMLmarkup'];
    isJobCompleted = json['is_job_completed'];
    isDeviceReturned = json['is_device_returned'];
    jobSource = json['jobSource'];
    sId = json['_id'];
    jobType = json['jobType'];
    jobTypes = json['jobTypes'];
    model = json['model'];
    servicesIds = json['servicesIds'].cast<String>();
    deviceId = json['deviceId'] != null ? DeviceId.fromJson(json['deviceId']) : null;
    jobContactId = json['jobContactId'];
    defectId = json['defectId'] != null ? DefectId.fromJson(json['defectId']) : null;
    subTotal = json['subTotal'];
    total = json['total'];
    vat = json['vat'];
    discount = json['discount'];
    jobNo = json['jobNo'];
    customerId = json['customerId'];
    if (json['assignedItemsIds'] != null) {
      assignedItemsIds = <AssignedItems>[];
      json['assignedItemsIds'].forEach((v) {
        assignedItemsIds!.add(AssignedItems.fromJson(v));
      });
    }
    emailConfirmation = json['emailConfirmation'];
    if (json['files'] != null) {
      files = <Files>[];
      json['files'].forEach((v) {
        files!.add(Files.fromJson(v));
      });
    }
    prdynamicDeviceLabel = json['prdynamicDeviceLabel'];
    if (json['jobStatus'] != null) {
      jobStatus = <JobStatus>[];
      json['jobStatus'].forEach((v) {
        jobStatus!.add(JobStatus.fromJson(v));
      });
    }
    customerDetails = json['customerDetails'] != null ? CustomerDetails.fromJson(json['customerDetails']) : null;
    status = json['status'];
    location = json['location'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    jobTrackingNumber = json['job_tracking_number'];
    physicalLocation = json['physicalLocation'];
    prdynamicOption = json['prdynamicOption'];
    signatureFilePath = json['signatureFilePath'];
    deviceData = json['deviceData'] != null ? DeviceData.fromJson(json['deviceData']) : null;
    jobPriority = json['job_priority'];
    assignUser = json['assign_user'];
    assignerName = json['assigner_name'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['salutationHTMLmarkup'] = salutationHTMLmarkup;
    data['termsAndConditionsHTMLmarkup'] = termsAndConditionsHTMLmarkup;
    data['is_job_completed'] = isJobCompleted;
    data['is_device_returned'] = isDeviceReturned;
    data['jobSource'] = jobSource;
    data['_id'] = sId;
    data['jobType'] = jobType;
    data['jobTypes'] = jobTypes;
    data['model'] = model;
    data['servicesIds'] = servicesIds;
    if (deviceId != null) {
      data['deviceId'] = deviceId!.toJson();
    }
    data['jobContactId'] = jobContactId;
    if (defectId != null) {
      data['defectId'] = defectId!.toJson();
    }
    data['subTotal'] = subTotal;
    data['total'] = total;
    data['vat'] = vat;
    data['discount'] = discount;
    data['jobNo'] = jobNo;
    data['customerId'] = customerId;
    if (assignedItemsIds != null) {
      data['assignedItemsIds'] = assignedItemsIds!.map((v) => v.toJson()).toList();
    }
    data['emailConfirmation'] = emailConfirmation;
    if (files != null) {
      data['files'] = files!.map((v) => v.toJson()).toList();
    }
    data['prdynamicDeviceLabel'] = prdynamicDeviceLabel;
    if (jobStatus != null) {
      data['jobStatus'] = jobStatus!.map((v) => v.toJson()).toList();
    }
    if (customerDetails != null) {
      data['customerDetails'] = customerDetails!.toJson();
    }
    data['status'] = status;
    data['location'] = location;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['job_tracking_number'] = jobTrackingNumber;
    data['physicalLocation'] = physicalLocation;
    data['prdynamicOption'] = prdynamicOption;
    data['signatureFilePath'] = signatureFilePath;
    if (deviceData != null) {
      data['deviceData'] = deviceData!.toJson();
    }
    data['job_priority'] = jobPriority;
    data['assign_user'] = assignUser;
    data['assigner_name'] = assignerName;
    data['id'] = id;
    return data;
  }
}

class DeviceId {
  String? sId;
  String? brand;
  String? model;
  String? category;
  String? imei;
  List<Condition>? condition;
  String? deviceSecurity;
  List<Null>? securityLock;
  String? color;
  String? createdAt;
  String? updatedAt;
  dynamic iV;
  String? id;

  DeviceId({
    this.sId,
    this.brand,
    this.model,
    this.category,
    this.imei,
    this.condition,
    this.deviceSecurity,
    this.securityLock,
    this.color,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
  });

  DeviceId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    brand = json['brand'];
    model = json['model'];
    category = json['category'];
    imei = json['imei'];
    if (json['condition'] != null) {
      condition = <Condition>[];
      json['condition'].forEach((v) {
        condition!.add(Condition.fromJson(v));
      });
    }

    deviceSecurity = json['deviceSecurity'];

    color = json['color'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['brand'] = brand;
    data['model'] = model;
    data['category'] = category;
    data['imei'] = imei;
    if (condition != null) {
      data['condition'] = condition!.map((v) => v.toJson()).toList();
    }

    data['color'] = color;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
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

class DefectId {
  String? sId;
  List<Defect>? defect;
  String? jobType;
  String? reference;
  String? description;
  List<InternalNote>? internalNote;
  List<String>? assignItems;
  String? createdAt;
  String? updatedAt;
  dynamic iV;
  String? id;

  DefectId({
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
    this.id,
  });

  DefectId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['defect'] != null) {
      defect = <Defect>[];
      json['defect'].forEach((v) {
        defect!.add(Defect.fromJson(v));
      });
    }
    jobType = json['jobType'];
    reference = json['reference'];
    description = json['description'];
    if (json['internalNote'] != null) {
      internalNote = <InternalNote>[];
      json['internalNote'].forEach((v) {
        internalNote!.add(InternalNote.fromJson(v));
      });
    }
    assignItems = json['assignItems'].cast<String>();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
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
    data['id'] = id;
    return data;
  }
}

class InternalNote {
  String? text;
  String? userId;
  String? createdAt;
  String? userName;
  String? id;

  InternalNote({this.text, this.userId, this.createdAt, this.userName, this.id});

  InternalNote.fromJson(Map<String, dynamic> json) {
    text = json['text'];
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

class Files {
  String? file;
  String? id;
  String? fileName;
  dynamic size;

  Files({this.file, this.id, this.fileName, this.size});

  Files.fromJson(Map<String, dynamic> json) {
    file = json['file'];
    id = json['id'];
    fileName = json['fileName'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file'] = file;
    data['id'] = id;
    data['fileName'] = fileName;
    data['size'] = size;
    return data;
  }
}

class JobStatus {
  String? title;
  String? userId;
  String? colorCode;
  String? userName;
  dynamic createAtStatus;
  bool? notifications;
  String? email;
  String? notes;
  String? priority;

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
  String? type;
  String? type2;
  String? organization;
  String? customerNo;
  String? email;
  String? telephone;
  BillingAddress? billingAddress;
  String? salutation;
  String? firstName;
  String? lastName;
  String? position;

  CustomerDetails({
    this.customerId,
    this.type,
    this.type2,
    this.organization,
    this.customerNo,
    this.email,
    this.telephone,
    this.billingAddress,
    this.salutation,
    this.firstName,
    this.lastName,
    this.position,
  });

  CustomerDetails.fromJson(Map<String, dynamic> json) {
    customerId = json['customerId'];
    type = json['type'];
    type2 = json['type2'];
    organization = json['organization'];
    customerNo = json['customerNo'];
    email = json['email'];
    telephone = json['telephone'];
    billingAddress = json['billing_address'] != null ? BillingAddress.fromJson(json['billing_address']) : null;
    salutation = json['salutation'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    position = json['position'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customerId'] = customerId;
    data['type'] = type;
    data['type2'] = type2;
    data['organization'] = organization;
    data['customerNo'] = customerNo;
    data['email'] = email;
    data['telephone'] = telephone;
    if (billingAddress != null) {
      data['billing_address'] = billingAddress!.toJson();
    }
    data['salutation'] = salutation;
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['position'] = position;
    return data;
  }
}

class BillingAddress {
  String? sId;
  String? street;
  String? zip;
  String? city;
  String? country;
  String? customerId;
  dynamic iV;

  BillingAddress({this.sId, this.street, this.zip, this.city, this.country, this.customerId, this.iV});

  BillingAddress.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
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
    data['street'] = street;
    data['zip'] = zip;
    data['city'] = city;
    data['country'] = country;
    data['customerId'] = customerId;
    data['__v'] = iV;
    return data;
  }
}

class DeviceData {
  String? sId;
  String? brand;
  String? model;
  String? category;
  String? imei;
  List<Condition>? condition;

  String? deviceSecurity;
  List<Null>? securityLock;
  String? color;
  String? createdAt;
  String? updatedAt;
  dynamic iV;

  DeviceData({
    this.sId,
    this.brand,
    this.model,
    this.category,
    this.imei,
    this.condition,

    this.deviceSecurity,
    this.securityLock,
    this.color,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  DeviceData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    brand = json['brand'];
    model = json['model'];
    category = json['category'];
    imei = json['imei'];
    if (json['condition'] != null) {
      condition = <Condition>[];
      json['condition'].forEach((v) {
        condition!.add(Condition.fromJson(v));
      });
    }

    deviceSecurity = json['deviceSecurity'];

    color = json['color'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['brand'] = brand;
    data['model'] = model;
    data['category'] = category;
    data['imei'] = imei;
    if (condition != null) {
      data['condition'] = condition!.map((v) => v.toJson()).toList();
    }
    data['color'] = color;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class ServiceItemList {
  String? productName;
  dynamic priceExclVat;
  dynamic vat;
  dynamic priceInclVat;
  String? id;
  String? itemNumber;
  dynamic unit;
  String? physicalLocation;
  dynamic stockQty;
  dynamic amount;
  String? description;
  String? manufacturer;
  String? manufacturerNumber;
  String? color;
  String? condition;
  String? category;
  bool? serialNoManagement;
  String? lineItemId;
  dynamic discountedIncl;
  dynamic discountedExcl;

  ServiceItemList({
    this.productName,
    this.priceExclVat,
    this.vat,
    this.priceInclVat,
    this.id,
    this.itemNumber,
    this.unit,
    this.physicalLocation,
    this.stockQty,
    this.amount,
    this.description,
    this.manufacturer,
    this.manufacturerNumber,
    this.color,
    this.condition,
    this.category,
    this.serialNoManagement,
    this.lineItemId,
    this.discountedIncl,
    this.discountedExcl,
  });

  ServiceItemList.fromJson(Map<String, dynamic> json) {
    productName = json['productName'];
    priceExclVat = json['price_excl_vat'];
    vat = json['vat'];
    priceInclVat = json['price_incl_vat'];
    id = json['id'];
    itemNumber = json['itemNumber'];
    unit = json['unit'];
    physicalLocation = json['physicalLocation'];
    stockQty = json['stockQty'];
    amount = json['amount'];
    description = json['description'];
    manufacturer = json['manufacturer'];
    manufacturerNumber = json['manufacturerNumber'];
    color = json['color'];
    condition = json['condition'];
    category = json['category'];
    serialNoManagement = json['serialNoManagement'];
    lineItemId = json['lineItemId'];
    discountedIncl = json['discounted_incl'];
    discountedExcl = json['discounted_excl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productName'] = productName;
    data['price_excl_vat'] = priceExclVat;
    data['vat'] = vat;
    data['price_incl_vat'] = priceInclVat;
    data['id'] = id;
    data['itemNumber'] = itemNumber;
    data['unit'] = unit;
    data['physicalLocation'] = physicalLocation;
    data['stockQty'] = stockQty;
    data['amount'] = amount;
    data['description'] = description;
    data['manufacturer'] = manufacturer;
    data['manufacturerNumber'] = manufacturerNumber;
    data['color'] = color;
    data['condition'] = condition;
    data['category'] = category;
    data['serialNoManagement'] = serialNoManagement;
    data['lineItemId'] = lineItemId;
    data['discounted_incl'] = discountedIncl;
    data['discounted_excl'] = discountedExcl;
    return data;
  }
}

class Status {
  String? title;
  String? userId;
  dynamic priority;
  String? email;
  String? colorCode;
  dynamic createdAt;

  Status({this.title, this.userId, this.priority, this.email, this.colorCode, this.createdAt});

  Status.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    userId = json['userId'];
    priority = json['priority'];
    email = json['email'];
    colorCode = json['colorCode'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['userId'] = userId;
    data['priority'] = priority;
    data['email'] = email;
    data['colorCode'] = colorCode;
    data['createdAt'] = createdAt;
    return data;
  }
}

class ReceiptFooter {
  String? companyLogo;
  String? companyLogoURL;
  Address? address;
  Contact? contact;
  Bank? bank;

  ReceiptFooter({this.companyLogo, this.companyLogoURL, this.address, this.contact, this.bank});

  ReceiptFooter.fromJson(Map<String, dynamic> json) {
    companyLogo = json['companyLogo'];
    companyLogoURL = json['companyLogoURL'];
    address = json['address'] != null ? Address.fromJson(json['address']) : null;
    contact = json['contact'] != null ? Contact.fromJson(json['contact']) : null;
    bank = json['bank'] != null ? Bank.fromJson(json['bank']) : null;
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

  Address({this.companyName, this.street, this.num, this.zip, this.city, this.country});

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

class Contact {
  String? ceo;
  String? telephone;
  String? email;
  String? website;

  Contact({this.ceo, this.telephone, this.email, this.website});

  Contact.fromJson(Map<String, dynamic> json) {
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

class LoggedUserId {
  String? sId;
  String? email;
  String? fullName;
  String? id;

  LoggedUserId({this.sId, this.email, this.fullName, this.id});

  LoggedUserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['fullName'] = fullName;
    data['id'] = id;
    return data;
  }
}

class Quotation {
  String? sId;
  String? quotationNo;
  String? companyId;
  String? jobId;
  String? text;
  String? status;
  dynamic subTotal;
  dynamic total;
  dynamic discount;
  dynamic rejectAmount;
  dynamic acceptAmount;
  String? quotationName;
  bool? send;
  bool? anyTimeSend;
  bool? changed;
  bool? paid;
  bool? rejectPaid;
  bool? accepted;
  bool? rejected;
  List<ServiceItemList>? serviceItemList;
  dynamic vat;
  CustomerDetails? customerDetails;
  String? userName;
  bool? onlinePaymentActived;
  String? userId;
  String? createdAt;
  String? updatedAt;
  dynamic iV;
  String? paymentId;
  String? rejectPaymentId;
  String? paymentMethod;
  String? paymentStatus;
  String? paymentLink;
  String? rejectPaymentLink;
  String? id;
  String? paidId;
  String? rejectPaidId;

  Quotation({
    this.sId,
    this.quotationNo,
    this.companyId,
    this.jobId,
    this.text,
    this.status,
    this.subTotal,
    this.total,
    this.discount,
    this.rejectAmount,
    this.acceptAmount,
    this.quotationName,
    this.send,
    this.anyTimeSend,
    this.changed,
    this.paid,
    this.rejectPaid,
    this.accepted,
    this.rejected,
    this.serviceItemList,
    this.vat,
    this.customerDetails,
    this.userName,
    this.onlinePaymentActived,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.paymentId,
    this.rejectPaymentId,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentLink,
    this.rejectPaymentLink,
    this.id,
    this.paidId,
    this.rejectPaidId,
  });

  Quotation.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    quotationNo = json['quotationNo'];
    companyId = json['companyId'];
    jobId = json['jobId'];
    text = json['text'];
    status = json['status'];
    subTotal = json['subTotal'];
    total = json['total'];
    discount = json['discount'];
    rejectAmount = json['rejectAmount'];
    acceptAmount = json['acceptAmount'];
    quotationName = json['quotationName'];
    send = json['send'];
    anyTimeSend = json['anyTimeSend'];
    changed = json['changed'];
    paid = json['paid'];
    rejectPaid = json['rejectPaid'];
    accepted = json['accepted'];
    rejected = json['rejected'];
    if (json['serviceItemList'] != null) {
      serviceItemList = <ServiceItemList>[];
      json['serviceItemList'].forEach((v) {
        serviceItemList!.add(ServiceItemList.fromJson(v));
      });
    }
    vat = json['vat'];
    customerDetails = json['customerDetails'] != null ? CustomerDetails.fromJson(json['customerDetails']) : null;
    userName = json['userName'];
    onlinePaymentActived = json['onlinePaymentActived'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    paymentId = json['paymentId'];
    rejectPaymentId = json['rejectPaymentId'];
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    paymentLink = json['paymentLink'];
    rejectPaymentLink = json['rejectPaymentLink'];
    id = json['id'];
    paidId = json['paidId'];
    rejectPaidId = json['rejectPaidId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['quotationNo'] = quotationNo;
    data['companyId'] = companyId;
    data['jobId'] = jobId;
    data['text'] = text;
    data['status'] = status;
    data['subTotal'] = subTotal;
    data['total'] = total;
    data['discount'] = discount;
    data['rejectAmount'] = rejectAmount;
    data['acceptAmount'] = acceptAmount;
    data['quotationName'] = quotationName;
    data['send'] = send;
    data['anyTimeSend'] = anyTimeSend;
    data['changed'] = changed;
    data['paid'] = paid;
    data['rejectPaid'] = rejectPaid;
    data['accepted'] = accepted;
    data['rejected'] = rejected;
    if (serviceItemList != null) {
      data['serviceItemList'] = serviceItemList!.map((v) => v.toJson()).toList();
    }
    data['vat'] = vat;
    if (customerDetails != null) {
      data['customerDetails'] = customerDetails!.toJson();
    }
    data['userName'] = userName;
    data['onlinePaymentActived'] = onlinePaymentActived;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['paymentId'] = paymentId;
    data['rejectPaymentId'] = rejectPaymentId;
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
    data['paymentLink'] = paymentLink;
    data['rejectPaymentLink'] = rejectPaymentLink;
    data['id'] = id;
    data['paidId'] = paidId;
    data['rejectPaidId'] = rejectPaidId;
    return data;
  }
}

class Notification {
  String? userId;
  String? message;
  String? notificationId;
  bool? isRead;
  String? messageType;
  String? conversationId;
  Sender? senderDetails;
  Sender? receiverDetails;

  Notification({
    this.userId,
    this.message,
    this.notificationId,
    this.isRead,
    this.messageType,
    this.conversationId,
    this.senderDetails,
    this.receiverDetails,
  });

  Notification.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    message = json['message'];
    notificationId = json['notification_id'];
    isRead = json['isRead'];
    messageType = json['messageType'];
    conversationId = json['conversationId'];
    senderDetails = json['sender_details'] != null ? Sender.fromJson(json['sender_details']) : null;
    receiverDetails = json['receiver_details'] != null ? Sender.fromJson(json['receiver_details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['message'] = message;
    data['notification_id'] = notificationId;
    data['isRead'] = isRead;
    data['messageType'] = messageType;
    data['conversationId'] = conversationId;
    if (senderDetails != null) {
      data['sender_details'] = senderDetails!.toJson();
    }
    if (receiverDetails != null) {
      data['receiver_details'] = receiverDetails!.toJson();
    }
    return data;
  }
}

class UserId {
  String? sId;
  String? email;
  String? fullName;
  String? avatar;
  String? position;
  String? userType;
  String? id;

  UserId({this.sId, this.email, this.fullName, this.avatar, this.position, this.userType, this.id});

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    email = json['email'];
    fullName = json['fullName'];
    avatar = json['avatar'];
    position = json['position'];
    userType = json['userType'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['email'] = email;
    data['fullName'] = fullName;
    data['avatar'] = avatar;
    data['position'] = position;
    data['userType'] = userType;
    data['id'] = id;
    return data;
  }
}
