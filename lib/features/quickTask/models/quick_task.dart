class QuickTask {
  bool? success;
  List<Task>? data;

  QuickTask({this.success, this.data});

  QuickTask.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = <Task>[];
      json['data'].forEach((v) {
        data!.add(Task.fromJson(v));
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

class Task {
  String? sId;
  String? title;
  String? dateTime;
  bool? complete;
  bool? send;
  String? createdBy;
  String? email;
  String? userId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  Task({
    this.sId,
    this.title,
    this.dateTime,
    this.complete,
    this.send,
    this.createdBy,
    this.email,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.id,
  });

  Task.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    dateTime = json['dateTime'];
    complete = json['complete'];
    send = json['send'];
    createdBy = json['createdBy'];
    email = json['email'];
    userId = json['userId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['dateTime'] = dateTime;
    data['complete'] = complete;
    data['send'] = send;
    data['createdBy'] = createdBy;
    data['email'] = email;
    data['userId'] = userId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['id'] = id;
    return data;
  }
}
