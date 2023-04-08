// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:open_route_service/open_route_service.dart';
import 'package:pharmacy_employee/models/order.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/models/product.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/overlay/btn_tag.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:pharmacy_employee/models/pharmacist.dart';

class AppController extends GetxController {
  static AppController instance = Get.find();

  static closeOverlay() async {
    await SystemAlertWindow.closeSystemWindow(
      prefMode: SystemWindowPrefMode.OVERLAY,
    ).then((value) async {
      // await Future.delayed(const Duration(milliseconds: 500));
      // SystemNavigator.pop();
      // const url = 'betterhealth_employee.capstone://home';
      // await launchUrl(Uri.parse(url));
    });
  }

  callBtnOverlay(String phone) async {
    if (!await launchUrl(Uri.parse("tel:$phone"))) {
      throw Exception('Could not call $phone');
    }
  }

  late OpenRouteService openrouteservice;

  RxString p = "".obs;

  Dio dio = Dio();

  RxBool isLogin = false.obs;

  Options? options;

  TextEditingController searchController = TextEditingController();

  Rx<Pharmacist> pharmacist = Pharmacist().obs;

  RxList<PharmacyProduct> productList = <PharmacyProduct>[].obs;
  RxList<OrderHistory> orderUnAcceptList = <OrderHistory>[].obs;
  RxList<OrderHistory> orderActiveList = <OrderHistory>[].obs;
  RxList<OrderHistory> orderCantAcceptList = <OrderHistory>[].obs;

  RxBool isProcessMode = false.obs;
  RxList<String> orderProcessList = <String>[].obs;

  RxBool isLoading = false.obs;
  RxBool isActiveLoading = false.obs;
  RxBool isUnAcceptLoading = false.obs;
  RxBool isCantAcceptLoading = false.obs;

  RxBool productHaveNext = false.obs;
  RxBool orderUnAcceptHaveNext = false.obs;
  RxBool orderActiveHaveNext = false.obs;
  RxBool orderCantAcceptHaveNext = false.obs;

  Rx<TabController?> orderTabController = null.obs;

  RxDouble fontSize = 18.0.obs;

