import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/models/order.dart';
import 'package:pharmacy_employee/views/order_process/widget/item_process.dart';

import '../../service/app_service.dart';

class OrderProcessScreen extends StatefulWidget {
  const OrderProcessScreen({super.key});

  @override
  State<OrderProcessScreen> createState() => _OrderProcessScreenState();
}

class _OrderProcessScreenState extends State<OrderProcessScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final tabController;
  bool isLoading = false;
  List<OrderHistory> listDelivery = [];
  List<OrderHistory> listPickup = [];
  int page = 1;
  bool haveNext = false;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    _fetchMoreOrder();
    super.initState();
  }

  Future _fetchMoreOrder() async {
    setState(() {
      isLoading = true;
    });

    final res = await AppService().fetchOrderProcess(page);
    List<OrderHistory> tempListDelivery = [];
    List<OrderHistory> tempListPickup = [];
    for (final item in res['items']) {
      final order = OrderHistory.fromJson(item);
      if (order.orderTypeId == 2) {
        if (order.orderStatus != '9') {
          tempListPickup.add(order);
        }
      } else {
        tempListDelivery.add(order);
      }
    }

    haveNext = res['hasNextPage'];

    setState(() {
      listDelivery.addAll(tempListDelivery);
      listPickup.addAll(tempListPickup);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xử lý đơn hàng'),
        bottom: TabBar(
          controller: tabController,
          tabs: const <Widget>[
            Tab(
              text: 'Giao hàng tận nơi',
              icon: Icon(Icons.delivery_dining),
            ),
            Tab(
              text: 'Nhận tại cửa hàng',
              icon: Icon(Icons.store),
            ),
          ],
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: appController.orderProcessList.isEmpty
                  ? null
                  : () async {
                      if (appController.orderType.value ==
                          "Giao hàng tận nơi") {
                        if (await Permission.location.isGranted) {
                          Get.toNamed('/prep_order');
                        } else {
                          await Permission.location.request().then(
                                (value) => Get.toNamed('/prep_order'),
                              );
                        }
                      } else {
                        Get.toNamed('/prep_pickup');
                      }
                    },
              child: Text(
                "Thực hiện ${appController.orderProcessList.length} đơn",
              ),
            ),
          ),
        ],
      ),
      body: isLoading && listDelivery.isEmpty
          ? Center(
              child: LoadingWidget(
                size: 60,
              ),
            )
          : TabBarView(
              controller: tabController,
              children: [
                !isLoading && listDelivery.isEmpty
                    ? const Center(
                        child: Text('Không có đơn hàng nào cần xử lý'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          if (index < listDelivery.length) {
                            final item = listDelivery[index];
                            return ItemProcess(item: item, index: index);
                          } else {
                            if (isLoading) {
                              return LoadingWidget();
                            } else {
                              return const SizedBox();
                            }
                          }
                        },
                        itemCount: listDelivery.length + 1,
                      ),
                !isLoading && listPickup.isEmpty
                    ? const Center(
                        child: Text('Không có đơn hàng nào cần xử lý'),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          if (index < listPickup.length) {
                            final item = listPickup[index];
                            return ItemProcess(
                              item: item,
                              index: index,
                            );
                          } else {
                            if (isLoading) {
                              return LoadingWidget();
                            } else {
                              return const SizedBox();
                            }
                          }
                        },
                        itemCount: listPickup.length + 1,
                      ),
              ],
            ),
    );
  }
}
