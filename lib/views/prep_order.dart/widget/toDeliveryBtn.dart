import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/models/map/leg.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/views/prep_delivery.dart/prep_delivery.dart';

import '../../../helpers/loading.dart';

class DeliveryButton extends StatelessWidget {
  const DeliveryButton({
    super.key,
    required this.isCompletePrep,
    required this.orderDetails,
    required this.addressList,
    required this.osrmMapData,
    required this.legList,
    required this.locationList,
    required this.currentPosition,
    required this.totalProduct,
    required this.finished,
  });

  final bool isCompletePrep;
  final List<OrderHistoryDetail?> orderDetails;
  final List<String> addressList;
  final Map<String, dynamic> osrmMapData;
  final List<Leg> legList;
  final List<Location> locationList;
  final Position? currentPosition;
  final int totalProduct;
  final List<String> finished;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 20,
      ),
      child: SwipeButton.expand(
        enabled: isCompletePrep,
        thumb: const Icon(
          Icons.double_arrow_rounded,
          color: Colors.white,
        ),
        activeThumbColor: context.theme.primaryColor,
        activeTrackColor: Colors.grey.shade300,
        onSwipe: () async {
          Get.dialog(Center(
            child: LoadingWidget(
              size: 60,
            ),
          ));
          for (var e in orderDetails) {
            await appController.updateOrderStatus(
              orderId: e!.id!,
              status: "7",
              desc: "",
            );
          }

          Get.off(
            () => PrepDeliveryScreen(
              addressList: addressList,
              mapData: osrmMapData,
              legList: legList,
              locationList: locationList,
              orders: orderDetails,
              currentPosition: currentPosition!,
            ),
          );
        },
        child: Text(
          isCompletePrep
              ? "Chuẩn bị giao hàng"
              : "Còn ${totalProduct - finished.length} sản phẩm",
        ),
      ),
    );
  }
}
