class AccessoriesModel {
  bool? success;
  List<Data>? data;

  AccessoriesModel({this.success, this.data});

  AccessoriesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
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

class Data {
  String? sId;
  String? value;
  String? label;
  bool? isAdmin;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  Data({this.sId, this.value, this.label, this.isAdmin, this.userId, this.createdAt, this.updatedAt, this.iV, this.id});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    value = json['value'];
    label = json['label'];
    isAdmin = json['isAdmin'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['value'] = value;
    data['label'] = label;
    data['isAdmin'] = isAdmin;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}
