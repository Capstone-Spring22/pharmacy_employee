import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order.dart';

class OrderTabView extends StatefulWidget {
  const OrderTabView(this.scrollController, this.type, {super.key});

  final ScrollController scrollController;
  final String type;

  @override
  State<OrderTabView> createState() => _OrderTabViewState();
}

class _OrderTabViewState extends State<OrderTabView> {
  List<String> viewType = ["2", "3", "4", "9", "6", "7", "8", "10"];
  @override
  Widget build(BuildContext context) {
    String dateRender = "";
    bool isLoading = true;
    return GetX<AppController>(
      builder: (controller) {
        List<OrderHistory> list() {
          if (widget.type == 'unAccept') {
            isLoading = controller.isUnAcceptLoading.value;
            return controller.orderUnAcceptList;
          } else if (widget.type == 'active') {
            isLoading = controller.isActiveLoading.value;
            return controller.orderActiveList;
          } else {
            isLoading = controller.isCantAcceptLoading.value;
            return controller.orderCantAcceptList;
          }
        }

        if (isLoading && list().isEmpty) {
          return Center(
            child: LoadingWidget(
              size: 60,
            ),
          );
        } else if (!isLoading && list().isEmpty) {
          return Center(
            child: Text(
              "Không Tìm Thấy Đơn",
              style: TextStyle(fontSize: appController.fontSize.value),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: ListView.builder(
              shrinkWrap: true,
              controller: widget.scrollController,
              itemCount: list().length + 1,
              itemBuilder: (context, index) {
                if (index < list().length) {
                  final item = list()[index];
                  bool dif = dateRender == item.createdDate!.convertToDate;
                  if (!dif) {
                    dateRender = item.createdDate!.convertToDate;
                  }

                  if (item.orderStatus == '8' &&
                      appController.isProcessMode.isTrue) {
                    return Container();
                  }

                  return GestureDetector(
                    onTap: () => Get.toNamed(
                      '/order_detail',
                      arguments: item.id,
                    ),
                    onLongPress: () {
                      if (appController.orderTabController.value!.index == 0) {
                        appController.isProcessMode.toggle();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          if (appController.isProcessMode.isTrue &&
                              appController.orderTabController.value!.index ==
                                  0)
                            Checkbox(
                              value: appController.orderProcessList
                                  .contains(item.id),
                              onChanged: (value) {
                                if (value!) {
                                  if (item.orderStatus == '11') {
                                    Get.showSnackbar(GetSnackBar(
                                      message:
                                          "Không thể thực hiện đơn hàng bị huỷ/từ chối",
                                      backgroundColor:
                                          context.theme.colorScheme.error,
                                      duration: const Duration(seconds: 2),
                                    ));
                                  } else if (item.orderStatus == '9') {
                                    Get.showSnackbar(GetSnackBar(
                                      message:
                                          "Đơn hàng đã được chuẩn bị, hãy đợi khách đến nhận hàng",
                                      backgroundColor:
                                          context.theme.primaryColor,
                                      duration: const Duration(seconds: 2),
                                    ));
                                  } else if (item.orderStatus == '8') {
                                    Get.showSnackbar(GetSnackBar(
                                      message:
                                          "Đơn hàng đã được giao, không thể thực hiện",
                                      backgroundColor:
                                          context.theme.colorScheme.error,
                                      duration: const Duration(seconds: 2),
                                    ));
                                  } else {
                                    if (appController
                                        .orderProcessList.isEmpty) {
                                      appController.orderType.value =
                                          item.orderTypeName!;
                                    }
                                    if (item.orderTypeName !=
                                        appController.orderType.value) {
                                      Get.showSnackbar(
                                        GetSnackBar(
                                          message:
                                              "Không thể thực hiện đơn hàng có loại khác nhau",
                                          backgroundColor:
                                              context.theme.colorScheme.error,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    } else {
                                      appController.orderProcessList
                                          .add(item.id!);
                                    }
                                  }
                                } else {
                                  appController.orderProcessList
                                      .remove(item.id);
                                }
                              },
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!dif)
                                  Text(
                                    dateRender,
                                    style: TextStyle(
                                        fontSize: appController.fontSize.value),
                                  ),
                                Obx(() => AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 100),
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: context.theme.primaryColor,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                        color:
                                            appController.isProcessMode.isTrue
                                                ? appController.orderProcessList
                                                        .contains(item.id)
                                                    ? context.theme
                                                        .secondaryHeaderColor
                                                    : Colors.transparent
                                                : Colors.transparent,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Tình Trạng: ${item.orderStatusName}",
                                            style: TextStyle(
                                              fontSize:
                                                  appController.fontSize.value,
                                              color: context.theme.primaryColor,
                                            ),
                                          ),
                                          Text(
                                            "Ngày Tạo: ${item.createdDate!.convertToDate}",
                                            style: TextStyle(
                                                fontSize: appController
                                                    .fontSize.value),
                                          ),
                                          Text(
                                            "Loại Đơn: ${item.orderTypeName}",
                                            style: TextStyle(
                                                fontSize: appController
                                                    .fontSize.value),
                                          ),
                                          Text(
                                            item.paymentMethod.toString(),
                                            style: TextStyle(
                                                fontSize: appController
                                                    .fontSize.value),
                                          ),
                                          Text(
                                            "Tổng Tiền: ${item.totalPrice!.convertCurrentcy()}",
                                            style: TextStyle(
                                                fontSize: appController
                                                    .fontSize.value),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
                  if (isLoading) {
                    return LoadingWidget();
                  } else {
                    return const SizedBox();
                  }
                }
              },
            ),
          );
        }
      },
    );
  }
}
