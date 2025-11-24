class NotificationModel {
  bool? success;
  List<Notifications>? data;

  NotificationModel({this.success, this.data});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Notifications>[];
      json['data'].forEach((v) {
        data!.add(Notifications.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Notifications {
  String? sId;
  bool? isRead;
  String? notificationId;
  String? message;
  String? userId;
  String? locationId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;
  SenderDetails? senderDetails;
  SenderDetails? receiverDetails;
  String? messageType;
  String? quotationNo;
  String? conversationId;

  Notifications({
    this.sId,
    this.isRead,
    this.notificationId,
    this.message,
    this.userId,
    this.locationId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
    this.senderDetails,
    this.receiverDetails,
    this.messageType,
    this.quotationNo,
    this.conversationId,
  });

  Notifications.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    isRead = json['isRead'];
    notificationId = json['notification_id'];
    message = json['message'];
    userId = json['userId'];
    locationId = json['locationId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
    senderDetails = json['sender_details'] != null ? SenderDetails.fromJson(json['sender_details']) : null;
    receiverDetails = json['receiver_details'] != null ? SenderDetails.fromJson(json['receiver_details']) : null;
    messageType = json['messageType'];
    quotationNo = json['quotationNo'];
    conversationId = json['conversationId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['isRead'] = isRead;
    data['notification_id'] = notificationId;
    data['message'] = message;
    data['userId'] = userId;
    data['locationId'] = locationId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    if (senderDetails != null) {
      data['sender_details'] = senderDetails!.toJson();
    }
    if (receiverDetails != null) {
      data['receiver_details'] = receiverDetails!.toJson();
    }
    data['messageType'] = messageType;
    data['quotationNo'] = quotationNo;
    data['conversationId'] = conversationId;
    return data;
  }
}

class SenderDetails {
  String? email;
  String? name;

  SenderDetails({this.email, this.name});

  SenderDetails.fromJson(Map<String, dynamic> json) {
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
