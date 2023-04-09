import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy_employee/views/order/order_tabview.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../../constant/controller.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with SingleTickerProviderStateMixin {
  int activeIndex = 1;
  int unAcceptUndex = 1;
  int cantIndex = 1;
  Offset offset = const Offset(0, 0);

  ScrollController activeTabScroll = ScrollController();
  ScrollController unAcceptTabScroll = ScrollController();
  ScrollController cantAcceptTabScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    appController.orderTabController =
        TabController(length: 2, vsync: this).obs;

    appController.triggerOrderLoad();

    activeTabScroll.addListener(() {
      if (activeTabScroll.position.pixels ==
          activeTabScroll.position.maxScrollExtent) {
        if (appController.orderActiveHaveNext.isTrue) {
          activeIndex++;
          appController.initOrder(activeIndex, false, 'active');
        }
      }
    });

    unAcceptTabScroll.addListener(() {
      if (unAcceptTabScroll.position.pixels ==
          unAcceptTabScroll.position.maxScrollExtent) {
        if (appController.orderUnAcceptHaveNext.isTrue) {
          unAcceptUndex++;
          appController.initOrder(unAcceptUndex, true, 'unAccept');
        }
      }
    });

    cantAcceptTabScroll.addListener(() {
      if (cantAcceptTabScroll.position.pixels ==
          cantAcceptTabScroll.position.maxScrollExtent) {
        if (appController.orderCantAcceptHaveNext.isTrue) {
          cantIndex++;
          appController.initOrder(cantIndex, true, 'cantAccept');
        }
      }
    });

    appController.orderTabController.value!.addListener(() {
      if (appController.orderTabController.value!.index == 0) {
        setState(() {
          offset = const Offset(0, 0);
        });
      } else {
        setState(() {
          offset = const Offset(100, 0);
        });
      }
    });
  }

  @override
  void dispose() {
    appController.orderTabController = null.obs;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        appController.orderUnAcceptList.clear();
        appController.orderActiveList.clear();
        appController.orderCantAcceptList.clear();

        appController.orderActiveHaveNext.value = false;
        appController.orderCantAcceptHaveNext.value = false;
        appController.orderUnAcceptHaveNext.value = false;

        appController.isLoading.value = false;
        appController.isProcessMode.value = false;

        return true;
      },
      child: Obx(
        () => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              var res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SimpleBarcodeScannerPage(),
                  ));
              setState(() {
                if (res is String) {
                  if (res != "-1") {
                    Get.toNamed('/order_detail', arguments: res);
                  }
                }
              });
            },
            child: const Icon(Icons.barcode_reader),
          ),
          appBar: AppBar(
            title: const Text("Đơn hàng"),
            bottom: TabBar(
              controller: appController.orderTabController.value,
              tabs: const [
                Tab(text: "Đơn đã nhận"),
                Tab(text: "Đơn cần xử lý"),
              ],
            ),
            actions: [
              if (appController.isProcessMode.isTrue)
                TextButton(
                  onPressed: appController.orderProcessList.isEmpty
                      ? null
                      : () async {
                          if (appController.orderType.value ==
                              "Giao hàng tận nơi") {
                            if (await Permission.location.isGranted) {
                              Get.toNamed('/prep_order');
                            } else {
                              await Permission.location
                                  .request()
                                  .then((value) => Get.toNamed('/prep_order'));
                            }
                          } else {
                            Get.toNamed('/prep_pickup');
                          }
                        },
                  child: Text(
                      "Thực hiện ${appController.orderProcessList.length} đơn"),
                ),
              AnimatedSlide(
                duration: const Duration(milliseconds: 100),
                offset: offset,
                child: TextButton(
                  onPressed: () {
                    if (appController.isProcessMode.isTrue) {
                      appController.isProcessMode.value = false;
                    } else {
                      appController.isProcessMode.toggle();
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: appController.isProcessMode.isTrue
                        ? const Text(
                            "Đóng",
                            style: TextStyle(color: Colors.red),
                          )
                        : Text(
                            "Chọn đơn thực hiện",
                            style: TextStyle(color: context.theme.primaryColor),
                          ),
                  ),
                ),
              )
            ],
          ),
          body: TabBarView(
            controller: appController.orderTabController.value,
            children: [
              OrderTabView(unAcceptTabScroll, 'active'),
              OrderTabView(unAcceptTabScroll, 'unAccept'),
            ],
          ),
        ),
      ),
    );
  }
}
