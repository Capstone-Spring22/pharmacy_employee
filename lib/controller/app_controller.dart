// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pharmacy_employee/models/order.dart';
import 'package:pharmacy_employee/models/product.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pharmacy_employee/models/pharmacist.dart';

class AppController extends GetxController {
  static AppController instance = Get.find();

  static closeOverlay() async {
    await SystemAlertWindow.closeSystemWindow(
      prefMode: SystemWindowPrefMode.OVERLAY,
    );
  }

  callBtnOverlay(String phone) async {
    if (!await launchUrl(Uri.parse("tel:$phone"))) {
      throw Exception('Could not call $phone');
    }
  }

  RxString p = "".obs;

  Dio dio = Dio();

  RxBool isLogin = false.obs;

  Options? options;

  TextEditingController searchController = TextEditingController();

  Rx<Pharmacist> pharmacist = Pharmacist().obs;

  RxList<PharmacyProduct> productList = <PharmacyProduct>[].obs;
  RxList<OrderHistory> orderList = <OrderHistory>[].obs;

  RxBool isLoading = false.obs;
  RxBool productHaveNext = false.obs;
  RxBool orderHaveNext = false.obs;

  RxDouble fontSize = 18.0.obs;

  @override
  void onInit() {
    final box = GetStorage();
    final user = box.read('user');

    fontSize.value = box.read('fontSize') ?? 18;

    ever(pharmacist, pharmacistState);
    if (user != null) {
      pharmacist.value = Pharmacist.fromJson(user);
    }
    super.onInit();
  }

  void pharmacistState(Pharmacist pm) {
    if (pm.id == null) {
      removeUserSetting();
    } else {
      setupUser();
    }
  }

  void decreaseFontSize() {
    if (fontSize.value > 12) {
      fontSize.value--;
      final box = GetStorage();
      box.write('fontSize', fontSize.value);
    }
  }

  void increaseFontSize() {
    if (fontSize.value < 30) {
      fontSize.value++;
      final box = GetStorage();
      box.write('fontSize', fontSize.value);
    }
  }

  setupUser() {
    isLogin.value = true;
    options = Options(headers: {
      'Authorization': 'Bearer ${pharmacist.value.token}',
    });
    final box = GetStorage();
    box.write('user', pharmacist.value.toJson());
  }

  removeUserSetting() {
    isLogin.value = false;
    options = null;
    final box = GetStorage();
    box.remove('user');
  }

  void logout() {
    pharmacist.value = Pharmacist();
    Get.offAllNamed('/login');
  }

  Future initLookup(String name, int page) async {
    isLoading.value = true;
    final result = await AppService().lookupProduct(name, page);
    productList.clear();
    for (final item in result['items']) {
      productList.add(PharmacyProduct.fromJson(item));
    }
    Map<String, dynamic> map = {
      "totalRecord": result['totalRecord'],
      "totalPage": result['totalPage'],
      "hasNextPage": result['hasNextPage'],
      "hasPreviousPage": result['hasPreviousPage']
    };
    productHaveNext.value = result['hasNextPage'];

    isLoading.value = false;
    return map;
  }

  void toProductDetail(String id) {
    Get.toNamed('/product_detail', arguments: id);
  }

  Future initOrder(int page, bool isAccept, {bool isNew = false}) async {
    isLoading.value = true;
    final result = await AppService().fetchOrder(page, isAccept);
    if (isNew) {
      orderList.clear();
    }
    for (final item in result['items']) {
      orderList.add(OrderHistory.fromJson(item));
    }

    Map<String, dynamic> map = {
      "totalRecord": result['totalRecord'],
      "totalPage": result['totalPage'],
      "hasNextPage": result['hasNextPage'],
      "hasPreviousPage": result['hasPreviousPage']
    };
    orderHaveNext.value = result['hasNextPage'];

    isLoading.value = false;
    return map;
  }
}
