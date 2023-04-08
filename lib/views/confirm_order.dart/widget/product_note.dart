import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/input.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';

class ProductNote extends StatefulWidget {
  const ProductNote({super.key, required this.order, required this.index});

  final OrderHistoryDetail order;
  final int index;

  @override
  State<ProductNote> createState() => _ProductNoteState();
}

class _ProductNoteState extends State<ProductNote> {
  final TextEditingController txt = TextEditingController();
  @override
  Widget build(BuildContext context) {
    OrderProducts product = widget.order.orderProducts![widget.index];
    txt.text = product.productNoteFromPharmacist ?? "";
    return Column(
      children: [
        ListTile(
          onTap: () => Get.toNamed(
            '/product_detail',
            arguments: product.productId,
          ),
          title: Text(
              style: TextStyle(fontSize: appController.fontSize.value),
              product.productName!),
          subtitle: Text(
            style: TextStyle(fontSize: appController.fontSize.value),
            "Số Lượng: ${product.quantity!} ${product.unitName}",
          ),
          trailing: Text(
            style: TextStyle(fontSize: appController.fontSize.value),
            product.priceTotal!.convertCurrentcy(),
          ),
        ),
        Input(
          inputController: txt,
          inputAction: TextInputAction.done,
          onSubmit: (p0) async {
            await AppService().putOrderNote(product.id!, txt.text);
            // await AppService().;
          },
          title: "Ghi chú sản phẩm",
        )
      ],
    );
  }
}
