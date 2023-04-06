class DiscountModel {
  String? title;
  String? reason;
  num? discountPercent;
  num? discountMoney;

  DiscountModel(
      {this.title, this.reason, this.discountPercent, this.discountMoney});

  DiscountModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    reason = json['reason'];
    discountPercent = json['discountPercent'];
    discountMoney = json['discountMoney'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['reason'] = reason;
    data['discountPercent'] = discountPercent;
    data['discountMoney'] = discountMoney;
    return data;
  }

  @override
  String toString() {
    return 'DiscountModel(title: $title, reason: $reason, discountPercent: $discountPercent, discountMoney: $discountMoney)';
  }
}
