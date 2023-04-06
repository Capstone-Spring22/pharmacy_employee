import 'package:pharmacy_employee/models/ingredient.dart';

class DescriptionModels {
  String? id;
  String? effect;
  String? instruction;
  String? sideEffect;
  String? contraindications;
  String? preserve;
  List<IngredientModel>? ingredientModel;

  DescriptionModels(
      {this.id,
      this.effect,
      this.instruction,
      this.sideEffect,
      this.contraindications,
      this.preserve,
      this.ingredientModel});

  DescriptionModels.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    effect = json['effect'];
    instruction = json['instruction'];
    sideEffect = json['sideEffect'];
    contraindications = json['contraindications'];
    preserve = json['preserve'];
    if (json['ingredientModel'] != null) {
      ingredientModel = <IngredientModel>[];
      json['ingredientModel'].forEach((v) {
        ingredientModel!.add(IngredientModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['effect'] = effect;
    data['instruction'] = instruction;
    data['sideEffect'] = sideEffect;
    data['contraindications'] = contraindications;
    data['preserve'] = preserve;
    if (ingredientModel != null) {
      data['ingredientModel'] =
          ingredientModel!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
