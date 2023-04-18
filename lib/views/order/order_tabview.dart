import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order.dart';
import 'package:pharmacy_employee/views/order_detail/order_detail.dart';

class OrderTabView extends StatefulWidget {
  const OrderTabView(this.scrollController, this.type, {super.key});

  final ScrollController scrollController;
  final String type;

  @override
  State<OrderTabView> createState() => _OrderTabViewState();
}

class _OrderTabViewState extends State<OrderTabView> {
  List<String> viewType = ["2", "3", "4", "9", "6", "7", "8", "10"];
  late final ExprollablePageController exprollablePageController;
  final peekOffset = const ViewportOffset.fractional(0.1);
  @override
  void initState() {
    super.initState();
    exprollablePageController = ExprollablePageController(
      initialViewportOffset: peekOffset,
      maxViewportOffset: peekOffset,
      snapViewportOffsets: [
        ViewportOffset.expanded,
        ViewportOffset.shrunk,
        peekOffset,
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    exprollablePageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dateRender = "";
    bool isLoading = true;
    List<OrderHistory> getList() {
      if (widget.type == 'unAccept') {
        isLoading = appController.isUnAcceptLoading.value;
        return appController.orderUnAcceptList;
      } else if (widget.type == 'active') {
        isLoading = appController.isActiveLoading.value;
        return appController.orderActiveList;
      } else {
        isLoading = appController.isCantAcceptLoading.value;
        return appController.orderCantAcceptList;
      }
    }

    return GetX<AppController>(
      builder: (controller) {
        List<OrderHistory> list = getList();
        bool isProcessMode = appController.isProcessMode.value;
        final fontSize = appController.fontSize;
        final theme = context.theme;
        if (isLoading && list.isEmpty) {
          return Center(
            child: LoadingWidget(
              size: 60,
            ),
          );
        } else if (!isLoading && list.isEmpty) {
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
              itemCount: list.length + 1,
              itemBuilder: (context, index) {
                if (index < list.length) {
                  final item = list[index];
                  bool dif = dateRender == item.createdDate!.convertToDate;
                  if (!dif) {
                    dateRender = item.createdDate!.convertToDate;
                  }

                  if (isProcessMode) {
                    if (item.orderStatus != '6' &&
                        item.orderStatus != '3' &&
                        item.orderStatus != '7') {
                      return Container();
                    }
                  }

                  return GestureDetector(
                    onTap: () {
                      showOrderDetailDialog(context, index, widget.type);
                    },
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
                                  if (appController.orderProcessList.isEmpty) {
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
                                if (!dif && appController.isProcessMode.isFalse)
                                  Text(
                                    dateRender,
                                    style: TextStyle(
                                      fontSize: appController.fontSize.value,
                                    ),
                                  ),
                                Obx(() => Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: theme.primaryColor,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.shade300,
                                            blurRadius: 7,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                        color:
                                            appController.isProcessMode.isTrue
                                                ? appController.orderProcessList
                                                        .contains(item.id)
                                                    ? theme.secondaryHeaderColor
                                                    : Colors.white
                                                : Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (kDebugMode)
                                            Text(
                                              "order status: ${item.orderStatus}",
                                              style: TextStyle(
                                                fontSize: fontSize.value,
                                              ),
                                            ),
                                          Text(
                                            "Tình Trạng: ${item.orderStatusName}",
                                            style: TextStyle(
                                              fontSize: fontSize.value,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                          Text(
                                            "Ngày Tạo: ${item.createdDate!.convertToDate}",
                                            style: TextStyle(
                                              fontSize: fontSize.value,
                                            ),
                                          ),
                                          Text(
                                            "Loại Đơn: ${item.orderTypeName}",
                                            style: TextStyle(
                                              fontSize: fontSize.value,
                                            ),
                                          ),
                                          Text(
                                            item.paymentMethod.toString(),
                                            style: TextStyle(
                                              fontSize: fontSize.value,
                                            ),
                                          ),
                                          Text(
                                            "Tổng Tiền: ${item.totalPrice!.convertCurrentcy()}",
                                            style: TextStyle(
                                              fontSize: fontSize.value,
                                            ),
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
                  ).animate().slideX(delay: (index * 20).ms).fade();
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
