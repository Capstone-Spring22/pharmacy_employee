import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy_employee/constant/controller.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  Position? currentPosition;
  Polyline? routePolyline;
  final Set<Marker> _markers = {};

  getLocation() async {
    var res = await Geolocator.getCurrentPosition();
    setState(() {
      currentPosition = res;
    });
    _markers.add(const Marker(
      markerId: MarkerId('Location 1'),
      position: LatLng(10.8294925, 106.7406685),
      infoWindow: InfoWindow(title: 'Location 1'),
    ));
    _markers.add(const Marker(
      markerId: MarkerId('Location 2'),
      position: LatLng(10.8160039, 106.6951782),
      infoWindow: InfoWindow(title: 'Location 2'),
    ));
    _markers.add(const Marker(
      markerId: MarkerId('Location 3'),
      position: LatLng(10.7950953, 106.6454822),
      infoWindow: InfoWindow(title: 'Location 3'),
    ));

    final route =
        await appController.openrouteservice.directionsMultiRouteCoordsPost(
      coordinates: [
        const ORSCoordinate(
          latitude: 10.8294925,
          longitude: 106.7406685,
        ),
        const ORSCoordinate(
          latitude: 10.8160039,
          longitude: 106.6951782,
        ),
        const ORSCoordinate(
          latitude: 10.7950953,
          longitude: 106.6454822,
        ),
      ],
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
        color: Colors.red,
        width: 4,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacist'),
        actions: [
          IconButton(
              onPressed: () => appController.logout(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => Column(
            children: [
              CupertinoListTile(
                title: Text("Font chữ",
                    style: TextStyle(fontSize: appController.fontSize.value)),
                trailing: Row(
                  children: [
                    IconButton(
                        onPressed: () => appController.decreaseFontSize(),
                        icon: const Icon(Icons.remove)),
                    Text(appController.fontSize.value.toString()),
                    IconButton(
                        onPressed: () => appController.increaseFontSize(),
                        icon: const Icon(Icons.add)),
                  ],
                ),
              ),
              CupertinoListTile(
                title: Text("Test",
                    style: TextStyle(fontSize: appController.fontSize.value)),
                onTap: () async {
                  if (await Permission.location.status.isGranted) {
                    // List<Location> placemarks =
                    //     await locationFromAddress('Chợ cây xoài Quận 2');

                    // Get.log(
                    //     "Cur: ${currentPosition.latitude} - ${currentPosition.longitude}");

                    // Get.log(
                    //     'User: ${placemarks[0].latitude} - ${placemarks[0].longitude}');

                    // double distance = Geolocator.distanceBetween(
                    //   currentPosition.latitude,
                    //   currentPosition.longitude,
                    //   placemarks[0].latitude,
                    //   placemarks[0].longitude,
                    // );

                    // Get.log(distance.toString());

                    // double startLat = currentPosition.latitude;
                    // double startLng = currentPosition.longitude;
                    // double endLat = placemarks[0].latitude;
                    // double endLng = placemarks[0].longitude;

                    // final List<ORSCoordinate> routeCoordinates =
                    //     await appController.openrouteservice
                    //         .directionsRouteCoordsGet(
                    //   startCoordinate: ORSCoordinate(
                    //       latitude: startLat, longitude: startLng),
                    //   endCoordinate:
                    //       ORSCoordinate(latitude: endLat, longitude: endLng),
                    // );

                    // // Print the route coordinates
                    // routeCoordinates.forEach(print);

                    // // Map route coordinates to a list of LatLng (requires google_maps_flutter package)
                    // // to be used in the Map route Polyline.
                    // final List<LatLng> routePoints = routeCoordinates
                    //     .map((coordinate) =>
                    //         LatLng(coordinate.latitude, coordinate.longitude))
                    //     .toList();

                    // // Create Polyline (requires Material UI for Color)
                    // final Polyline routePolyline = Polyline(
                    //   polylineId: const PolylineId('route'),
                    //   visible: true,
                    //   points: routePoints,
                    //   color: Colors.red,
                    //   width: 4,
                    // );
                  } else {
                    await Permission.location.request();
                  }

                  // String url =
                  //     "https://www.google.com/maps/dir/19 đường 6A Phước Bình/Rach Chiec Golf Driving Range, 150 XL Hà Nội, An Phú, Quận 2, Thành phố Hồ Chí Minh, Vietnam/FLORA ANH ĐÀO";
                  // await launchUrl(Uri.parse(url),
                  //     mode: LaunchMode.externalApplication);
                },
              ),
              if (currentPosition != null && routePolyline != null)
                SizedBox(
                  height: Get.width * .9,
                  width: Get.width * .9,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentPosition!.latitude,
                          currentPosition!.longitude),
                      zoom: 14.4746,
                    ),
                    markers: _markers,
                    polylines: <Polyline>{routePolyline!},
                    onMapCreated: (GoogleMapController controller) {},
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
