import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/models/ingredient.dart';

class IngredientsText extends StatelessWidget {
  const IngredientsText({super.key, required this.ingre});

  final List<IngredientModel> ingre;

  @override
  Widget build(BuildContext context) {
    String text = "";
    for (var element in ingre) {
      String contentString = element.content.toString();
      if (contentString.endsWith(".0")) {
        contentString = contentString.substring(0, contentString.length - 2);
      }
      text +=
          "${element.ingredientName} ($contentString ${element.unitName}), ";
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            "Thành Phần:",
            style: context.textTheme.titleLarge,
          ),
          AutoSizeText(
            text,
            style: context.textTheme.titleMedium!.copyWith(color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
