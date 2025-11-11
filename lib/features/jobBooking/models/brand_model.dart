class BrandModel {
  String? sId;
  String? name;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  BrandModel({
    this.sId,
    this.name,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
  });

  BrandModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}
