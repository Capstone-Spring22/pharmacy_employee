import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/views/prep_delivery.dart/prep_delivery.dart';

class PrepOrder extends StatefulWidget {
  const PrepOrder({super.key, required this.order});

  final OrderHistoryDetail order;

  @override
  State<PrepOrder> createState() => _PrepOrderState();
}

class _PrepOrderState extends State<PrepOrder> {
  List<int> selected = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SwipeButton.expand(
          thumb: const Icon(
            Icons.double_arrow_rounded,
            color: Colors.white,
          ),
          enabled: selected.length == widget.order.orderProducts!.length,
          activeThumbColor: context.theme.primaryColor,
          activeTrackColor: Colors.grey.shade300,
          onSwipe: () {
            if (widget.order.orderTypeId == 3) {
              Get.to(() => PrepDeliveryScreen(
                    order: widget.order,
                  ));
            }
          },
          child: Text(
            "Sang Bước Tiếp Theo",
            style: context.textTheme.headlineSmall,
          ),
        ),
      ),
      appBar: AppBar(
        title: const Text("Chuẩn bị thuốc"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
              itemCount: widget.order.orderProducts!.length,
              itemBuilder: (context, index) {
                final item = widget.order.orderProducts![index];
                return Column(
                  children: [
                    CupertinoListTile.notched(
                      leading: Checkbox(
                        value: selected.contains(index),
                        onChanged: (value) {
                          if (value!) {
                            setState(() {
                              selected.add(index);
                            });
                          } else {
                            setState(() {
                              selected.remove(index);
                            });
                          }
                        },
                      ),
                      title: Text(
                        item.productName!,
                        style:
                            TextStyle(fontSize: appController.fontSize.value),
                        maxLines: 3,
                      ),
                      subtitle: Text(
                        "Số lượng ${item.quantity} - ${item.unitName}",
                        style:
                            TextStyle(fontSize: appController.fontSize.value),
                      ),
                    ),
                    const Divider()
                  ],
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
