import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/models/site.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';
import 'package:url_launcher/url_launcher.dart';

class PrepDeliveryScreen extends StatefulWidget {
  const PrepDeliveryScreen(
      {super.key,
      required this.orders,
      required this.distance,
      required this.addressList,
      required this.locationList,
      required this.currentPosition});

  final List<OrderHistoryDetail?> orders;
  final List<double> distance;
  final List<String> addressList;
  final List<Location> locationList;
  final Position currentPosition;

  @override
  State<PrepDeliveryScreen> createState() => _PrepDeliveryScreenState();
}

class _PrepDeliveryScreenState extends State<PrepDeliveryScreen> {
  late List<OrderHistoryDetail?> orders;
  late List<double> distance;
  late List<String> addressList;
  late List<Location> locationList;
  Polyline? routePolyline;
  final Set<Marker> _markers = {};
  bool isQueryRoute = false;
  bool isFinished = false;
  bool isQueryRouteBack = false;

  @override
  void initState() {
    super.initState();
    orders = widget.orders;
    distance = widget.distance;
    addressList = widget.addressList;
    locationList = widget.locationList;
  }

  routeBackToSite() async {
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
    Site site =
        appController.getSiteById(appController.pharmaTokenDecode()['SiteID']);

    final listLatLng = await locationFromAddress(site.fullyAddress!);

    _markers.add(Marker(
      markerId: MarkerId(site.siteName!),
      position: LatLng(
        listLatLng.first.latitude,
        listLatLng.first.longitude,
      ),
      infoWindow: InfoWindow(title: site.fullyAddress!),
    ));

    final route =
        await appController.openrouteservice.directionsMultiRouteCoordsPost(
      coordinates: [
        ORSCoordinate(
            latitude: widget.currentPosition.latitude,
            longitude: widget.currentPosition.longitude),
        ORSCoordinate(
            latitude: listLatLng.first.latitude,
            longitude: listLatLng.first.longitude),
      ],
      continueStraight: true,
      geometry: true,
      instructions: true,
      profileOverride: ORSProfile.cyclingRoad,
      units: 'm',
    );

    List<LatLng> routePoints = [];

    for (var e in route) {
      routePoints.add(LatLng(e.latitude, e.longitude));
    }

    setState(() {
      routePolyline = Polyline(
        polylineId: const PolylineId('route'),
        visible: true,
        points: routePoints,
        color: context.theme.primaryColor,
        width: 4,
      );
      isQueryRoute = false;
      isQueryRouteBack = true;
    });
  }

