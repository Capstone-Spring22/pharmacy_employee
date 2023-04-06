import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  int currentIndex = 1;
  bool isAccept = true;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    appController.initOrder(1, isAccept, isNew: true);
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (appController.orderHaveNext.isTrue) {
          currentIndex++;
          appController.initOrder(currentIndex, isAccept);
        }
      }
    });
  }

  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));
  @override
  Widget build(BuildContext context) {
    String dateRender = "";
    return WillPopScope(
      onWillPop: () async {
        appController.orderList.clear();
        appController.orderHaveNext.value = false;
        appController.isLoading.value = false;

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Đơn Hàng"),
          actions: [
            Switch.adaptive(
                value: isAccept,
                onChanged: (v) {
                  setState(() {
                    isAccept = v;
                  });
                  appController.initOrder(1, isAccept, isNew: true);
                })
          ],
        ),
        body: GetX<AppController>(
          builder: (controller) {
            if (controller.isLoading.isTrue && controller.orderList.isEmpty) {
              return Center(
                child: LoadingWidget(
                  size: 60,
                ),
              );
            } else if (controller.isLoading.isFalse &&
                controller.orderList.isEmpty) {
              return Center(
                child: Text(
                  "Không Tìm Thấy Đơn",
                  style: TextStyle(fontSize: appController.fontSize.value),
                ),
              );
            } else {
              return ListView.builder(
                shrinkWrap: true,
                controller: scrollController,
                itemCount: controller.orderList.length + 1,
                itemBuilder: (context, index) {
                  if (index < controller.orderList.length) {
                    final item = controller.orderList[index];
                    bool dif = dateRender == item.createdDate!.convertToDate;
                    if (!dif) {
                      dateRender = item.createdDate!.convertToDate;
                    }
                    return GestureDetector(
                      onTap: () => Get.toNamed(
                        '/order_detail',
                        arguments: item.id,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!dif)
                              Text(
                                dateRender,
                                style: TextStyle(
                                    fontSize: appController.fontSize.value),
                              ),
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ngày Tạo: ${item.createdDate!.convertToDate}",
                                    style: TextStyle(
                                        fontSize: appController.fontSize.value),
                                  ),
                                  Text(
                                    "Loại Đơn: ${item.orderTypeName}",
                                    style: TextStyle(
                                        fontSize: appController.fontSize.value),
                                  ),
                                  Text(
                                    item.paymentMethod == "0"
                                        ? "Hình thức thanh toán: Tiền mặt"
                                        : "Hình thức thanh toán: Online",
                                    style: TextStyle(
                                        fontSize: appController.fontSize.value),
                                  ),
                                  Text(
                                    "Tổng Tiền: ${item.totalPrice!.convertCurrentcy()}",
                                    style: TextStyle(
                                        fontSize: appController.fontSize.value),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    if (controller.isLoading.isTrue) {
                      return LoadingWidget();
                    } else {
                      return const SizedBox();
                    }
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }
}
