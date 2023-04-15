import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:georouter/georouter.dart';
import 'package:get/get.dart' hide Response;
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/models/pharmacist.dart';
import 'package:pharmacy_employee/models/site.dart';

class AppService {
  final dio = appController.dio;
  final api = dotenv.env['API_URL']!;

  Future loginUser(String id, String pass) async {
    try {
      var res = await dio.post(
        '${api}Member/InternalUser/Login',
        data: {
          'username': id,
          'password': pass,
        },
      );

      if (res.statusCode == 200) {
        appController.pharmacist.value = Pharmacist.fromJson(res.data);
        return null;
      } else {
        return "Wrong username or password";
      }
    } on DioError catch (e) {
      final error = e.response!.data;
      if (error['userNotFound'] != null) {
        return error['userNotFound'];
      } else if (error['wrongPassword'] != null) {
        return error['wrongPassword'];
      } else if (error['userInactive'] != null) {
        return error['userInactive'];
      } else if (error['noWorkingSite'] != null) {
        return error['noWorkingSite'];
      } else if (error['otherError'] != null) {
        return error['otherError'];
      } else {
        return 'Something went wrong';
      }
    }
  }

  Future fetchOrder(int page, bool isAccept, bool isOnlyPharmacist,
      {int count = 10}) async {
    try {
      var res = await dio.get(
        '$api/Order',
        queryParameters: {
          'NotAcceptable': isAccept,
          'pageIndex': page,
          'pageItems': count,
          'ShowOnlyPharmacist': isOnlyPharmacist,
        },
        options: appController.options,
      );

      if (res.statusCode == 200) {
        return res.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      Get.log(e.message.toString());

      if (e.response != null) {
        Get.log(e.response!.data.toString());
      }
    }
  }

  Future<List<Site>> fetchAllSite() async {
    var res = await dio
        .get('$api/Site', options: appController.options, queryParameters: {
      'pageIndex': 1,
      'pageItems': 10,
    });

    if (res.statusCode == 200) {
      return List<Site>.from(res.data['items'].map((e) => Site.fromJson(e)));
    } else {
      return [];
    }
  }

  Future lookupProduct(String name, int page) async {
    try {
      var res = await dio.get('$api/Product', queryParameters: {
        'productName': name,
        'pageIndex': page,
        'pageItems': 10,
      });

      if (res.statusCode == 200) {
        return res.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      Get.log(e.response.toString());
    }
  }

  Future fetchProductDetail(String id) async {
    try {
      var res = await dio.get('$api/Product/View/$id',
          options: appController.options);

      if (res.statusCode == 200) {
        return res.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      Get.log(e.response.toString());
    }
  }

  Future<OrderHistoryDetail?> fetchOrderDetail(String id) async {
    try {
      var res = await dio.get('$api/Order/$id', options: appController.options);
      return OrderHistoryDetail.fromJson(res.data);
    } on DioError catch (e) {
      Get.log(e.response.toString());
    }
    return null;
  }

  Future fetchOrderStatus(num id) async {
    try {
      var res = await dio.get('$api/OrderStatus',
          queryParameters: {
            'OrderTypeId': id,
          },
          options: appController.options);

      if (res.statusCode == 200) {
        return res.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      Get.log(e.response.toString());
    }
  }

  Future putOrderNote(String id, String note) async {
    try {
      var res = await dio.put(
        '${api}Order/UpdateOrderProductNote',
        data: [
          {"orderDetailId": id, "note": note}
        ],
        options: appController.options,
      );
      return res.statusCode;
    } on DioError catch (e) {
      Get.log(e.response!.statusMessage.toString());
    }
  }

  Future fetchIpAddress() async {
    try {
      var res = await dio.get('https://api.ipify.org/?format=json');
      return res.data['ip'];
    } on DioError catch (e) {
      Get.log(e.response.toString());
    }
  }

  Future acceptOrder(String orderId, bool isAccept, {String desc = ""}) async {
    try {
      var ip = await fetchIpAddress();
      var res = await dio.put('${api}Order/ValidateOrder',
          options: appController.options,
          data: {
            "orderId": orderId,
            "isAccept": isAccept,
            "description": desc,
            "ipAddress": ip
          });
      return res.statusCode;
    } on DioError catch (e) {
      Get.log("Response: ${e.response!.data.toString()}");
    }
  }

  Future updateOrderStatus(String id, String statusId, String desc) async {
    try {
      var res = await dio.put(
        '${api}Order/ExecuteOrder',
        options: appController.options,
        data: {
          "orderId": id,
          "orderStatusId": statusId,
          "description": desc,
        },
      );
      return res.statusCode;
    } on DioError catch (e) {
      Get.log(e.response!.statusMessage.toString());
    }
  }

  Future fetchSiteInfo(String id) async {
    try {
      var res = await dio.get(
        '${api}Site/$id',
        options: appController.options,
      );
      return res.data;
    } on DioError catch (e) {
      Get.log(e.response.toString());
    }
  }

  // Future<Map<String, dynamic>> getDistance(
  //     Position currentPosition, List<Location> listDestinationLocation) async {
  //   const apiKey =
  //       '5b3ce3597851110001cf6248e2b15d5d8ed740e7a67b546cb69bc43d'; // Replace with your actual API key
  //   const apiUrl = 'https://api.openrouteservice.org/v2/directions/driving-car';

  //   final data = {
  //     'coordinates': [
  //       [currentPosition.longitude, currentPosition.latitude],
  //       ...listDestinationLocation.map((e) => [e.longitude, e.latitude]),
  //       [106.7585922, 10.8106114]
  //     ],
  //   };

  //   try {
  //     final res = await dio.post(
  //       apiUrl,
  //       options: Options(headers: {
  //         'Authorization': apiKey,
  //       }),
  //       data: data,
  //     );

  //     if (res.statusCode == 200) {
  //       final data = res.data;
  //       return data;
  //     } else {
  //       throw Exception('Failed to get distance');
  //     }
  //   } on DioError catch (e) {
  //     Get.log(e.response.toString());
  //   }
  //   return {};
  // }

  Future<List<PolylinePoint>?> getOptimizeRoute(
      Position currentPosition, List<Location> listDestinationLocation) async {
    List<String> latLngList = [
      "${currentPosition.latitude},${currentPosition.longitude}",
      ...listDestinationLocation
          .map((waypoint) => "${waypoint.latitude},${waypoint.longitude}")
    ];

    final georouter = GeoRouter(mode: TravelMode.driving);

    final coordinates = [
      PolylinePoint(
          latitude: currentPosition.latitude,
          longitude: currentPosition.longitude),
      ...listDestinationLocation.map(
          (e) => PolylinePoint(latitude: e.latitude, longitude: e.longitude)),
    ];
    try {
      final directions =
          await georouter.getDirectionsBetweenPoints(coordinates);
      Get.log(directions.toString());
      return directions;
    } on GeoRouterException {
// Handle GeoRouterException
    } on HttpException {
// Handle HttpException
    }
    return null;
  }

  static List<PolylinePoint> decodePolyline(String encoded) {
    final List<PolylinePoint> points = <PolylinePoint>[];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final PolylinePoint point =
          PolylinePoint(latitude: lat / 1E5, longitude: lng / 1E5);
      points.add(point);
    }

    return points;
  }

  Future<Map<String, dynamic>> getOptimizeDistance(
      Position currentPosition, List<Location> listDestinationLocation,
      {bool roundTrip = false}) async {
    final List listCoor = [
      "${currentPosition.longitude},${currentPosition.latitude}",
      ...listDestinationLocation
          .map((e) => "${e.longitude},${e.latitude}")
          .toList()
    ];
    String joinedCoor = listCoor.join(';');
    Get.log(joinedCoor);
    Response res;
    try {
      res = await dio.get(
          'http://router.project-osrm.org/trip/v1/driving/$joinedCoor',
          queryParameters: {
            'steps': true,
            'source': 'first',
            'roundtrip': roundTrip,
          });

      return res.data;
    } catch (e) {
      Get.log(e.toString());
    }
    return {};
  }
}
