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
        title: const Text("Thông Tin Sản Phẩm"),
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
                    title: "Giá",
                    content: convertCurrency(product.price!),
                  ),
                  ContentInfo(
                    title: "Đơn Vị",
                    content: product.unitName!,
                  ),
                  ContentInfo(
                    title: "Loại",
                    content: product.isPrescription!
                        ? "Thuốc Kê Đơn"
                        : "Thuốc Không Kê Đơn",
                  ),
                  if (product.productUnitReferences!.isNotEmpty)
                    ContentInfo(
                      title: "Các Đơn Vị Khác",
                      content: product.productUnitReferences!
                          .map((e) => e.unitName)
                          .join(", "),
                    ),
                  if (product.totalUnitOnly != null)
                    ContentInfo(
                      title: "Danh Mục",
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
          title: "Tác Dụng",
          content: desc.effect!,
        ),
      if (desc.instruction != 'string')
        ContentInfo(
          title: "Hướng Dẫn Sử Dụng",
          content: desc.instruction!,
        ),
      if (desc.sideEffect != 'string')
        ContentInfo(
          title: "Tác Dụng Phụ",
          content: desc.sideEffect!,
        ),
      if (desc.contraindications != 'string')
        ContentInfo(
          title: "Chống chỉ định",
          content: desc.contraindications!,
        ),
      if (desc.preserve != 'string')
        ContentInfo(
          title: "Bảo Quản",
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
