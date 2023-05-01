import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/main.dart';

import '../../../models/order.dart';

class ItemProcess extends StatelessWidget {
  const ItemProcess({super.key, required this.item, required this.index});

  final OrderHistory item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final fontSize = appController.fontSize.value;
    return GestureDetector(
      onTap: () {
        Get.toNamed('/order_detail', arguments: item.id);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Obx(() => MSHCheckbox(
                    size: 30,
                    duration: 400.ms,
                    value: appController.orderProcessList.contains(item.id),
                    onChanged: (value) {
                      if (value) {
                        if (appController.orderProcessList.isEmpty) {
                          appController.orderType.value = item.orderTypeName!;
                        }
                        if (item.orderTypeName !=
                            appController.orderType.value) {
                          Get.showSnackbar(
                            GetSnackBar(
                              message:
                                  "Không thể thực hiện đơn hàng có loại khác nhau",
                              backgroundColor: context.theme.colorScheme.error,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          appController.orderProcessList.add(item.id!);
                        }
                      } else {
                        appController.orderProcessList.remove(item.id);
                      }
                    },
                  )),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.primaryColor,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade300,
                                blurRadius: 7,
                                spreadRadius: 5,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(10),
                            color:
                                appController.orderProcessList.contains(item.id)
                                    ? theme.secondaryHeaderColor
                                    : Colors.white),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (kDebugMode)
                              Text(
                                "order status: ${item.orderStatus}",
                                style: TextStyle(
                                  fontSize: fontSize,
                                ),
                              ),
                            Text(
                              "Tình Trạng: ${item.orderStatusName}",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: theme.primaryColor,
                              ),
                            ),
                            Text(
                              "Ngày Tạo: ${item.createdDate!.convertToDate}",
                              style: TextStyle(
                                fontSize: fontSize,
                              ),
                            ),
                            Text(
                              "Loại Đơn: ${item.orderTypeName}",
                              style: TextStyle(
                                fontSize: fontSize,
                              ),
                            ),
                            Text(
                              item.paymentMethod.toString(),
                              style: TextStyle(
                                fontSize: fontSize,
                              ),
                            ),
                            Text(
                              "Tổng Tiền: ${item.totalPrice!.convertCurrentcy()}",
                              style: TextStyle(
                                fontSize: fontSize,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideX(delay: (index * 20).ms).fade(),
    );
  }
}
