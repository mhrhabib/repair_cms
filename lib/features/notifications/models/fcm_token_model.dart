class FcmTokenModel {
  String? sId;
  String? token;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;

  FcmTokenModel({
    this.sId,
    this.token,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  FcmTokenModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    token = json['token'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sId != null) data['_id'] = sId;
    if (token != null) data['token'] = token;
    if (userId != null) data['userId'] = userId;
    if (createdAt != null) data['createdAt'] = createdAt;
    if (updatedAt != null) data['updatedAt'] = updatedAt;
    if (iV != null) data['__v'] = iV;
    return data;
  }
}
