import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';
import 'package:pharmacy_employee/views/prep_delivery.dart/widget/callBtn.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderTileDelivery extends StatelessWidget {
  const OrderTileDelivery(
      {super.key,
      required this.address,
      required this.distance,
      required this.orderId,
      required this.phone,
      required this.total,
      required this.orders,
      required this.i,
      required this.orderAction,
      required this.color});

  final String address;
  final String distance;
  final String orderId;
  final String phone;
  final String total;
  final List<OrderHistoryDetail?> orders;
  final int i;
  final Function orderAction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.alt_route,
              color: color,
              size: 30,
            ),
          ],
        ),
        title: Text("Địa chỉ: $address"),
        subtitle: Text(
          "Khoảng cách: $distance",
        ),
        minLeadingWidth: Get.width * .05,
      ),
      children: [
        DetailContent(
          title: 'Mã Đơn hàng',
          content: Text(orderId),
          haveDivider: false,
        ),
        DetailContent(
          title: 'Tên khách hàng',
          content: Text(orders[i]!.orderContactInfo!.fullname!),
          haveDivider: false,
        ),
        GestureDetector(
          onTap: () async {
            await launchUrl(
              Uri.parse('tel:$phone'),
            );
          },
          child: CallButton(orders: orders, i: i),
        ),
        DetailContent(
          title: 'Tổng tiền',
          content: Text(orders[i]!.totalPrice!.convertCurrentcy()),
          haveDivider: false,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () {
                Get.toNamed('/order_detail', arguments: orders[i]!.id);
              },
              child: const Text("Xem chi tiết"),
            ),
            TextButton(
              onPressed: () async {
                appController.startDelivery(orders[i]!);
                appController
                    .launchMaps(orders[i]!.orderDelivery!.fullyAddress!);
              },
              child: const Text("Dùng Google Map"),
            ),
            FilledButton(
              onPressed: () => orderAction(
                i,
                orders[i]!.totalPrice!,
                orders[i]!.paymentMethodId != 1,
              ),
              child: const Text("Xử lý"),
            ),
          ],
        ),
      ],
    );
  }
}