  getLocation() async {
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

    final route =
        await appController.openrouteservice.directionsMultiRouteCoordsPost(
      coordinates: [
        ORSCoordinate(
            latitude: widget.currentPosition.latitude,
            longitude: widget.currentPosition.longitude),
        ...locationList.map((e) => ORSCoordinate(
              latitude: e.latitude,
              longitude: e.longitude,
            )),
      ],
      continueStraight: true,
      geometry: true,
      instructions: true,
      profileOverride: ORSProfile.cyclingRoad,
      units: 'm',
    );

    List<LatLng> routePoints = [];

    for (var e in route) {
      routePoints.add(LatLng(e.latitude, e.longitude));
    }

    setState(() {
      routePolyline = Polyline(
        polylineId: const PolylineId('route'),
        visible: true,
        points: routePoints,
        color: context.theme.primaryColor,
        width: 4,
      );
      isQueryRoute = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kế hoạch giao hàng'),
        actions: const [],
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: Get.height * .2,
            top: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (routePolyline == null)
                  Icon(
                    Icons.location_on_rounded,
                    size: 150,
                    color: context.theme.primaryColor.withOpacity(.5),
                  ),
                if (routePolyline == null)
                  Text(
                    "Hãy nhấn nút tìm đường",
                    style: context.textTheme.headlineSmall,
                  ),
                if (isQueryRoute)
                  Center(
                    child: LoadingWidget(),
                  ),
                if (routePolyline != null && !isQueryRoute)
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
                      polylines: <Polyline>{routePolyline!},
                      onMapCreated: (GoogleMapController controller) {},
                    ),
                  ),
              ],
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            snap: true,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: context.theme.secondaryHeaderColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
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
                                if (isQueryRouteBack) {
                                  Get.offAllNamed('/home');
                                  appController.isProcessMode.value = false;

                                  appController.launchMaps(appController
                                      .getSiteById(appController
                                          .pharmaTokenDecode()['SiteID'])
                                      .fullyAddress!);
                                } else if (isFinished) {
                                  routeBackToSite();
                                }
                                getLocation();
                              },
                              child: AnimatedSwitcher(
                                duration: 300.milliseconds,
                                child: isQueryRoute
                                    ? LoadingWidget(
                                        color: Colors.white,
                                      )
                                    : isFinished
                                        ? isQueryRouteBack
                                            ? const Text("Dùng Google Map")
                                            : const Text("Về cửa hàng")
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

                                  final itemDistance =
                                      distance.removeAt(oldIndex);
                                  distance.insert(newIndex, itemDistance);

                                  final itemAddress =
                                      addressList.removeAt(oldIndex);
                                  addressList.insert(newIndex, itemAddress);

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
                                          border: Border.all(
                                              color:
                                                  context.theme.primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ExpansionTile(
                                          title: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Địa chỉ: ${addressList[i]}"),
                                              Text(
                                                "Khoảng cách: ${distance[i].round().toKilometers()}",
                                              ),
                                            ],
                                          ),
                                          children: [
                                            DetailContent(
                                              title: 'Mã Đơn hàng',
                                              content: Text(
                                                  orders[i]!.id.toString()),
                                              haveDivider: false,
                                            ),
                                            DetailContent(
                                              title: 'Tên khách hàng',
                                              content: Text(orders[i]!
                                                  .orderContactInfo!
                                                  .fullname!),
                                              haveDivider: false,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                await launchUrl(
                                                  Uri.parse(
                                                      'tel:${orders[i]!.orderContactInfo!.phoneNumber!}'),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: DetailContent(
                                                      title: 'Số điện thoại',
                                                      content: Text(orders[i]!
                                                          .orderContactInfo!
                                                          .phoneNumber!),
                                                      haveDivider: false,
                                                    ),
                                                  ),
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 20),
                                                    child: CircleAvatar(
                                                      child: Icon(Icons.call),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            DetailContent(
                                              title: 'Tổng tiền',
                                              content: Text(orders[i]!
                                                  .totalPrice!
                                                  .convertCurrentcy()),
                                              haveDivider: false,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Get.toNamed('/order_detail',
                                                        arguments:
                                                            orders[i]!.id);
                                                  },
                                                  child: const Text(
                                                      "Xem chi tiết"),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    appController.startDelivery(
                                                        orders[i]!);
                                                    appController.launchMaps(
                                                        orders[i]!
                                                            .orderDelivery!
                                                            .fullyAddress!);
                                                  },
                                                  child: const Text(
                                                      "Dùng Google Map"),
                                                ),
                                                FilledButton(
                                                  onPressed: () {
                                                    appController
                                                        .updateOrderStatus(
                                                      orderId: orders[i]!.id!,
                                                      status: "8",
                                                    );
                                                    appController
                                                        .orderProcessList
                                                        .removeWhere(
                                                            (element) =>
                                                                element ==
                                                                orders[i]!.id);
                                                    distance.removeAt(i);
                                                    addressList.removeAt(i);
                                                    locationList.removeAt(i);
                                                    orders.removeAt(i);
                                                    appController
                                                        .triggerOrderLoad();
                                                    setState(() {});
                                                    if (orders.isEmpty &&
                                                        appController
                                                            .orderProcessList
                                                            .isEmpty) {
                                                      isFinished = true;
                                                    }
                                                  },
                                                  child:
                                                      const Text("Hoàn thành"),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                ]),
                    ],
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
