import 'package:pharmacy_employee/models/description.dart';
import 'package:pharmacy_employee/models/discount.dart';

class PharmacyDetail {
  String? id;
  String? productIdParent;
  String? name;
  String? nameWithUnit;
  String? totalUnitOnly;
  String? subCategoryId;
  String? manufacturerId;
  bool? isPrescription;
  bool? isBatches;
  String? unitId;
  String? unitName;
  num? unitLevel;
  num? price;
  num? priceAfterDiscount;
  DescriptionModels? descriptionModels;
  List<ImageModels>? imageModels;
  List<ProductUnitReferences>? productUnitReferences;
  DiscountModel? discountModel;

  PharmacyDetail(
      {this.id,
      this.productIdParent,
      this.name,
      this.nameWithUnit,
      this.totalUnitOnly,
      this.subCategoryId,
      this.manufacturerId,
      this.isPrescription,
      this.isBatches,
      this.unitId,
      this.unitName,
      this.unitLevel,
      this.price,
      this.priceAfterDiscount,
      this.descriptionModels,
      this.imageModels,
      this.productUnitReferences,
      this.discountModel});

  PharmacyDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productIdParent = json['productIdParent'];
    name = json['name'];
    nameWithUnit = json['nameWithUnit'];
    totalUnitOnly = json['totalUnitOnly'];
    subCategoryId = json['subCategoryId'];
    manufacturerId = json['manufacturerId'];
    isPrescription = json['isPrescription'];
    isBatches = json['isBatches'];
    unitId = json['unitId'];
    unitName = json['unitName'];
    unitLevel = json['unitLevel'];
    price = json['price'];
    priceAfterDiscount = json['priceAfterDiscount'];
    descriptionModels = json['descriptionModels'] != null
        ? DescriptionModels.fromJson(json['descriptionModels'])
        : null;
    if (json['imageModels'] != null) {
      imageModels = <ImageModels>[];
      json['imageModels'].forEach((v) {
        imageModels!.add(ImageModels.fromJson(v));
      });
    }
    if (json['productUnitReferences'] != null) {
      productUnitReferences = <ProductUnitReferences>[];
      json['productUnitReferences'].forEach((v) {
        productUnitReferences!.add(ProductUnitReferences.fromJson(v));
      });
    }

    discountModel = json['discountModel'] != null
        ? DiscountModel.fromJson(json['discountModel'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['productIdParent'] = productIdParent;
    data['name'] = name;
    data['nameWithUnit'] = nameWithUnit;
    data['totalUnitOnly'] = totalUnitOnly;
    data['subCategoryId'] = subCategoryId;
    data['manufacturerId'] = manufacturerId;
    data['isPrescription'] = isPrescription;
    data['isBatches'] = isBatches;
    data['unitId'] = unitId;
    data['unitName'] = unitName;
    data['unitLevel'] = unitLevel;
    data['price'] = price;
    data['priceAfterDiscount'] = priceAfterDiscount;
    if (descriptionModels != null) {
      data['descriptionModels'] = descriptionModels!.toJson();
    }
    if (imageModels != null) {
      data['imageModels'] = imageModels!.map((v) => v.toJson()).toList();
    }
    data['productUnitReferences'] = productUnitReferences;
    if (discountModel != null) {
      data['discountModel'] = discountModel!.toJson();
    }
    return data;
  }
}

class ImageModels {
  String? id;
  String? imageURL;

  ImageModels({this.id, this.imageURL});

  ImageModels.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    imageURL = json['imageURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['imageURL'] = imageURL;
    return data;
  }
}

class ProductUnitReferences {
  String? id;
  String? unitId;
  String? unitName;
  num? unitLevel;
  num? quantitative;

  ProductUnitReferences(
      {this.id, this.unitId, this.unitName, this.unitLevel, this.quantitative});

  ProductUnitReferences.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    unitId = json['unitId'];
    unitName = json['unitName'];
    unitLevel = json['unitLevel'];
    quantitative = json['quantitative'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['unitId'] = unitId;
    data['unitName'] = unitName;
    data['unitLevel'] = unitLevel;
    data['quantitative'] = quantitative;
    return data;
  }
}
