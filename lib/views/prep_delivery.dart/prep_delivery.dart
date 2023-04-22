import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georouter/georouter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/constant/static.dart';
import 'package:pharmacy_employee/helpers/input.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/helpers/showSnack.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/map/leg.dart';
import 'package:pharmacy_employee/models/map/waypoint.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/prep_delivery.dart/widget/order_tile.dart';
import 'package:toggle_switch/toggle_switch.dart';

class PrepDeliveryScreen extends StatefulWidget {
  const PrepDeliveryScreen({
    super.key,
    required this.orders,
    required this.mapData,
    required this.addressList,
    required this.locationList,
    required this.currentPosition,
    required this.legList,
  });

  final List<OrderHistoryDetail?> orders;
  final Map<String, dynamic> mapData;
  final List<String> addressList;
  final List<Location> locationList;
  final Position currentPosition;
  final List<Leg> legList;

  @override
  State<PrepDeliveryScreen> createState() => _PrepDeliveryScreenState();
}

class _PrepDeliveryScreenState extends State<PrepDeliveryScreen> {
  late List<OrderHistoryDetail?> orders;
  late Map<String, dynamic> mapData;
  late List<String> addressList;
  late List<Location> locationList;
  late List<Leg> legList;
  final Set<Marker> _markers = {};
  bool isQueryRoute = false;
  bool isFinished = false;
  bool isQueryRouteBack = false;

  late GoogleMapController mapController;
  final Set<Polyline> _polylines = {};
  final List<String> routeSettingList = ['Nhanh nhất', 'Thứ tự sắp xếp'];
  int? selectedValue = 0;

  @override
  void initState() {
    super.initState();
    orders = widget.orders;
    mapData = widget.mapData;
    addressList = widget.addressList;
    locationList = widget.locationList;
    legList = widget.legList;
    getRouteFastest();
  }

  getRouteBySort() async {
    setState(() {
      isQueryRoute = true;
    });

    mapData =
        await AppService().getRouteBySort(widget.currentPosition, locationList);

    legList.clear();
    for (var itm in mapData['routes'][0]['legs']) {
      legList.add(Leg.fromJson(itm));
    }

    _polylines.clear();
    for (var e in legList) {
      List<PolylinePoint> poly = [];
      for (var ele in e.steps!) {
        poly.addAll(AppService.decodePolyline(ele.geometry!));
      }
      List<LatLng> routePoints = [];
      for (var p in poly) {
        routePoints.add(LatLng(p.latitude, p.longitude));
      }

      _polylines.add(Polyline(
        polylineId: PolylineId(e.summary!),
        visible: true,
        points: routePoints,
        color: getRandomBrightColor(),
        width: 4,
      ));
    }
    setState(() {
      selectedValue = 1;
      isQueryRoute = false;
    });
    showSnack(
      "Thông báo",
      "Đã tìm thấy tuyến đường nhanh nhất theo thứ tự sắp xếp",
      SnackType.success,
    );
  }

  getRouteFastest() async {
    setState(() {
      isQueryRoute = true;
    });
    _markers.clear();
    _markers.add(Marker(
      markerId: const MarkerId('Vị trí hiện tại'),
      position: LatLng(
        widget.currentPosition.latitude,
        widget.currentPosition.longitude,
      ),
      infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
    ));
    for (int i = 0; i < locationList.length; i++) {
      _markers.add(
        Marker(
          markerId: MarkerId(addressList[i]),
          position: LatLng(locationList[i].latitude, locationList[i].longitude),
          infoWindow: InfoWindow(
            title: addressList[i],
          ),
        ),
      );
    }

    //Get fastest route
    mapData = await AppService()
        .getOptimizeDistance(widget.currentPosition, locationList);

    List<Waypoint> wayPointList = [];
    for (final i in mapData['waypoints']) {
      wayPointList.add(Waypoint.fromJson(i));
    }

    orders = rearrangeList(orders, wayPointList);

    legList.clear();
    for (var itm in mapData['trips'][0]['legs']) {
      legList.add(Leg.fromJson(itm));
    }

    _polylines.clear();

    for (var e in legList) {
      List<PolylinePoint> poly = [];
      for (var ele in e.steps!) {
        poly.addAll(AppService.decodePolyline(ele.geometry!));
      }
      List<LatLng> routePoints = [];
      for (var p in poly) {
        routePoints.add(LatLng(p.latitude, p.longitude));
      }

      _polylines.add(Polyline(
        polylineId: PolylineId(e.summary!),
        visible: true,
        points: routePoints,
        color: getRandomBrightColor(),
        width: 4,
      ));
    }

    setState(() {
      selectedValue = 0;
      isQueryRoute = false;
    });

    showSnack(
      "Thông báo",
      "Đã tìm thấy tuyến đường nhanh nhất",
      SnackType.success,
    );
  }

