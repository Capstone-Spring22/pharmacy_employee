class Site {
  String? id;
  String? imageUrl;
  String? siteName;
  String? addressId;
  String? fullyAddress;
  String? lastUpdate;
  String? description;
  String? contactInfo;
  bool? isActivate;
  bool? isDelivery;

  Site(
      {this.id,
      this.imageUrl,
      this.siteName,
      this.addressId,
      this.fullyAddress,
      this.lastUpdate,
      this.description,
      this.contactInfo,
      this.isActivate,
      this.isDelivery});

  Site.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageUrl = json['imageUrl'];
    siteName = json['siteName'];
    addressId = json['addressId'];
    fullyAddress = json['fullyAddress'];
    lastUpdate = json['lastUpdate'];
    description = json['description'];
    contactInfo = json['contactInfo'];
    isActivate = json['isActivate'];
    isDelivery = json['isDelivery'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['imageUrl'] = imageUrl;
    data['siteName'] = siteName;
    data['addressId'] = addressId;
    data['fullyAddress'] = fullyAddress;
    data['lastUpdate'] = lastUpdate;
    data['description'] = description;
    data['contactInfo'] = contactInfo;
    data['isActivate'] = isActivate;
    data['isDelivery'] = isDelivery;
    return data;
  }
}
