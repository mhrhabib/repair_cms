class ModelsModel {
  String? sId;
  String? name;
  String? brandId;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  ModelsModel({
    this.sId,
    this.name,
    this.brandId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
  });

  ModelsModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    brandId = json['brandId'];
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
    data['brandId'] = brandId;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}