  LatLngBounds getBounds() {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    for (Marker marker in _markers) {
      LatLng position = marker.position;
      minLat = min(minLat, position.latitude);
      maxLat = max(maxLat, position.latitude);
      minLng = min(minLng, position.longitude);
      maxLng = max(maxLng, position.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void setCameraToMarkers() {
    LatLngBounds bounds = getBounds();
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
  }

  void orderAction(int i, num totalPrice) {
    TextEditingController txt = TextEditingController();
    TextEditingController moneyTxt = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final formMoney = GlobalKey<FormState>();
    Rx<num> change = 0.0.obs;

    RxBool receiveMoney = false.obs;
    showModalBottomSheet(
      context: context,
      enableDrag: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                shrinkWrap: true,
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Tổng tiền: ',
                              style: context.textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Text(
                              totalPrice.convertCurrentcy(),
                              style: context.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'Tiền thối:',
                              style: context.textTheme.bodyLarge,
                            ),
                            const Spacer(),
                            Obx(
                              () => Text(
                                change.value.convertCurrentcy(),
                                style: context.textTheme.bodyLarge,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Form(
                    key: formMoney,
                    child: Input(
                      inputController: moneyTxt,
                      title: 'Nhận tiền',
                      inputType: TextInputType.number,
                      maxLines: 1,
                      txtHeight: 80,
                      isFormField: true,
                      validator: (p0) => p0!.isEmpty
                          ? 'Nhập tiền'
                          : p0.isNumericOnly
                              ? num.parse(p0) < totalPrice
                                  ? 'Tiền nhận phải cao hơn hoặc bằng tổng tiền'
                                  : null
                              : 'Nhập số',
                      onChanged: (v) {
                        if (formMoney.currentState!.validate()) {
                          change.value = num.parse(v) - totalPrice;
                          if (change.value >= 0) {
                            receiveMoney.value = true;
                          } else {}
                        } else {
                          receiveMoney.value = false;
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Obx(() => SwipeButton.expand(
                          enabled: receiveMoney.value,
                          thumb: const Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.white,
                          ),
                          activeThumbColor: context.theme.primaryColor,
                          activeTrackColor: Colors.grey[300],
                          onSwipe: () {
                            appController.updateOrderStatus(
                              orderId: orders[i]!.id!,
                              status: "8",
                            );
                            appController.orderProcessList.removeWhere(
                                (element) => element == orders[i]!.id);
                            addressList.removeAt(i);
                            locationList.removeAt(i);
                            orders.removeAt(i);
                            appController.triggerOrderLoad();
                            setState(() {
                              if (orders.isEmpty &&
                                  appController.orderProcessList.isEmpty) {
                                isFinished = true;
                              } else {
                                selectedValue == 0
                                    ? getRouteFastest()
                                    : getRouteBySort();
                              }
                            });
                            Get.back();
                          },
                          child: const Text("Hoàn thành đơn hàng"),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Form(
                      key: formKey,
                      child: Input(
                        expands: true,
                        maxLines: null,
                        txtHeight: Get.height * .15,
                        inputController: txt,
                        inputType: TextInputType.multiline,
                        title: "Lý do",
                        isFormField: true,
                        validator: (p0) => p0!.isEmpty
                            ? "Vui lòng nhập lý do"
                            : p0.length < 10
                                ? 'Tối thiểu 10 ký tự'
                                : p0.isNumericOnly
                                    ? 'Lý do không được chứa mỗi số'
                                    : null,
                        onChanged: (p0) {
                          formKey.currentState!.validate();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwipeButton.expand(
                      enabled: true,
                      thumb: const Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.white,
                      ),
                      activeThumbColor: Colors.deepOrange.shade500,
                      activeTrackColor: Colors.grey[300],
                      onSwipe: () {
                        if (txt.text.isEmpty) {
                          showSnack(
                            "Thông báo",
                            "Vui lòng nhập lý do hoãn đơn hàng",
                            SnackType.error,
                          );
                          return;
                        } else {
                          appController.updateOrderStatus(
                            orderId: orders[i]!.id!,
                            status: "7",
                            desc: txt.text,
                          );
                          appController.orderProcessList.removeWhere(
                            (element) => element == orders[i]!.id,
                          );
                          addressList.removeAt(i);
                          locationList.removeAt(i);
                          orders.removeAt(i);
                          appController.triggerOrderLoad();
                          setState(() {
                            if (orders.isEmpty &&
                                appController.orderProcessList.isEmpty) {
                              isFinished = true;
                            } else {
                              selectedValue == 0
                                  ? getRouteFastest()
                                  : getRouteBySort();
                            }
                          });

                          Get.back();
                        }
                      },
                      child: const Text("Hoãn đơn hàng"),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SwipeButton.expand(
                      enabled: true,
                      thumb: const Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.white,
                      ),
                      activeThumbColor: context.theme.colorScheme.error,
                      activeTrackColor: Colors.grey.shade300,
                      onSwipe: () async {
                        if (txt.text.isEmpty) {
                          showSnack(
                            "Thông báo",
                            "Vui lòng nhập lý do hủy đơn hàng",
                            SnackType.error,
                          );
                          return;
                        } else {
                          Get.dialog(LoadingWidget());
                          await AppService()
                              .cancelOrder(orders[i]!.id!, txt.text);
                          appController.orderProcessList.removeWhere(
                            (element) => element == orders[i]!.id,
                          );
                          addressList.removeAt(i);
                          locationList.removeAt(i);
                          orders.removeAt(i);
                          appController.triggerOrderLoad();
                          setState(() {
                            if (orders.isEmpty &&
                                appController.orderProcessList.isEmpty) {
                              isFinished = true;
                            } else {
                              selectedValue == 0
                                  ? getRouteFastest()
                                  : getRouteBySort();
                            }
                          });
                          Get.back();
                          Get.back();
                        }
                      },
                      child: const Text("Hủy đơn hàng"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      // isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.colorScheme.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Kế hoạch giao hàng'),
        actions: const [],
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: Get.height * .26,
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        widget.currentPosition.latitude,
                        widget.currentPosition.longitude,
                      ),
                      zoom: 14.4746,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (GoogleMapController controller) async {
                      mapController = controller;
                      await Future.delayed(1.seconds);
                      setCameraToMarkers();
                    },
                  ),
                ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            snap: true,
            minChildSize: 0.3,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      AutoSizeText(
                        'Tìm tuyến đường theo:',
                        style: context.textTheme.titleLarge,
                      ),
                      ToggleSwitch(
                        initialLabelIndex: selectedValue,
                        totalSwitches: 2,
                        labels: routeSettingList,
                        onToggle: (index) {
                          selectedValue = index;
                        },
                        cornerRadius: 20.0,
                        inactiveBgColor: context.theme.secondaryHeaderColor,
                        minWidth: Get.width * .4,
                        minHeight: Get.height * .05,
                        activeBgColor: [context.theme.primaryColor],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: AnimatedContainer(
                          decoration: BoxDecoration(
                            color: context.theme.primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          duration: 250.milliseconds,
                          width: isQueryRoute ? Get.width * .2 : Get.width * .9,
                          child: SizedBox(
                            child: FilledButton(
                              onPressed: () {
                                if (isFinished) {
                                  Get.offAllNamed('/home');
                                  appController.isProcessMode.value = false;

                                  // appController.launchMaps(appController
                                  //     .getSiteById(appController
                                  //         .pharmaTokenDecode()['SiteID'])
                                  //     .fullyAddress!);
                                } else {
                                  selectedValue == 0
                                      ? getRouteFastest()
                                      : getRouteBySort();
                                }
                              },
                              child: AnimatedSwitcher(
                                duration: 300.milliseconds,
                                child: isQueryRoute
                                    ? LoadingWidget(
                                        color: Colors.white,
                                      )
                                    : isFinished
                                        ? const Text("Hoàn thành")
                                        : const Text("Tìm đường"),
                              ),
                            ),
                          ),
                        ),
                      ),
                      isFinished
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: Get.height * .05),
                              child: const Text("Đã hoàn thành các đơn hàng"),
                            )
                          : ReorderableListView(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              onReorder: (oldIndex, newIndex) {
                                setState(() {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  final itemOrder = orders.removeAt(oldIndex);
                                  orders.insert(newIndex, itemOrder);

                                  final itemAddress =
                                      addressList.removeAt(oldIndex);
                                  addressList.insert(newIndex, itemAddress);

                                  final itemLeg = legList.removeAt(oldIndex);
                                  legList.insert(newIndex, itemLeg);

                                  final itemLocation =
                                      locationList.removeAt(oldIndex);
                                  locationList.insert(newIndex, itemLocation);
                                });
                              },
                              children: [
                                  for (var i = 0; i < orders.length; i++)
                                    Padding(
                                      key: UniqueKey(),
                                      padding: const EdgeInsets.all(15),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 7,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: OrderTileDelivery(
                                          address: addressList[i],
                                          distance: legList
                                                      .map((e) => e.distance)
                                                      .take(i)
                                                      .toList()
                                                      .length >
                                                  1
                                              ? legList
                                                  .map((e) => e.distance)
                                                  .take(i)
                                                  .reduce((value, element) =>
                                                      value! + element!)!
                                                  .toKilometers()
                                              : legList[i]
                                                  .distance!
                                                  .toKilometers(),
                                          i: i,
                                          orders: orders,
                                          orderAction: orderAction,
                                          orderId: orders[i]!.id!,
                                          phone: orders[i]!
                                              .orderContactInfo!
                                              .phoneNumber!,
                                          total: orders[i]!
                                              .totalPrice!
                                              .convertCurrentcy(),
                                        ),
                                      ),
                                    )
                                ]),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
