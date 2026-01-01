class MessageModel {
  final String? id;
  final SenderReceiver? sender;
  final SenderReceiver? receiver;
  final MessageContent? message;
  final bool? seen;
  final String? conversationId;
  final String? userId;
  final String? participants;
  final String? loggedUserId;
  final List<AttachmentModel>? attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MessageModel({
    this.id,
    this.sender,
    this.receiver,
    this.message,
    this.seen,
    this.conversationId,
    this.userId,
    this.participants,
    this.loggedUserId,
    this.attachments,
    this.createdAt,
    this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id'] ?? json['id'],
      sender: json['sender'] != null ? SenderReceiver.fromJson(json['sender']) : null,
      receiver: json['receiver'] != null ? SenderReceiver.fromJson(json['receiver']) : null,
      message: json['message'] != null ? MessageContent.fromJson(json['message']) : null,
      seen: json['seen'],
      conversationId: json['conversationId'],
      userId: json['userId'],
      participants: json['participants'],
      loggedUserId: json['loggedUserId'],
      attachments: json['attachment'] != null
          ? (json['attachment'] as List).map((a) => AttachmentModel.fromJson(a)).toList()
          : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      if (sender != null) 'sender': sender!.toJson(),
      if (receiver != null) 'receiver': receiver!.toJson(),
      if (message != null) 'message': message!.toJson(),
      if (seen != null) 'seen': seen,
      if (conversationId != null) 'conversationId': conversationId,
      if (userId != null) 'userId': userId,
      if (participants != null) 'participants': participants,
      if (loggedUserId != null) 'loggedUserId': loggedUserId,
      if (attachments != null) 'attachment': attachments!.map((a) => a.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }
}

class SenderReceiver {
  final String? email;
  final String? name;

  SenderReceiver({this.email, this.name});

  factory SenderReceiver.fromJson(Map<String, dynamic> json) {
    return SenderReceiver(email: json['email'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {if (email != null) 'email': email, if (name != null) 'name': name};
  }
}

class MessageContent {
  final String? message;
  final String? messageType; // "standard", "attachment", "comment", "quotation"
  final String? jobId;
  final QuotationModel? quotation;

  MessageContent({this.message, this.messageType, this.jobId, this.quotation});

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      message: json['message'],
      messageType: json['messageType'],
      jobId: json['jobId'],
      quotation: json['quotation'] != null ? QuotationModel.fromJson(json['quotation']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (message != null) 'message': message,
      if (messageType != null) 'messageType': messageType,
      if (jobId != null) 'jobId': jobId,
      if (quotation != null) 'quotation': quotation!.toJson(),
    };
  }
}

class AttachmentModel {
  final String? url;
  final String? name;
  final String? type;
  final int? size;

  AttachmentModel({this.url, this.name, this.type, this.size});

  factory AttachmentModel.fromJson(Map<String, dynamic> json) {
    return AttachmentModel(url: json['url'], name: json['name'], type: json['type'], size: json['size']);
  }

  Map<String, dynamic> toJson() {
    return {
      if (url != null) 'url': url,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (size != null) 'size': size,
    };
  }
}

class QuotationModel {
  final String? service;
  final String? description;
  final int? unit;
  final double? price;
  final double? subtotal;
  final double? vatPercent;
  final double? vatAmount;
  final double? totalAmount;
  final bool? accepted;
  final String? acceptedAt;
  final String? paymentStatus; // "Paid", "Not Paid"
  final DateTime? timestamp;

  QuotationModel({
    this.service,
    this.description,
    this.unit,
    this.price,
    this.subtotal,
    this.vatPercent,
    this.vatAmount,
    this.totalAmount,
    this.accepted,
    this.acceptedAt,
    this.paymentStatus,
    this.timestamp,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    return QuotationModel(
      service: json['service'],
      description: json['description'],
      unit: json['unit'],
      price: json['price']?.toDouble(),
      subtotal: json['subtotal']?.toDouble(),
      vatPercent: json['vatPercent']?.toDouble(),
      vatAmount: json['vatAmount']?.toDouble(),
      totalAmount: json['totalAmount']?.toDouble(),
      accepted: json['accepted'],
      acceptedAt: json['acceptedAt'],
      paymentStatus: json['paymentStatus'],
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (service != null) 'service': service,
      if (description != null) 'description': description,
      if (unit != null) 'unit': unit,
      if (price != null) 'price': price,
      if (subtotal != null) 'subtotal': subtotal,
      if (vatPercent != null) 'vatPercent': vatPercent,
      if (vatAmount != null) 'vatAmount': vatAmount,
      if (totalAmount != null) 'totalAmount': totalAmount,
      if (accepted != null) 'accepted': accepted,
      if (acceptedAt != null) 'acceptedAt': acceptedAt,
      if (paymentStatus != null) 'paymentStatus': paymentStatus,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }
}

// ConversationModel removed - use conversation_model.dart for receiving messages
// This file is only for sending messages using MessageModel
