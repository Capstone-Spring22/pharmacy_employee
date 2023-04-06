class IngredientModel {
  String? ingredientId;
  String? ingredientName;
  num? content;
  String? unitId;
  String? unitName;

  IngredientModel(
      {this.ingredientId,
      this.ingredientName,
      this.content,
      this.unitId,
      this.unitName});

  IngredientModel.fromJson(Map<String, dynamic> json) {
    ingredientId = json['ingredientId'];
    ingredientName = json['ingredientName'];
    content = json['content'];
    unitId = json['unitId'];
    unitName = json['unitName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ingredientId'] = ingredientId;
    data['ingredientName'] = ingredientName;
    data['content'] = content;
    data['unitId'] = unitId;
    data['unitName'] = unitName;
    return data;
  }
}
