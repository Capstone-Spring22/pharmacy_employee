import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/models/pharmacist.dart';

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

  Future fetchOrder(int page, bool isAccept, {int count = 10}) async {
    try {
      var res = await dio.get(
        '$api/Order',
        queryParameters: {
          'NotAcceptable': isAccept,
          'pageIndex': page,
          'pageItems': count,
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

  Future fetchOrderDetail(String id) async {
    try {
      var res = await dio.get('$api/Order/$id', options: appController.options);

      if (res.statusCode == 200) {
        return res.data;
      } else {
        return null;
      }
    } on DioError catch (e) {
      Get.log(e.response.toString());
    }
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
}
