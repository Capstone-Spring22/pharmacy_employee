import 'dart:isolate';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';
import 'package:pharmacy_employee/isolate_manager.dart';
import 'package:pharmacy_employee/views/confirm_order.dart/confirm_order.dart';
import 'package:pharmacy_employee/views/debug/debug_screen.dart';
import 'package:pharmacy_employee/views/home/home.dart';
import 'package:pharmacy_employee/views/login/login.dart';
import 'package:pharmacy_employee/views/lookup/lookup.dart';
import 'package:pharmacy_employee/views/map/map.dart';
import 'package:pharmacy_employee/views/order/order.dart';
import 'package:pharmacy_employee/views/order_detail/order_detail.dart';
import 'package:pharmacy_employee/views/overlay/btn_tag.dart';
import 'package:pharmacy_employee/views/overlay/overlay.dart';
import 'package:pharmacy_employee/views/prep_order.dart/prep_order.dart';
import 'package:pharmacy_employee/views/prep_pickup/prep_pickup.dart';
import 'package:pharmacy_employee/views/product_detail/product_detail.dart';
import 'package:pharmacy_employee/views/user/user.dart';
import 'package:system_alert_window/system_alert_window.dart';

extension DateFormatter on String {
  String get convertToDate {
    return DateFormat.yMMMMd('vi_VN').format(DateTime.parse(this));
  }
}

extension DoubleExtensions on int {
  String toKilometers() {
    if (this < 1000) {
      return '${toStringAsFixed(0)}m';
    } else {
      double distanceInKm = this / 1000;
      return '${distanceInKm.toStringAsFixed(2)}km';
    }
  }
}

extension PriceConvert on num {
  String convertCurrentcy() {
    return NumberFormat.currency(locale: 'vi', symbol: 'đ').format(this);
  }
}

@pragma('vm:entry-point')
bool callBackFunction(String tag) {
  SendPort port = IsolateManager.lookupPortByName();
  port.send([tag]);
  return true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "dotenv");
  await GetStorage.init();
  await initializeDateFormatting('vi_VN', null);

  SystemAlertWindow.requestPermissions;
  Get.put(AppController());

  await SystemAlertWindow.checkPermissions();
  ReceivePort port = ReceivePort();
  IsolateManager.registerPortWithName(port.sendPort);
  port.listen((dynamic callBackData) {
    String tag = callBackData[0];
    String tagKey = tag.split('-')[0];
    String value = tag.split('-')[1];
    switch (tagKey) {
      case "personal_btn":
        print(
            "Personal button click : Do what ever you want here. This is inside your application scope");
        break;
      case closeBtnTag:
        AppController.closeOverlay();
        break;
      case callBtnTag:
        AppController().callBtnOverlay(value);
        break;
    }
  });
  SystemAlertWindow.registerOnClickListener(callBackFunction);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Material App',
      initialRoute: appController.isLogin.value ? "/home" : "/login",
      theme: FlexThemeData.light(
        scheme: FlexScheme.aquaBlue,
        useMaterial3: true,
      ),
      defaultTransition: Transition.cupertino,
      getPages: [
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/lookup', page: () => const ProductLookup()),
        GetPage(name: '/map', page: () => const MapScreen()),
        GetPage(
          name: '/order_view',
          page: () => const OrderScreen(),
        ),
        GetPage(name: '/debug', page: () => const DebugScreen()),
        GetPage(name: '/prep_order', page: () => const PrepOrder()),
        GetPage(name: '/overlay', page: () => const OverLayScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/user', page: () => const UserScreen()),
        GetPage(name: '/prep_pickup', page: () => const PrepPickUpScreen()),
        GetPage(name: '/order_detail', page: () => const OrderDetail()),
        GetPage(name: '/order_confirm', page: () => const ConfirmOrderScreen()),
        GetPage(
          name: '/product_detail',
          page: () => const ProductDetailScreen(),
        ),
      ],
    );
  }
}
