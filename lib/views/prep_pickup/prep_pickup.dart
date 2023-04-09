import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';

class PrepPickUpScreen extends StatefulWidget {
  const PrepPickUpScreen({super.key});

  @override
  State<PrepPickUpScreen> createState() => _PrepPickUpScreenState();
}

class _PrepPickUpScreenState extends State<PrepPickUpScreen> {
  List<OrderHistoryDetail?> orderDetails = [];
  bool isLoading = false;
  bool isCompletePrep = false;
  int totalProduct = 0;
  List<int> finished = [];

  @override
  void initState() {
    super.initState();
    _loadOrderProcess();
  }

  _loadOrderProcess() async {
    try {
      setState(() {
        isLoading = true;
      });
      orderDetails = await Future.wait(
        appController.orderProcessList.map(
          (e) => AppService().fetchOrderDetail(e),
        ),
      );
      for (var i = 0; i < orderDetails.length; i++) {
        totalProduct += orderDetails[i]!.orderProducts!.length;
      }
      setState(() {
        isLoading = false;
      });
    } on Exception {
      // TODO
    }
  }

  finishOrder(int index) {
    setState(() {
      finished.add(index);
      isCompletePrep = finished.length == totalProduct;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Chuẩn bị đơn hàng'),
          actions: const [],
        ),
        body: isLoading
            ? Center(
                child: LoadingWidget(
                  size: 60,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ExpansionTile(
                              initiallyExpanded: true,
                              title: AutoSizeText(
                                  appController.orderProcessList[index]),
                              expandedCrossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                DetailContent(
                                  title: "Tên khách hàng",
                                  content: AutoSizeText(
                                    "${orderDetails[index]!.orderContactInfo!.fullname}",
                                  ),
                                  haveDivider: false,
                                ),
                                DetailContent(
                                  title: "Số điện thoại",
                                  content: AutoSizeText(
                                    "${orderDetails[index]!.orderContactInfo!.phoneNumber}",
                                  ),
                                  haveDivider: false,
                                ),
                                DetailContent(
                                  title: "Tổng tiền",
                                  content: AutoSizeText(
                                    orderDetails[index]!
                                        .totalPrice!
                                        .convertCurrentcy(),
                                  ),
                                  haveDivider: false,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      child: ListTile(
                                        trailing: Checkbox(
                                          value: finished.contains(index),
                                          onChanged: (value) {
                                            if (value!) {
                                              setState(() {
                                                finishOrder(index);
                                              });
                                            } else {
                                              setState(() {
                                                finished.remove(index);
                                                isCompletePrep =
                                                    finished.length ==
                                                        totalProduct;
                                              });
                                            }
                                          },
                                        ),
                                        title: Text(orderDetails[index]!
                                            .orderProducts![i]
                                            .productName!),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${orderDetails[index]!.orderProducts![i].quantity} ${orderDetails[index]!.orderProducts![i].unitName} - ${orderDetails[index]!.orderProducts![i].priceTotal!.convertCurrentcy()}",
                                            ),
                                            AutoSizeText(
                                              orderDetails[index]!
                                                      .orderProducts![i]
                                                      .productNoteFromPharmacist ??
                                                  "",
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: orderDetails[index]!
                                      .orderProducts!
                                      .length,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: appController.orderProcessList.length,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      child: SwipeButton.expand(
                        enabled: isCompletePrep,
                        thumb: const Icon(
                          Icons.double_arrow_rounded,
                          color: Colors.white,
                        ),
                        activeThumbColor: context.theme.primaryColor,
                        activeTrackColor: Colors.grey.shade300,
                        onSwipe: () async {
                          appController.orderProcessList.clear();
                          appController.orderType.value = "";
                          appController.isProcessMode.value = false;
                          for (var e in orderDetails) {
                            await appController.updateOrderStatus(
                              orderId: e!.id!,
                              status: "9",
                              desc: "",
                            );
                          }
                          await appController
                              .triggerOrderLoad()
                              .then((value) => Get.back());
                        },
                        child: Text(isCompletePrep
                            ? "Hoàn tất chuẩn bị"
                            : "Còn ${totalProduct - finished.length} sản phẩm"),
                      ),
                    )
                  ],
                ),
              ));
  }
}
