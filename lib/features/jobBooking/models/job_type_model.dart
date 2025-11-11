class JobTypeModel {
  bool? success;
  List<JobType>? data;

  JobTypeModel({this.success, this.data});

  JobTypeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <JobType>[];
      json['data'].forEach((v) {
        data!.add(JobType.fromJson(v));
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

class JobType {
  String? sId;
  String? name;
  bool? isAdmin;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  JobType({
    this.sId,
    this.name,
    this.isAdmin,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
  });

  JobType.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
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
    data['name'] = name;
    data['isAdmin'] = isAdmin;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}
