import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/constant/static.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/map/leg.dart';
import 'package:pharmacy_employee/models/map/waypoint.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';
import 'package:pharmacy_employee/views/prep_order.dart/widget/toDeliveryBtn.dart';
import 'package:pharmacy_employee/views/prep_order.dart/widget/unitcheck.dart';

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
  List<Leg> legList = [];
  Map<String, dynamic> osrmMapData = {};

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
      List orderProcessList = appController.orderProcessList;

      orderDetails = await Future.wait(
        orderProcessList.map(
          (e) => AppService().fetchOrderDetail(e),
        ),
      );

      List<OrderHistoryDetail?> tempOrderDetails = await Future.wait(
        orderProcessList.map(
          (e) => AppService().fetchOrderDetail(e),
        ),
      );

      for (var i = 0; i < tempOrderDetails.length; i++) {
        totalProduct += tempOrderDetails[i]!.orderProducts!.length;
      }

      //Get current location latlng
      currentPosition = await AppController.getCurrentLocation();
      for (var i = 0; i < appController.orderProcessList.length; i++) {
        addressList.add(tempOrderDetails[i]!.orderDelivery!.fullyAddress!);
      }

      //Get LatLng from address
      List<List<Location>> locations = await Future.wait(
        addressList.map((e) => locationFromAddress(e)),
      );

      //Create list of location
      for (var location in locations) {
        locationList.add(location[0]);
      }

      //Get fastest route
      osrmMapData = await AppService()
          .getOptimizeDistance(currentPosition!, locationList);

      List<Waypoint> wayPointList = [];
      for (final i in osrmMapData['waypoints']) {
        wayPointList.add(Waypoint.fromJson(i));
      }

      orderDetails = rearrangeList(tempOrderDetails, wayPointList);
      legList.clear();
      for (var itm in osrmMapData['trips'][0]['legs']) {
        legList.add(Leg.fromJson(itm));
      }
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
      body: isLoading
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
                  // AnimatedTextKit(
                  //   isRepeatingAnimation: false,
                  //   onFinished: () {
                  //     setState(() {
                  //       isTextAnimateComplete = true;
                  //     });
                  //   },
                  //   animatedTexts: [
                  //     TypewriterAnimatedText(
                  //       'Đang tải đơn hàng',
                  //       textStyle: const TextStyle(
                  //         fontSize: 25,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     TypewriterAnimatedText(
                  //       'Đang lấy địa chỉ',
                  //       textStyle: const TextStyle(
                  //         fontSize: 25,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     TypewriterAnimatedText(
                  //       'Tính khoảng cách',
                  //       textStyle: const TextStyle(
                  //         fontSize: 25,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     TypewriterAnimatedText(
                  //       'Sắp xếp theo khoảng cách',
                  //       textStyle: const TextStyle(
                  //         fontSize: 25,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // )
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: appController.orderProcessList.length,
                    itemBuilder: (context, index) {
                      final contactInfo =
                          orderDetails[index]!.orderContactInfo!;
                      final products = orderDetails[index]!.orderProducts!;
                      final grouped = orderDetails[index]!
                          .orderProducts!
                          .groupProductByName();
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
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
                              appController.orderProcessList[index],
                              maxLines: 1,
                            ),
                            expandedCrossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              DetailContent(
                                title: "Tên khách hàng",
                                content: AutoSizeText(
                                  "${contactInfo.fullname}",
                                ),
                                haveDivider: false,
                              ),
                              DetailContent(
                                title: "Số điện thoại",
                                content: AutoSizeText(
                                  "${contactInfo.phoneNumber}",
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
                                  legList[index].distance!.toKilometers(),
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
                              productList(grouped, products),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  DeliveryButton(
                    isCompletePrep: isCompletePrep,
                    orderDetails: orderDetails,
                    addressList: addressList,
                    osrmMapData: osrmMapData,
                    legList: legList,
                    locationList: locationList,
                    currentPosition: currentPosition,
                    totalProduct: totalProduct,
                    finished: finished,
                  ),
                ],
              ),
            ),
    );
  }

  DetailContent productList(
    List<List<OrderProducts>> grouped,
    List<OrderProducts> products,
  ) {
    return DetailContent(
      title: "Danh sách sản phẩm",
      haveDivider: false,
      content: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: grouped.length,
        itemBuilder: (context, i) {
          final item = grouped[i];
          return Padding(
            padding: const EdgeInsets.all(8.0),
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
                  ]),
              child: ListTile(
                title: Text(
                  products[i].productName!,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...item.map(
                      (e) => UnitCheck(
                        product: e,
                        onCheck: (v) {
                          setState(() {
                            if (v) {
                              finishOrder(e.id!);
                            } else {
                              finished.remove(
                                e.id,
                              );
                              isCompletePrep = finished.length == totalProduct;
                            }
                          });
                        },
                        value: finished.contains(
                          e.id,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().slideX(delay: (i * 80).ms).fade();
        },
      ),
    );
  }
}
