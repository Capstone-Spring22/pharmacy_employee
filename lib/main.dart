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
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/views/confirm_order.dart/confirm_order.dart';
import 'package:pharmacy_employee/views/debug/debug_screen.dart';
import 'package:pharmacy_employee/views/error/error.dart';
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

extension GroupProduct on List<OrderProducts> {
  List<List<OrderProducts>> groupProductByName() {
    List<List<OrderProducts>> result = [];
    List<OrderProducts> temp = [];
    String currentName = '';

    temp = this;
    try {
      temp.sort((a, b) => a.productName!.compareTo(b.productName!));
    } catch (e) {
      Get.log("Error Sort Group: $e");
    }

    for (var product in temp) {
      if (product.productName != currentName) {
        currentName = product.productName!;
        result.add([product]);
      } else {
        result.last.add(product);
      }
    }

    return result;
  }
}

extension PriceConvert on num {
  String convertCurrentcy() {
    return NumberFormat.currency(locale: 'vi', symbol: 'đ').format(this);
  }

  String toKilometers() {
    if (this < 1000) {
      return '${toStringAsFixed(0)}m';
    } else {
      double distanceInKm = this / 1000;
      return '${distanceInKm.toStringAsFixed(2)}km';
    }
  }

  String convertToHoursMinutes() {
    int wholeHours = (this / 3600).floor();
    int remainingMinutes = ((this % 3600) / 60).floor();
    int remainingSeconds = (this % 60).round();

    String hoursString = wholeHours.toString();
    String minutesString = remainingMinutes.toString().padLeft(2, '0');
    String secondsString = remainingSeconds.toString().padLeft(2, '0');
    return '$hoursString tiếng $minutesString phút';
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

  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return ErrorScreen(errorDetails: errorDetails);
  };

  await dotenv.load(fileName: "dotenv");
  await GetStorage.init();
  await initializeDateFormatting('vi_VN', null);
  Get.put(AppController());

  SystemAlertWindow.requestPermissions;

  await SystemAlertWindow.checkPermissions();
  ReceivePort port = ReceivePort();
  IsolateManager.registerPortWithName(port.sendPort);
  port.listen((dynamic callBackData) {
    String tag = callBackData[0];
    String tagKey = tag.split('-')[0];
    String value = tag.split('-')[1];
    switch (tagKey) {
      case "personal_btn":
        debugPrint(
          "Personal button click : Do what ever you want here. This is inside your application scope",
        );
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
        GetPage(name: '/debug', page: () => const DebugScreen()),
        GetPage(name: '/overlay', page: () => const OverLayScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/user', page: () => const UserScreen()),
        GetPage(name: '/prep_pickup', page: () => const PrepPickUpScreen()),
        GetPage(name: '/prep_order', page: () => const PrepOrder()),
        GetPage(name: '/order_detail', page: () => const OrderDetail()),
        GetPage(name: '/order_confirm', page: () => const ConfirmOrderScreen()),
        GetPage(
          name: '/order_view',
          page: () => const OrderScreen(),
        ),
        GetPage(
          name: '/product_detail',
          page: () => const ProductDetailScreen(),
        ),
      ],
    );
  }
}
