import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';
import 'package:pharmacy_employee/views/prep_delivery.dart/prep_delivery.dart';

class PrepOrder extends StatefulWidget {
  const PrepOrder({super.key});

  @override
  State<PrepOrder> createState() => _PrepOrderState();
}

class _PrepOrderState extends State<PrepOrder> {
  List<String> finished = [];
  Position? currentPosition;
  bool isLoading = false;
  bool isTextAnimateComplete = false;
  bool isCompletePrep = false;
  int totalProduct = 0;
  String loadingState = "";
  List<OrderHistoryDetail?> orderDetails = [];
  List<String> addressList = [];
  List<Location> locationList = [];
  List<double> distance = [];

  @override
  void initState() {
    super.initState();
    _loadOrderProcess();
  }

  _loadOrderProcess() async {
    try {
      setState(() {
        isLoading = true;
      });

      orderDetails = await Future.wait(
        appController.orderProcessList.map(
          (e) => AppService().fetchOrderDetail(e),
        ),
      );

      for (var i = 0; i < orderDetails.length; i++) {
        totalProduct += orderDetails[i]!.orderProducts!.length;
      }

      currentPosition = await Geolocator.getCurrentPosition();
      for (var i = 0; i < appController.orderProcessList.length; i++) {
        addressList.add(orderDetails[i]!.orderDelivery!.fullyAddress!);
      }

      List<List<Location>> locations =
          await Future.wait(addressList.map((e) => locationFromAddress(e)));

      for (var location in locations) {
        locationList.add(location[0]);
      }

      locationList.sort((a, b) => Geolocator.distanceBetween(
              currentPosition!.latitude,
              currentPosition!.longitude,
              a.latitude,
              a.longitude)
          .compareTo(Geolocator.distanceBetween(currentPosition!.latitude,
              currentPosition!.longitude, b.latitude, b.longitude)));

      distance = locationList
          .map((e) => Geolocator.distanceBetween(currentPosition!.latitude,
              currentPosition!.longitude, e.latitude, e.longitude))
          .toList();

      setState(() {
        isLoading = false;
      });
    } on Exception catch (e) {
      Get.log(e.toString());
    }
  }

  finishOrder(String index) {
    setState(() {
      finished.add(index);
      isCompletePrep = finished.length == totalProduct;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuẩn bị đơn hàng'),
        actions: const [],
      ),
      body: isLoading || isTextAnimateComplete == false
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingWidget(
                    size: 60,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  AnimatedTextKit(
                    isRepeatingAnimation: false,
                    onFinished: () {
                      setState(() {
                        isTextAnimateComplete = true;
                      });
                    },
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Đang tải đơn hàng',
                        textStyle: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TypewriterAnimatedText(
                        'Đang lấy địa chỉ',
                        textStyle: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TypewriterAnimatedText(
                        'Tính khoảng cách',
                        textStyle: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TypewriterAnimatedText(
                        'Sắp xếp theo khoảng cách',
                        textStyle: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: AutoSizeText(
                                appController.orderProcessList[index]),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              DetailContent(
                                title: "Tên khách hàng",
                                content: AutoSizeText(
                                  "${orderDetails[index]!.orderContactInfo!.fullname}",
                                ),
                                haveDivider: false,
                              ),
                              DetailContent(
                                title: "Số điện thoại",
                                content: AutoSizeText(
                                  "${orderDetails[index]!.orderContactInfo!.phoneNumber}",
                                ),
                                haveDivider: false,
                              ),
                              DetailContent(
                                title: "Địa chỉ",
                                content: AutoSizeText(
                                  "${orderDetails[index]!.orderDelivery!.fullyAddress}",
                                ),
                                haveDivider: false,
                              ),
                              DetailContent(
                                title: "Khoảng cách",
                                content: AutoSizeText(
                                  distance[index].round().toKilometers(),
                                ),
                                haveDivider: false,
                              ),
                              DetailContent(
                                title: "Tổng tiền",
                                content: AutoSizeText(
                                  orderDetails[index]!
                                      .totalPrice!
                                      .convertCurrentcy(),
                                ),
                              ),
                              DetailContent(
                                title: "Danh sách sản phẩm",
                                haveDivider: false,
                                content: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        trailing: Checkbox(
                                          value: finished.contains(
                                              orderDetails[index]!
                                                  .orderProducts![i]
                                                  .id),
                                          onChanged: (value) {
                                            if (value!) {
                                              setState(() {
                                                finishOrder(orderDetails[index]!
                                                    .orderProducts![i]
                                                    .id!);
                                              });
                                            } else {
                                              setState(() {
                                                finished.remove(
                                                    orderDetails[index]!
                                                        .orderProducts![i]
                                                        .id);
                                                isCompletePrep =
                                                    finished.length ==
                                                        totalProduct;
                                              });
                                            }
                                          },
                                        ),
                                        title: Text(orderDetails[index]!
                                            .orderProducts![i]
                                            .productName!),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${orderDetails[index]!.orderProducts![i].quantity} ${orderDetails[index]!.orderProducts![i].unitName} - ${orderDetails[index]!.orderProducts![i].priceTotal!.convertCurrentcy()}",
                                            ),
                                            AutoSizeText(
                                              orderDetails[index]!
                                                      .orderProducts![i]
                                                      .productNoteFromPharmacist ??
                                                  "",
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: orderDetails[index]!
                                      .orderProducts!
                                      .length,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: appController.orderProcessList.length,
                  ),
                  Padding(
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

                        Get.to(() => PrepDeliveryScreen(
                              addressList: addressList,
                              distance: distance,
                              locationList: locationList,
                              orders: orderDetails,
                              currentPosition: currentPosition!,
                            ));
                      },
                      child: Text(isCompletePrep
                          ? "Chuẩn bị giao hàng"
                          : "Còn ${totalProduct - finished.length} sản phẩm"),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
