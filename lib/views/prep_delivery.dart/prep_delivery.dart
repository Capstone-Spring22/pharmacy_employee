import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';

class PrepDeliveryScreen extends StatelessWidget {
  const PrepDeliveryScreen({super.key, required this.order});

  final OrderHistoryDetail order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chuẩn bị giao hàng"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text(
                "Mã đơn hàng: ${order.id}",
                style: TextStyle(fontSize: appController.fontSize.value),
              ),
              subtitle: Text(
                "Ngày đặt: ${order.createdDate!.convertToDate}",
                style: TextStyle(fontSize: appController.fontSize.value),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                "Khách hàng: ${order.orderContactInfo!.fullname}",
                style: TextStyle(fontSize: appController.fontSize.value),
              ),
              subtitle: Text(
                "Số điện thoại: ${order.orderContactInfo!.phoneNumber!}",
                style: TextStyle(fontSize: appController.fontSize.value),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(
                "Địa chỉ: ${order.orderDelivery!.homeNumber!}",
                style: TextStyle(fontSize: appController.fontSize.value),
              ),
            ),
            const Divider(),
            Text(
              "Danh sách sản phẩm",
              style: TextStyle(
                fontSize: appController.fontSize.value,
              ),
            ),
            Expanded(
                child: ListView.builder(
              itemCount: order.orderProducts!.length,
              itemBuilder: (context, index) {
                final item = order.orderProducts![index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(
                        item.productName!,
                        style:
                            TextStyle(fontSize: appController.fontSize.value),
                      ),
                      subtitle: Text(
                        item.priceTotal!.convertCurrentcy(),
                        style:
                            TextStyle(fontSize: appController.fontSize.value),
                      ),
                      trailing: Text(
                        "${item.quantity} ${item.unitName}",
                        style:
                            TextStyle(fontSize: appController.fontSize.value),
                      ),
                    ),
                    const Divider()
                  ],
                );
              },
            )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SwipeButton.expand(
                thumb: const Icon(
                  Icons.double_arrow_rounded,
                  color: Colors.white,
                ),
                enabled: true,
                activeThumbColor: context.theme.primaryColor,
                activeTrackColor: Colors.grey.shade300,
                onSwipe: () async {
                  appController
                    ..launchMaps(order.orderDelivery!.homeNumber!)
                    ..startDelivery(order);
                },
                child: Text(
                  "Bắt Đầu Giao",
                  style: context.textTheme.headlineSmall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
