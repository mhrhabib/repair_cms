import 'package:repair_cms/features/myJobs/models/single_job_model.dart';

extension MapSafeHelper on Map<String, dynamic> {
  String? getString(String key) {
    var value = this[key];
    if (value == null) return null;
    return value.toString();
  }

  int? getInt(String key) {
    var value = this[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? getDouble(String key) {
    var value = this[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  bool? getBool(String key) {
    var value = this[key];
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value == 1;
    return null;
  }

  Map<String, dynamic>? getMap(String key) {
    var value = this[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<dynamic>? getList(String key) {
    var value = this[key];
    if (value == null || value is! List) return null;
    return value;
  }
}

class ConversationModel {
  bool? success;
  List<Conversation>? data;
  dynamic pages;
  dynamic total;
  String? error;
  String? message;

  ConversationModel({
    this.success,
    this.data,
    this.pages,
    this.total,
    this.error,
    this.message,
  });

  ConversationModel.fromJson(Map<String, dynamic> json) {
    success = json.getBool('success');
    var dataList = json.getList('data');
    if (dataList != null) {
      data = <Conversation>[];
      for (var v in dataList) {
        if (v is Map<String, dynamic>) {
          data!.add(Conversation.fromJson(v));
        }
      }
    }
    pages = json['pages'];
    total = json['total'];
    error = json.getString('error');
    message = json.getString('message');
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
    sId = json.getString('_id');
    var senderMap = json.getMap('sender');
    sender = senderMap != null ? Sender.fromJson(senderMap) : null;
    var receiverMap = json.getMap('receiver');
    receiver = receiverMap != null ? Sender.fromJson(receiverMap) : null;
    conversationId = json.getString('conversationId');
    var messageMap = json.getMap('message');
    message = messageMap != null ? Message.fromJson(messageMap) : null;
    var commentMap = json.getMap('comment');
    comment = commentMap != null ? Comment.fromJson(commentMap) : null;

    var commentsList = json.getList('comments');
    if (commentsList != null) {
      comments = <Comment>[];
      for (var v in commentsList) {
        if (v is Map<String, dynamic>) {
          comments!.add(Comment.fromJson(v));
        }
      }
    }

    seen = json.getBool('seen');
    var serviceItems = json.getList('serviceItemList');
    if (serviceItems != null) {
      serviceItemList = <ServiceItemList>[];
      for (var v in serviceItems) {
        if (v is Map<String, dynamic>) {
          serviceItemList!.add(ServiceItemList.fromJson(v));
        }
      }
    }

    participants = json.getString('participants');
    loggedUserId = json.getString('loggedUserId');
    var userIdMap = json.getMap('userId');
    userId = userIdMap != null ? UserId.fromJson(userIdMap) : null;
    createdAt = json.getString('createdAt');
    updatedAt = json.getString('updatedAt');
    iV = json['__v'];
    id = json.getString('id');
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
      data['serviceItemList'] = serviceItemList!
          .map((v) => v.toJson())
          .toList();
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
    email = json.getString('email');
    name = json.getString('name');
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
    message = json.getString('message');
    messageType = json.getString('messageType');
    jobId = json.getString('jobId');
    progress = json.getString('progress');
    var servicesList = json.getList('services');
    if (servicesList != null) {
      services = <Services>[];
      for (var v in servicesList) {
        if (v is Map<String, dynamic>) {
          services!.add(Services.fromJson(v));
        }
      }
    }
    file = json.getString('file');
    var invoiceMap = json.getMap('invoice');
    invoice = invoiceMap != null ? Invoice.fromJson(invoiceMap) : null;
    quotationNo = json.getString('quotationNo');
    quotationId = json.getString('quotationId');
    var quotationMap = json.getMap('quotation');
    quotation = quotationMap != null ? Quotation.fromJson(quotationMap) : null;
    var notificationMap = json.getMap('notification');
    notification = notificationMap != null
        ? Notification.fromJson(notificationMap)
        : null;
    var commentMap = json.getMap('comment');
    comment = commentMap != null ? Comment.fromJson(commentMap) : null;
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
    text = json.getString('text');

    var author = json['authorId'];
    if (author is Map) {
      authorId =
          (author['_id'] ?? author['id'] ?? author['sId'] ?? author['userId'])
              ?.toString();
    } else {
      authorId = author?.toString();
    }

    var user = json['userId'];
    if (user is Map) {
      userId = (user['_id'] ?? user['id'] ?? user['sId'] ?? user['userId'])
          ?.toString();
    } else {
      userId = user?.toString();
    }

    var msgId = json['messageId'];
    if (msgId is Map) {
      messageId = (msgId['_id'] ?? msgId['id'] ?? msgId['sId'])?.toString();
    } else {
      messageId = msgId?.toString();
    }

    var convId = json['conversationId'];
    if (convId is Map) {
      conversationId = (convId['_id'] ?? convId['id'] ?? convId['sId'])
          ?.toString();
    } else {
      conversationId = convId?.toString();
    }

    var parent = json['parentCommentId'];
    if (parent is Map) {
      parentCommentId = (parent['_id'] ?? parent['id'] ?? parent['sId'])
          ?.toString();
    } else {
      parentCommentId = parent?.toString();
    }

    var mentionsList = json.getList('mentions');
    if (mentionsList != null) {
      mentions = mentionsList
          .map((m) {
            if (m is Map)
              return (m['_id'] ?? m['id'] ?? m['sId'] ?? m['email'])
                  ?.toString();
            return m?.toString();
          })
          .whereType<String>()
          .toList();
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
  dynamic itemNumber;
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
    productName = json.getString('productName');
    priceExclVat = json['price_excl_vat'];
    vat = json['vat'];
    priceInclVat = json['price_incl_vat'];
    id = json.getString('id');
    itemNumber = json['itemNumber'];
    unit = json['unit'];
    physicalLocation = json.getString('physicalLocation');
    stockQty = json['stockQty'];
    amount = json['amount'];
    description = json.getString('description');
    manufacturer = json.getString('manufacturer');
    manufacturerNumber = json.getString('manufacturerNumber');
    color = json.getString('color');
    condition = json.getString('condition');
    category = json.getString('category');
    serialNoManagement = json.getBool('serialNoManagement');
    lineItemId = json.getString('lineItemId');
    discountedIncl = json['discounted_incl'];
    discountedExcl = json['discounted_excl'];
    serviceId = json.getString('serviceId');
    var items = json.getList('assignedItems');
    if (items != null) {
      assignedItems = <AssignedItems>[];
      for (var v in items) {
        if (v is Map<String, dynamic>) {
          assignedItems!.add(AssignedItems.fromJson(v));
        }
      }
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
    productName = json.getString('productName');
    priceExclVat = json['price_excl_vat'];
    vat = json['vat'];
    priceInclVat = json['price_incl_vat'];
    id = json.getString('id');
    itemNumber = json.getString('itemNumber');
    unit = json['unit'];
    physicalLocation = json.getString('physicalLocation');
    stockQty = json['stockQty'];
    amount = json['amount'];
    description = json.getString('description');
    manufacturer = json.getString('manufacturer');
    manufacturerNumber = json.getString('manufacturerNumber');
    color = json.getString('color');
    condition = json.getString('condition');
    category = json.getString('category');
    serialNoManagement = json.getBool('serialNoManagement');
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
    companyId = json.getString('companyId');
    var jobIdMap = json.getMap('jobId');
    jobId = jobIdMap != null ? JobId.fromJson(jobIdMap) : null;
    jobNo = json.getString('jobNo');
    text = json.getString('text');
    subTotal = json['subTotal'];
    discount = json['discount'];
    discountPercent = json.getString('discountPercent');
    vat = json['vat'];
    total = json['total'];
    backAmount = json['backAmount'];
    var itemsList = json.getList('serviceItemList');
    if (itemsList != null) {
      serviceItemList = <ServiceItemList>[];
      for (var v in itemsList) {
        if (v is Map<String, dynamic>) {
          serviceItemList!.add(ServiceItemList.fromJson(v));
        }
      }
    }
    paymentMethod = json.getString('paymentMethod');
    paymentStatus = json.getString('paymentStatus');
    invoiceNo = json.getString('invoiceNo');
    invoiceStatus = json.getString('invoiceStatus');
    var statusList = json.getList('status');
    if (statusList != null) {
      status = <Status>[];
      for (var v in statusList) {
        if (v is Map<String, dynamic>) {
          status!.add(Status.fromJson(v));
        }
      }
    }
    var filesList = json.getList('files');
    if (filesList != null) {
      files = <Files>[];
      for (var v in filesList) {
        if (v is Map<String, dynamic>) {
          files!.add(Files.fromJson(v));
        }
      }
    }

    var customerMap = json.getMap('customerDetails');
    customerDetails = customerMap != null
        ? CustomerDetails.fromJson(customerMap)
        : null;
    paymentNote = json.getString('paymentNote');
    paymentDueDate = json['paymentDueDate'];
    isSend = json.getBool('isSend');
    isRevoked = json.getBool('isRevoked');
    isCreditInvoice = json.getBool('isCreditInvoice');
    paid = json.getBool('paid');
    invoicePrdynamicType = json.getString('invoicePrdynamicType');
    invoiceType = json.getString('invoiceType');
    userName = json.getString('userName');
    salutationHTMLmarkup = json.getString('salutationHTMLmarkup');
    termsAndConditionsHTMLmarkup = json.getString(
      'termsAndConditionsHTMLmarkup',
    );
    var footerMap = json.getMap('receipt_footer');
    receiptFooter = footerMap != null
        ? ReceiptFooter.fromJson(footerMap)
        : null;
    location = json.getString('location');
    var loggedUserMap = json.getMap('loggedUserId');
    loggedUserId = loggedUserMap != null
        ? LoggedUserId.fromJson(loggedUserMap)
        : null;
    userId = json.getString('userId');
    isIncludingVat = json.getBool('isIncludingVat');
    customerReference = json.getString('customerReference');
    sId = json.getString('_id');
    createdAt = json.getString('createdAt');
    updatedAt = json.getString('updatedAt');
    iV = json['__v'];
    id = json.getString('id');
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
      data['serviceItemList'] = serviceItemList!
          .map((v) => v.toJson())
          .toList();
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
    salutationHTMLmarkup = json.getString('salutationHTMLmarkup');
    termsAndConditionsHTMLmarkup = json.getString(
      'termsAndConditionsHTMLmarkup',
    );
    isJobCompleted = json.getBool('is_job_completed');
    isDeviceReturned = json.getBool('is_device_returned');
    jobSource = json.getString('jobSource');
    sId = json.getString('_id');
    jobType = json.getString('jobType');
    jobTypes = json.getString('jobTypes');
    model = json.getString('model');
    var sIds = json.getList('servicesIds');
    servicesIds = sIds?.map((e) => e.toString()).toList();
    var deviceMap = json.getMap('deviceId');
    deviceId = deviceMap != null ? DeviceId.fromJson(deviceMap) : null;
    jobContactId = json.getString('jobContactId');
    var defectMap = json.getMap('defectId');
    defectId = defectMap != null ? DefectId.fromJson(defectMap) : null;
    subTotal = json['subTotal'];
    total = json['total'];
    vat = json['vat'];
    discount = json['discount'];
    jobNo = json.getString('jobNo');
    customerId = json.getString('customerId');
    var itemsList = json.getList('assignedItemsIds');
    if (itemsList != null) {
      assignedItemsIds = <AssignedItems>[];
      for (var v in itemsList) {
        if (v is Map<String, dynamic>) {
          assignedItemsIds!.add(AssignedItems.fromJson(v));
        }
      }
    }
    emailConfirmation = json.getBool('emailConfirmation');
    var filesList = json.getList('files');
    if (filesList != null) {
      files = <Files>[];
      for (var v in filesList) {
        if (v is Map<String, dynamic>) {
          files!.add(Files.fromJson(v));
        }
      }
    }
    prdynamicDeviceLabel = json.getBool('prdynamicDeviceLabel');
    var statusList = json.getList('jobStatus');
    if (statusList != null) {
      jobStatus = <JobStatus>[];
      for (var v in statusList) {
        if (v is Map<String, dynamic>) {
          jobStatus!.add(JobStatus.fromJson(v));
        }
      }
    }
    var customerMap = json.getMap('customerDetails');
    customerDetails = customerMap != null
        ? CustomerDetails.fromJson(customerMap)
        : null;
    status = json.getString('status');
    location = json.getString('location');
    userId = json.getString('userId');
    createdAt = json.getString('createdAt');
    updatedAt = json.getString('updatedAt');
    iV = json['__v'];
    jobTrackingNumber = json.getString('job_tracking_number');
    physicalLocation = json.getString('physicalLocation');
    prdynamicOption = json.getString('prdynamicOption');
    signatureFilePath = json.getString('signatureFilePath');
    var deviceDataMap = json.getMap('deviceData');
    deviceData = deviceDataMap != null
        ? DeviceData.fromJson(deviceDataMap)
        : null;
    jobPriority = json.getString('job_priority');
    assignUser = json.getString('assign_user');
    assignerName = json.getString('assigner_name');
    id = json.getString('id');
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
      data['assignedItemsIds'] = assignedItemsIds!
          .map((v) => v.toJson())
          .toList();
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
    sId = json.getString('_id');
    brand = json.getString('brand');
    model = json.getString('model');
    category = json.getString('category');
    imei = json.getString('imei');
    var condList = json.getList('condition');
    if (condList != null) {
      condition = <Condition>[];
      for (var v in condList) {
        if (v is Map<String, dynamic>) {
          condition!.add(Condition.fromJson(v));
        }
      }
    }

    deviceSecurity = json.getString('deviceSecurity');

    color = json.getString('color');
    createdAt = json.getString('createdAt');
    updatedAt = json.getString('updatedAt');
    iV = json['__v'];
    id = json.getString('id');
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
    value = json.getString('value');
    id = json.getString('id');
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
    sId = json.getString('_id');
    var defectList = json.getList('defect');
    if (defectList != null) {
      defect = <Defect>[];
      for (var v in defectList) {
        if (v is Map<String, dynamic>) {
          defect!.add(Defect.fromJson(v));
        }
      }
    }
    jobType = json.getString('jobType');
    reference = json.getString('reference');
    description = json.getString('description');
    var notesList = json.getList('internalNote');
    if (notesList != null) {
      internalNote = <InternalNote>[];
      for (var v in notesList) {
        if (v is Map<String, dynamic>) {
          internalNote!.add(InternalNote.fromJson(v));
        }
      }
    }
    var items = json.getList('assignItems');
    assignItems = items?.map((e) => e.toString()).toList();
    createdAt = json.getString('createdAt');
    updatedAt = json.getString('updatedAt');
    iV = json['__v'];
    id = json.getString('id');
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
    text = json.getString('text');
    userId = json.getString('userId');
    createdAt = json['createdAt'];
    userName = json.getString('userName');
    id = json.getString('id');
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
    file = json.getString('file');
    id = json.getString('id');
    fileName = json.getString('fileName');
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
    title = json.getString('title');
    userId = json.getString('userId');
    colorCode = json.getString('colorCode');
    userName = json.getString('userName');
    createAtStatus = json['createAtStatus'];
    notifications = json.getBool('notifications');
    email = json.getString('email');
    notes = json.getString('notes');
    priority = json.getString('priority');
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
    customerId = json.getString('customerId');
    type = json.getString('type');
    type2 = json.getString('type2');
    organization = json.getString('organization');
    customerNo = json.getString('customerNo');
    email = json.getString('email');
    telephone = json.getString('telephone');
    var billingMap = json.getMap('billing_address');
    billingAddress = billingMap != null
        ? BillingAddress.fromJson(billingMap)
        : null;
    salutation = json.getString('salutation');
    firstName = json.getString('firstName');
    lastName = json.getString('lastName');
    position = json.getString('position');
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

  BillingAddress({
    this.sId,
    this.street,
    this.zip,
    this.city,
    this.country,
    this.customerId,
    this.iV,
  });

  BillingAddress.fromJson(Map<String, dynamic> json) {
    sId = json.getString('_id');
    street = json.getString('street');
    zip = json.getString('zip');
    city = json.getString('city');
    country = json.getString('country');
    customerId = json.getString('customerId');
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
    sId = json.getString('_id');
    brand = json.getString('brand');
    model = json.getString('model');
    category = json.getString('category');
    imei = json.getString('imei');
    var condList = json.getList('condition');
    if (condList != null) {
      condition = <Condition>[];
      for (var v in condList) {
        if (v is Map<String, dynamic>) {
          condition!.add(Condition.fromJson(v));
        }
      }
    }

    deviceSecurity = json.getString('deviceSecurity');

    color = json.getString('color');
    createdAt = json.getString('createdAt');
    updatedAt = json.getString('updatedAt');
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
  dynamic id;
  dynamic itemNumber;
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
    productName = json.getString('productName');
    priceExclVat = json['price_excl_vat'];
    vat = json['vat'];
    priceInclVat = json['price_incl_vat'];
    id = json['id'];
    itemNumber = json['itemNumber'];
    unit = json['unit'];
    physicalLocation = json.getString('physicalLocation');
    stockQty = json['stockQty'];
    amount = json['amount'];
    description = json.getString('description');
    manufacturer = json.getString('manufacturer');
    manufacturerNumber = json.getString('manufacturerNumber');
    color = json.getString('color');
    condition = json.getString('condition');
    category = json.getString('category');
    serialNoManagement = json.getBool('serialNoManagement');
    lineItemId = json.getString('lineItemId');
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

  Status({
    this.title,
    this.userId,
    this.priority,
    this.email,
    this.colorCode,
    this.createdAt,
  });

  Status.fromJson(Map<String, dynamic> json) {
    title = json.getString('title');
    userId = json.getString('userId');
    priority = json['priority'];
    email = json.getString('email');
    colorCode = json.getString('colorCode');
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

  ReceiptFooter({
    this.companyLogo,
    this.companyLogoURL,
    this.address,
    this.contact,
    this.bank,
  });

  ReceiptFooter.fromJson(Map<String, dynamic> json) {
    companyLogo = json.getString('companyLogo');
    companyLogoURL = json.getString('companyLogoURL');
    var addrMap = json.getMap('address');
    address = addrMap != null ? Address.fromJson(addrMap) : null;
    var contMap = json.getMap('contact');
    contact = contMap != null ? Contact.fromJson(contMap) : null;
    var bankMap = json.getMap('bank');
    bank = bankMap != null ? Bank.fromJson(bankMap) : null;
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

  Address({
    this.companyName,
    this.street,
    this.num,
    this.zip,
    this.city,
    this.country,
  });

  Address.fromJson(Map<String, dynamic> json) {
    companyName = json.getString('companyName');
    street = json.getString('street');
    num = json.getString('num');
    zip = json.getString('zip');
    city = json.getString('city');
    country = json.getString('country');
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
    ceo = json.getString('ceo');
    telephone = json.getString('telephone');
    email = json.getString('email');
    website = json.getString('website');
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
    bankName = json.getString('bankName');
    iban = json.getString('iban');
    bic = json.getString('bic');
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
    sId = json.getString('_id');
    email = json.getString('email');
    fullName = json.getString('fullName');
    id = json.getString('id');
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
    sId = json.getString('_id');
    quotationNo = json.getString('quotationNo');
    companyId = json.getString('companyId');
    jobId = json.getString('jobId');
    text = json.getString('text');
    status = json.getString('status');
    subTotal = json['subTotal'];
    total = json['total'];
    discount = json['discount'];
    rejectAmount = json['rejectAmount'];
    acceptAmount = json['acceptAmount'];
    quotationName = json.getString('quotationName');
    send = json.getBool('send');
    anyTimeSend = json.getBool('anyTimeSend');
    changed = json.getBool('changed');
    paid = json.getBool('paid');
    rejectPaid = json.getBool('rejectPaid');
    accepted = json.getBool('accepted');
    rejected = json.getBool('rejected');
    var items = json.getList('serviceItemList');
    if (items != null) {
      serviceItemList = <ServiceItemList>[];
      for (var v in items) {
        if (v is Map<String, dynamic>) {
          serviceItemList!.add(ServiceItemList.fromJson(v));
        }
      }
    }
    vat = json['vat'];
    var customerMap = json.getMap('customerDetails');
    customerDetails = customerMap != null
        ? CustomerDetails.fromJson(customerMap)
        : null;
    userName = json.getString('userName');
    onlinePaymentActived = json.getBool('onlinePaymentActived');
    userId = json.getString('userId');
    createdAt = json.getString('createdAt');
    updatedAt = json.getString('updatedAt');
    iV = json['__v'];
    paymentId = json.getString('paymentId');
    rejectPaymentId = json.getString('rejectPaymentId');
    paymentMethod = json.getString('paymentMethod');
    paymentStatus = json.getString('paymentStatus');
    paymentLink = json.getString('paymentLink');
    rejectPaymentLink = json.getString('rejectPaymentLink');
    id = json.getString('id');
    paidId = json.getString('paidId');
    rejectPaidId = json.getString('rejectPaidId');
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
      data['serviceItemList'] = serviceItemList!
          .map((v) => v.toJson())
          .toList();
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
    userId = json.getString('userId');
    message = json.getString('message');
    notificationId = json.getString('notification_id');
    isRead = json.getBool('isRead');
    messageType = json.getString('messageType');
    conversationId = json.getString('conversationId');
    var senderMap = json.getMap('sender_details');
    senderDetails = senderMap != null ? Sender.fromJson(senderMap) : null;
    var receiverMap = json.getMap('receiver_details');
    receiverDetails = receiverMap != null ? Sender.fromJson(receiverMap) : null;
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

  UserId({
    this.sId,
    this.email,
    this.fullName,
    this.avatar,
    this.position,
    this.userType,
    this.id,
  });

  UserId.fromJson(Map<String, dynamic> json) {
    sId = json.getString('_id');
    email = json.getString('email');
    fullName = json.getString('fullName');
    avatar = json.getString('avatar');
    position = json.getString('position');
    userType = json.getString('userType');
    id = json.getString('id');
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