  @override
  void onInit() {
    final box = GetStorage();
    openrouteservice = OpenRouteService(
        apiKey: '5b3ce3597851110001cf6248e2b15d5d8ed740e7a67b546cb69bc43d');
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

  Future initOrder(
    int page,
    bool isAccept,
    String type, {
    bool isNew = false,
    bool isOnlyPharmacist = false,
  }) async {
    switch (type) {
      case "unAccept":
        isUnAcceptLoading.value = true;
        break;
      case "active":
        isActiveLoading.value = true;
        break;
      case "cantAccept":
        isCantAcceptLoading.value = true;
        break;
      default:
    }

    final result =
        await AppService().fetchOrder(page, isAccept, isOnlyPharmacist);

    Map<String, dynamic> map = {
      "totalRecord": result['totalRecord'],
      "totalPage": result['totalPage'],
      "hasNextPage": result['hasNextPage'],
      "hasPreviousPage": result['hasPreviousPage']
    };

    switch (type) {
      case "unAccept":
        if (isNew) {
          orderUnAcceptList.clear();
        }
        for (final item in result['items']) {
          orderUnAcceptList.add(OrderHistory.fromJson(item));
        }
        orderUnAcceptHaveNext.value = result['hasNextPage'];
        break;
      case "active":
        if (isNew) {
          orderActiveList.clear();
        }
        for (final item in result['items']) {
          orderActiveList.add(OrderHistory.fromJson(item));
        }
        orderActiveHaveNext.value = result['hasNextPage'];
        break;
      case "cantAccept":
        if (isNew) {
          orderCantAcceptList.clear();
        }
        for (final item in result['items']) {
          orderCantAcceptList.add(OrderHistory.fromJson(item));
        }
        orderCantAcceptHaveNext.value = result['hasNextPage'];
        break;
      default:
    }

    switch (type) {
      case "unAccept":
        isUnAcceptLoading.value = false;
        break;
      case "active":
        isActiveLoading.value = false;
        break;
      case "cantAccept":
        isCantAcceptLoading.value = false;
        break;
      default:
    }
    return map;
  }

  void launchMaps(String address) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$address';
    if (!await launchUrl(Uri.parse(googleUrl),
        mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $googleUrl');
    }
  }

  void startDelivery(OrderHistoryDetail order) {
    SystemWindowHeader header = SystemWindowHeader(
      title: SystemWindowText(
        text: "${order.orderContactInfo!.fullname}",
        fontSize: 20,
        textColor: Colors.black87,
      ),
      padding: SystemWindowPadding.setSymmetricPadding(12, 12),
      subTitle: SystemWindowText(
        text: "${order.orderDelivery!.homeNumber}",
        fontSize: 20,
        fontWeight: FontWeight.BOLD,
        textColor: Colors.black87,
      ),
      decoration: SystemWindowDecoration(startColor: Colors.grey[100]),
      // button: SystemWindowButton(
      //   text: SystemWindowText(
      //     text: "Gọi",
      //     fontSize: 10,
      //     textColor: Get.context!.theme.primaryColor,
      //   ),
      //   tag: "$callBtnTag-${order.orderContactInfo!.phoneNumber}",
      // ),
      // buttonPosition: ButtonPosition.TRAILING,
    );

    SystemWindowBody body = SystemWindowBody(
      rows: [
        EachRow(
          columns: [
            EachColumn(
              text: SystemWindowText(
                  text: "An Toàn, Thượng Lộ Bình An",
                  fontSize: 12,
                  textColor: Colors.black45),
            ),
          ],
          gravity: ContentGravity.CENTER,
        ),
      ],
      padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
    );

    SystemWindowFooter footer = SystemWindowFooter(
      buttons: [
        SystemWindowButton(
          text: SystemWindowText(
            text: "Tắt Overlay",
            fontSize: 12,
            textColor: Get.context!.theme.primaryColor,
          ),
          tag: "$closeBtnTag-0",
          padding: SystemWindowPadding(
            left: 10,
            right: 10,
            bottom: 10,
            top: 10,
          ),
          width: 0,
          height: SystemWindowButton.WRAP_CONTENT,
          decoration: SystemWindowDecoration(
            startColor: Colors.white,
            endColor: Colors.white,
            borderWidth: 0,
            borderRadius: 0.0,
          ),
        ),
        SystemWindowButton(
          text: SystemWindowText(
            text: "Gọi Khách",
            fontSize: 12,
            textColor: Colors.white,
          ),
          tag: "$callBtnTag-${p.value}",
          width: 0,
          padding: SystemWindowPadding(
            left: 10,
            right: 10,
            bottom: 10,
            top: 10,
          ),
          height: SystemWindowButton.WRAP_CONTENT,
          decoration: SystemWindowDecoration(
            startColor: Get.context!.theme.primaryColor,
            endColor: Get.context!.theme.secondaryHeaderColor,
            borderWidth: 0,
            borderRadius: 30.0,
          ),
        )
      ],
      padding: SystemWindowPadding(
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: SystemWindowDecoration(startColor: Colors.white),
      buttonsPosition: ButtonPosition.CENTER,
    );
    SystemAlertWindow.showSystemWindow(
      height: (Get.height * .2).toInt(),
      header: header,
      footer: footer,
      margin: SystemWindowMargin(
        left: 8,
        right: 8,
        top: 100,
        bottom: 0,
      ),
      gravity: SystemWindowGravity.TOP,
      notificationTitle: "Thực Hiện Đơn Giao Hàng",
      notificationBody:
          "Khách hàng: ${order.orderContactInfo!.fullname} - ${order.orderContactInfo!.phoneNumber}",
      prefMode: SystemWindowPrefMode.OVERLAY,
    );
  }

  Future validateOrder({
    required bool isAccept,
    required String orderId,
    String desc = "",
  }) async {
    try {
      var res = await AppService().acceptOrder(orderId, isAccept, desc: desc);
      Get.log(res.toString());
    } catch (e) {
      Get.log("Validate order error: $e");
    }
  }
}
