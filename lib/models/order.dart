class OrderHistory {
  String? id;
  String? pharmacistId;
  num? orderTypeId;
  String? orderTypeName;
  String? siteId;
  String? orderStatus;
  String? orderStatusName;
  num? totalPrice;
  num? usedPoint;
  num? paymentMethodId;
  String? paymentMethod;
  bool? isPaid;
  String? createdDate;
  bool? needAcceptance;

  OrderHistory(
      {this.id,
      this.pharmacistId,
      this.orderTypeId,
      this.orderTypeName,
      this.siteId,
      this.orderStatus,
      this.orderStatusName,
      this.totalPrice,
      this.usedPoint,
      this.paymentMethodId,
      this.paymentMethod,
      this.isPaid,
      this.createdDate,
      this.needAcceptance});

  OrderHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pharmacistId = json['pharmacistId'];
    orderTypeId = json['orderTypeId'];
    orderTypeName = json['orderTypeName'];
    siteId = json['siteId'];
    orderStatus = json['orderStatus'];
    orderStatusName = json['orderStatusName'];
    totalPrice = json['totalPrice'];
    usedPoint = json['usedPoint'];
    paymentMethodId = json['paymentMethodId'];
    paymentMethod = json['paymentMethod'];
    isPaid = json['isPaid'];
    createdDate = json['createdDate'];
    needAcceptance = json['needAcceptance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['pharmacistId'] = pharmacistId;
    data['orderTypeId'] = orderTypeId;
    data['orderTypeName'] = orderTypeName;
    data['siteId'] = siteId;
    data['orderStatus'] = orderStatus;
    data['orderStatusName'] = orderStatusName;
    data['totalPrice'] = totalPrice;
    data['usedPoint'] = usedPoint;
    data['paymentMethodId'] = paymentMethodId;
    data['paymentMethod'] = paymentMethod;
    data['isPaid'] = isPaid;
    data['createdDate'] = createdDate;
    data['needAcceptance'] = needAcceptance;
    return data;
  }
}
