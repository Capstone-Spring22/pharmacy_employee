import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/models/description.dart';
import 'package:pharmacy_employee/models/product_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/product_detail/widget/content_info.dart';
import 'package:pharmacy_employee/views/product_detail/widget/ingre.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final id = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Product Detail"),
      ),
      body: FutureBuilder(
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingWidget(
                size: 60,
              ),
            );
          } else {
            final product = PharmacyDetail.fromJson(snapshot.data);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      product.name!,
                      style: context.textTheme.headlineMedium,
                    ),
                  ),
                  ContentInfo(
                    title: "Price",
                    content: convertCurrency(product.price!),
                  ),
                  ContentInfo(
                    title: "Unit",
                    content: product.unitName!,
                  ),
                  ContentInfo(
                    title: "Type",
                    content: product.isPrescription!
                        ? "Prescription"
                        : "Non-Precription",
                  ),
                  if (product.productUnitReferences!.isNotEmpty)
                    ContentInfo(
                      title: "Other Units",
                      content: product.productUnitReferences!
                          .map((e) => e.unitName)
                          .join(", "),
                    ),
                  if (product.totalUnitOnly != null)
                    ContentInfo(
                      title: "Category",
                      content: product.totalUnitOnly!,
                    ),
                  ...descriptionWidgets(product.descriptionModels!),
                ],
              ),
            );
          }
        },
        future: AppService().fetchProductDetail(id),
      ),
    );
  }

  List descriptionWidgets(DescriptionModels desc) {
    return [
      if (desc.effect != 'string')
        ContentInfo(
          title: "Effect",
          content: desc.effect!,
        ),
      if (desc.instruction != 'string')
        ContentInfo(
          title: "Instruction",
          content: desc.instruction!,
        ),
      if (desc.sideEffect != 'string')
        ContentInfo(
          title: "SideEffect",
          content: desc.sideEffect!,
        ),
      if (desc.contraindications != 'string')
        ContentInfo(
          title: "Contraindications",
          content: desc.contraindications!,
        ),
      if (desc.preserve != 'string')
        ContentInfo(
          title: "Preserve",
          content: desc.preserve!,
        ),
      if (desc.ingredientModel!.isNotEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: IngredientsText(
            ingre: desc.ingredientModel!,
          ),
        )
    ];
  }
}
