class OrderStatusHistory {
  String? statusId;
  String? statusName;
  String? userId;
  bool? isInternal;
  String? fullName;
  List<StatusDescriptions>? statusDescriptions;

  OrderStatusHistory(
      {this.statusId,
      this.statusName,
      this.userId,
      this.isInternal,
      this.fullName,
      this.statusDescriptions});

  OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    statusId = json['statusId'];
    statusName = json['statusName'];
    userId = json['userId'];
    isInternal = json['isInternal'];
    fullName = json['fullName'];
    if (json['statusDescriptions'] != null) {
      statusDescriptions = <StatusDescriptions>[];
      json['statusDescriptions'].forEach((v) {
        statusDescriptions!.add(StatusDescriptions.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusId'] = statusId;
    data['statusName'] = statusName;
    data['userId'] = userId;
    data['isInternal'] = isInternal;
    data['fullName'] = fullName;
    if (statusDescriptions != null) {
      data['statusDescriptions'] =
          statusDescriptions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StatusDescriptions {
  String? description;
  String? time;

  StatusDescriptions({this.description, this.time});

  StatusDescriptions.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['time'] = time;
    return data;
  }
}
