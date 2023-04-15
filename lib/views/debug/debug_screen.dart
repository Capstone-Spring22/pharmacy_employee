import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georouter/georouter.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pharmacy_employee/constant/static.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/map/leg.dart';
import 'package:pharmacy_employee/models/map/waypoint.dart';

import '../../constant/controller.dart';
import '../../models/order_detail.dart';
import '../../service/app_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
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
  late List<OrderHistoryDetail?> orders;
  List<Leg> legList = [];

  final Set<Polyline> _polylines = {};

  late GoogleMapController mapController;

  Polyline? routePolyline;
  final Set<Marker> _markers = {};
  bool isQueryRoute = false;
  bool isFinished = false;
  bool isQueryRouteBack = false;

  @override
  void initState() {
    super.initState();
    _loadOrderProcess();
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

  _loadOrderProcess() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<OrderHistoryDetail?> tempOrderDetails = await Future.wait(
        appController.orderProcessList.map(
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

      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('Vị trí hiện tại'),
        position: LatLng(
          currentPosition!.latitude,
          currentPosition!.longitude,
        ),
        infoWindow: const InfoWindow(title: 'Vị trí hiện tại'),
      ));
      for (int i = 0; i < locationList.length; i++) {
        _markers.add(
          Marker(
            markerId: MarkerId(addressList[i]),
            position:
                LatLng(locationList[i].latitude, locationList[i].longitude),
            infoWindow: InfoWindow(
              title: addressList[i],
            ),
          ),
        );
      }

      //Get fastest route
      var data = await AppService()
          .getOptimizeDistance(currentPosition!, locationList);

      List<Waypoint> wayPointList = [];
      for (final i in data['waypoints']) {
        wayPointList.add(Waypoint.fromJson(i));
      }

      orderDetails = rearrangeList(tempOrderDetails, wayPointList);

      legList.clear();
      for (var itm in data['trips'][0]['legs']) {
        legList.add(Leg.fromJson(itm));
      }

      for (var e in legList) {
        Get.log(e.steps!.length.toString());

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
        isQueryRoute = false;
        isLoading = false;
      });
    } on Exception catch (e) {
      Get.log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                SizedBox(
                  height: Get.height * .5,
                  width: Get.width,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        currentPosition!.latitude,
                        currentPosition!.longitude,
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
                Expanded(
                    child: ListView.builder(
                  itemCount: orderDetails.length,
                  itemBuilder: (context, index) {
                    final item = orderDetails[index];
                    return ListTile(
                      title: Text(item!.orderDelivery!.fullyAddress!),
                      subtitle: Text(
                        "Khoảng cách: ${legList[index].distance!.toInt().toKilometers()}",
                      ),
                    );
                  },
                )),
              ],
            ),
    );
  }
}
