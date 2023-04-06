// ignore_for_file: public_member_api_docs, sort_constructors_first
class OrderHistoryDetail {
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
  String? note;
  String? createdDate;
  bool? needAcceptance;
  List<OrderProducts>? orderProducts;
  ActionStatus? actionStatus;
  OrderContactInfo? orderContactInfo;
  OrderPickUp? orderPickUp;
  OrderDelivery? orderDelivery;

  OrderHistoryDetail(
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
      this.note,
      this.createdDate,
      this.needAcceptance,
      this.orderProducts,
      this.actionStatus,
      this.orderContactInfo,
      this.orderPickUp,
      this.orderDelivery});

  OrderHistoryDetail.fromJson(Map<String, dynamic> json) {
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
    note = json['note'];
    createdDate = json['createdDate'];
    needAcceptance = json['needAcceptance'];
    if (json['orderProducts'] != null) {
      orderProducts = <OrderProducts>[];
      json['orderProducts'].forEach((v) {
        orderProducts!.add(OrderProducts.fromJson(v));
      });
    }

    actionStatus = json['actionStatus'] != null
        ? ActionStatus.fromJson(json['actionStatus'])
        : null;
    orderContactInfo = json['orderContactInfo'] != null
        ? OrderContactInfo.fromJson(json['orderContactInfo'])
        : null;
    orderPickUp = json['orderPickUp'] != null
        ? OrderPickUp.fromJson(json['orderPickUp'])
        : null;
    orderDelivery = json['orderDelivery'] != null
        ? OrderDelivery.fromJson(json['orderDelivery'])
        : null;
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
    data['note'] = note;
    data['createdDate'] = createdDate;
    data['needAcceptance'] = needAcceptance;
    if (orderProducts != null) {
      data['orderProducts'] = orderProducts!.map((v) => v.toJson()).toList();
    }
    data['actionStatus'] = actionStatus;
    if (orderContactInfo != null) {
      data['orderContactInfo'] = orderContactInfo!.toJson();
    }
    if (orderPickUp != null) {
      data['orderPickUp'] = orderPickUp!.toJson();
    }
    if (orderDelivery != null) {
      data['orderDelivery'] = orderDelivery!.toJson();
    }
    return data;
  }
}

class OrderProducts {
  String? id;
  String? productId;
  String? imageUrl;
  String? productName;
  bool? isBatches;
  String? unitName;
  num? quantity;
  num? originalPrice;
  num? discountPrice;
  num? priceTotal;
  String? productNoteFromPharmacist;
  List<OrderBatches>? orderBatches;

  OrderProducts(
      {this.id,
      this.productId,
      this.imageUrl,
      this.productName,
      this.isBatches,
      this.unitName,
      this.quantity,
      this.originalPrice,
      this.discountPrice,
      this.priceTotal,
      this.productNoteFromPharmacist,
      this.orderBatches});

  OrderProducts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['productId'];
    imageUrl = json['imageUrl'];
    productName = json['productName'];
    isBatches = json['isBatches'];
    unitName = json['unitName'];
    quantity = json['quantity'];
    originalPrice = json['originalPrice'];
    discountPrice = json['discountPrice'];
    priceTotal = json['priceTotal'];
    productNoteFromPharmacist = json['productNoteFromPharmacist'];
    if (json['orderBatches'] != null) {
      orderBatches = <OrderBatches>[];
      json['orderBatches'].forEach((v) {
        orderBatches!.add(OrderBatches.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productId'] = productId;
    data['imageUrl'] = imageUrl;
    data['productName'] = productName;
    data['isBatches'] = isBatches;
    data['unitName'] = unitName;
    data['quantity'] = quantity;
    data['originalPrice'] = originalPrice;
    data['discountPrice'] = discountPrice;
    data['priceTotal'] = priceTotal;
    data['productNoteFromPharmacist'] = productNoteFromPharmacist;
    if (orderBatches != null) {
      data['orderBatches'] = orderBatches!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class OrderBatches {
  String? manufacturerDate;
  String? expireDate;
  num? quantity;
  String? unitName;

  OrderBatches(
      {this.manufacturerDate, this.expireDate, this.quantity, this.unitName});

  OrderBatches.fromJson(Map<String, dynamic> json) {
    manufacturerDate = json['manufacturerDate'];
    expireDate = json['expireDate'];
    quantity = json['quantity'];
    unitName = json['unitName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['manufacturerDate'] = manufacturerDate;
    data['expireDate'] = expireDate;
    data['quantity'] = quantity;
    data['unitName'] = unitName;
    return data;
  }
}

class OrderContactInfo {
  String? fullname;
  String? phoneNumber;
  String? email;

  OrderContactInfo({this.fullname, this.phoneNumber, this.email});

  OrderContactInfo.fromJson(Map<String, dynamic> json) {
    fullname = json['fullname'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['fullname'] = fullname;
    data['phoneNumber'] = phoneNumber;
    data['email'] = email;
    return data;
  }
}

class OrderPickUp {
  String? datePickUp;
  String? timePickUp;

  OrderPickUp({this.datePickUp, this.timePickUp});

  OrderPickUp.fromJson(Map<String, dynamic> json) {
    datePickUp = json['datePickUp'];
    timePickUp = json['timePickUp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['datePickUp'] = datePickUp;
    data['timePickUp'] = timePickUp;
    return data;
  }
}

class OrderDelivery {
  String? cityId;
  String? districtId;
  String? wardId;
  String? homeNumber;
  String? fullyAddress;
  num? shippingFee;
  String? addressId;

  OrderDelivery(
      {this.cityId,
      this.districtId,
      this.wardId,
      this.homeNumber,
      this.fullyAddress,
      this.shippingFee,
      this.addressId});

  OrderDelivery.fromJson(Map<String, dynamic> json) {
    cityId = json['cityId'];
    districtId = json['districtId'];
    wardId = json['wardId'];
    homeNumber = json['homeNumber'];
    fullyAddress = json['fullyAddress'];
    shippingFee = json['shippingFee'];
    addressId = json['addressId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cityId'] = cityId;
    data['districtId'] = districtId;
    data['wardId'] = wardId;
    data['homeNumber'] = homeNumber;
    data['fullyAddress'] = fullyAddress;
    data['shippingFee'] = shippingFee;
    data['addressId'] = addressId;
    return data;
  }
}

class ActionStatus {
  bool? canAccept;
  String? statusMessage;
  List<String>? missingProducts;

  ActionStatus({this.canAccept, this.statusMessage, this.missingProducts});

  ActionStatus.fromJson(Map<String, dynamic> json) {
    canAccept = json['canAccept'];
    statusMessage = json['statusMessage'];
    missingProducts = json['missingProducts'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['canAccept'] = canAccept;
    data['statusMessage'] = statusMessage;
    data['missingProducts'] = missingProducts;
    return data;
  }
}
