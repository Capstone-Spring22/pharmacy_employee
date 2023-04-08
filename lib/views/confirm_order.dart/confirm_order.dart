import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/input.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/confirm_order.dart/widget/product_note.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmOrderScreen extends StatefulWidget {
  const ConfirmOrderScreen({super.key});

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  OrderHistoryDetail order = OrderHistoryDetail();
  bool isLoading = true;
  TextEditingController inputController = TextEditingController();

  fetchData() async {
    var res = await AppService().fetchOrderDetail(Get.arguments);
    setState(() {
      order = res;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    fetchData();
  }

  showDig(bool isAccept) async {
    showModalBottomSheet(
      useSafeArea: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(42.0),
          topRight: Radius.circular(42.0),
        ),
      ),
      context: context,
      builder: (context) {
        FocusNode focusNode = FocusNode();
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 10,
              left: 15,
              right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom + 50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  isAccept ? "Nhận đơn hàng" : "Từ chối đơn hàng",
                  style: context.textTheme.headlineSmall,
                ),
                Input(
                  inputController: inputController,
                  focus: focusNode,
                  expands: true,
                  maxLines: null,
                  title: isAccept ? "Thông tin" : "Lý do từ chối",
                  autofocus: true,
                  txtHeight: 100,
                  inputType: TextInputType.multiline,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: SwipeButton.expand(
                    enabled: order.actionStatus!.canAccept!,
                    thumb: const Icon(
                      Icons.double_arrow_rounded,
                      color: Colors.white,
                    ),
                    activeThumbColor: isAccept
                        ? context.theme.primaryColor
                        : context.theme.colorScheme.error,
                    activeTrackColor: Colors.grey.shade300,
                    onSwipe: () async {
                      if (isAccept) {
                        await appController
                            .validateOrder(
                              isAccept: true,
                              orderId: order.id!,
                            )
                            .then((value) => showComebackOrProcess());
                      } else {
                        await appController
                            .validateOrder(
                              isAccept: false,
                              orderId: order.id!,
                              desc: inputController.text,
                            )
                            .then((value) => showComebackOrProcess());
                      }
                    },
                    child: Text(
                      "Xác nhận",
                      style: context.textTheme.headlineSmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  showComebackOrProcess() {
    Get.defaultDialog(
      title: "Đã xử lý thành công",
      middleText: "Nhận thêm đơn hoặc thực hiện đơn?",
      textConfirm: "Nhận thêm",
      textCancel: "Thực hiện",
      confirmTextColor: Colors.white,
      buttonColor: context.theme.primaryColor,
      cancelTextColor: context.theme.primaryColorDark,
      onCancel: () {
        appController.orderTabController.value!.animateTo(0);
        Get.back();
        Get.back();
        Get.back();
      },
      onConfirm: () {
        Get.back();
        Get.back();
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác Nhận Đơn Hàng"),
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? Center(
                child: LoadingWidget(
                  size: 60,
                ),
              )
            : Column(
                children: [
                  DetailContent(
                    title: "Tên Khách Hàng",
                    content: Text(
                        style:
                            TextStyle(fontSize: appController.fontSize.value),
                        order.orderContactInfo!.fullname!),
                  ),
                  DetailContent(
                    title: "Email",
                    content: Text(
                      style: TextStyle(fontSize: appController.fontSize.value),
                      order.orderContactInfo!.email ?? "Không có email",
                    ),
                  ),
                  GestureDetector(
                    onTap: () async => await launchUrl(Uri.parse(
                        "tel://${order.orderContactInfo!.phoneNumber}")),
                    child: DetailContent(
                      title: "Số Điện Thoại",
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: appController.fontSize.value,
                              color: Colors.blue,
                            ),
                            order.orderContactInfo!.phoneNumber!,
                          ),
                          const CircleAvatar(child: Icon(Icons.call))
                        ],
                      ),
                    ),
                  ),
                  if (order.orderDelivery != null)
                    DetailContent(
                      title: "Địa Chỉ",
                      content: Text(
                        style:
                            TextStyle(fontSize: appController.fontSize.value),
                        order.orderDelivery!.homeNumber!,
                      ),
                    ),
                  DetailContent(
                    title: "Tổng Tiền",
                    content: Text(
                      style: TextStyle(fontSize: appController.fontSize.value),
                      order.totalPrice!.convertCurrentcy(),
                    ),
                  ),
                  ListView.builder(
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ProductNote(
                            order: order,
                            index: index,
                          ),
                          const Divider(),
                        ],
                      );
                    },
                    itemCount: order.orderProducts!.length,
                    shrinkWrap: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: SwipeButton.expand(
                      enabled: order.actionStatus!.canAccept!,
                      thumb: const Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.white,
                      ),
                      activeThumbColor: context.theme.primaryColor,
                      activeTrackColor: Colors.grey.shade300,
                      onSwipe: () async {
                        if (order.pharmacistId == null) {
                          await showDig(true);
                        }
                      },
                      child: Text(
                        "Nhận đơn này",
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: SwipeButton.expand(
                      enabled: order.actionStatus!.canAccept!,
                      thumb: const Icon(
                        Icons.double_arrow_rounded,
                        color: Colors.white,
                      ),
                      activeThumbColor: context.theme.colorScheme.error,
                      activeTrackColor: Colors.grey.shade300,
                      onSwipe: () async {
                        await showDig(false);
                      },
                      child: Text(
                        "Từ chối đơn hàng",
                        style: context.textTheme.headlineSmall,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
