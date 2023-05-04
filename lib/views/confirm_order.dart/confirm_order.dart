import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
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
      order = res!;
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
        final theme = context.textTheme;
        final formKey = GlobalKey<FormState>();
        final deboucer = Debouncer(delay: 500.milliseconds);
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
                  style: theme.headlineSmall,
                ),
                isAccept
                    ? Input(
                        inputController: inputController,
                        focus: focusNode,
                        expands: true,
                        maxLines: null,
                        title: "Ghi chú của nhân viên",
                        autofocus: true,
                        txtHeight: 100,
                        inputType: TextInputType.multiline,
                      )
                    : Form(
                        key: formKey,
                        child: Input(
                          inputController: inputController,
                          focus: focusNode,
                          expands: true,
                          isFormField: true,
                          maxLines: null,
                          title: "Lý do từ chối đơn hàng (tối thiểu 10 kí tự)",
                          validator: (p0) => p0!.isEmpty
                              ? "Không được để trống"
                              : p0.isNumericOnly
                                  ? 'Lý do không hợp lệ'
                                  : p0.length < 10
                                      ? "Lý do từ chối quá ngắn"
                                      : null,
                          autofocus: true,
                          txtHeight: 100,
                          inputType: TextInputType.multiline,
                          onChanged: (v) {
                            deboucer.cancel();
                            deboucer.call(() {
                              formKey.currentState!.validate();
                            });
                          },
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
                    activeThumbColor: isAccept
                        ? context.theme.primaryColor
                        : context.theme.colorScheme.error,
                    activeTrackColor: Colors.grey.shade300,
                    onSwipe: () async {
                      Get.dialog(Center(
                        child: SizedBox(
                          height: Get.height * 4,
                          width: Get.height * 5,
                          child: LoadingWidget(
                            size: 60,
                          ),
                        ),
                      ));
                      if (isAccept) {
                        await appController
                            .validateOrder(
                          isAccept: true,
                          orderId: order.id!,
                        )
                            .then((value) async {
                          await appController.triggerOrderLoad();
                          showComebackOrProcess();
                        });
                      } else {
                        await appController
                            .validateOrder(
                          isAccept: false,
                          orderId: order.id!,
                          desc: inputController.text,
                        )
                            .then((value) async {
                          await appController.triggerOrderLoad();
                          showComebackOrProcess();
                        });
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
        Get
          ..back()
          ..back()
          ..back()
          ..back();
      },
      onConfirm: () {
        Get
          ..back()
          ..back()
          ..back()
          ..back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final font = appController.fontSize;
    final orderContactInfo = order.orderContactInfo;
    final orderAction = order.actionStatus;
    final txtTheme = context.textTheme;
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
                      style: TextStyle(fontSize: font.value),
                      order.orderContactInfo!.fullname!,
                    ),
                  ),
                  if (orderContactInfo!.email != null &&
                      orderContactInfo.email!.isNotEmpty)
                    DetailContent(
                      title: "Email",
                      content: Text(
                        style: TextStyle(fontSize: font.value),
                        order.orderContactInfo!.email ?? "Không có email",
                      ),
                    ),
                  GestureDetector(
                    onTap: () async => await launchUrl(
                      Uri.parse("tel://${order.orderContactInfo!.phoneNumber}"),
                    ),
                    child: DetailContent(
                      title: "Số Điện Thoại",
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: font.value,
                              color: Colors.blue,
                            ),
                            order.orderContactInfo!.phoneNumber!,
                          ),
                          const CircleAvatar(
                            child: Icon(Icons.call),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (order.orderDelivery != null)
                    DetailContent(
                      title: "Địa Chỉ",
                      content: Text(
                        style: TextStyle(fontSize: font.value),
                        order.orderDelivery!.fullyAddress!,
                      ),
                    ),
                  DetailContent(
                    title: "Tổng Tiền",
                    content: Text(
                      style: TextStyle(fontSize: font.value),
                      order.totalPrice!.convertCurrentcy(),
                    ),
                  ),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
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
                    // child: SwipeButton.expand(
                    //   enabled: orderAction!.canAccept!,
                    //   thumb: const Icon(
                    //     Icons.double_arrow_rounded,
                    //     color: Colors.white,
                    //   ),
                    //   activeThumbColor: context.theme.primaryColor,
                    //   activeTrackColor: Colors.grey[300],
                    //   onSwipe: () async {
                    //     if (order.pharmacistId == null) {
                    //       await showDig(true);
                    //     }
                    //   },
                    //   child: Text(
                    //     "Nhận đơn này",
                    //     style: txtTheme.headlineSmall,
                    //   ),
                    // ),
                    child: SizedBox(
                      width: Get.width * .8,
                      child: FilledButton(
                        onPressed: orderAction!.canAccept!
                            ? () async {
                                if (order.pharmacistId == null) {
                                  await showDig(true);
                                }
                              }
                            : null,
                        child: Text(
                          "Nhận đơn này",
                          style: txtTheme.headlineSmall!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    // child: SwipeButton.expand(
                    //   enabled: order.actionStatus!.canAccept!,
                    //   thumb: const Icon(
                    //     Icons.double_arrow_rounded,
                    //     color: Colors.white,
                    //   ),
                    //   activeThumbColor: context.theme.colorScheme.error,
                    //   activeTrackColor: Colors.grey.shade300,
                    //   onSwipe: () async {
                    //     await showDig(false);
                    //   },
                    //   child: Text(
                    //     "Từ chối đơn hàng",
                    //     style: context.textTheme.headlineSmall,
                    //   ),
                    // ),
                    child: SizedBox(
                      width: Get.width * .8,
                      child: FilledButton(
                        onPressed: order.actionStatus!.canAccept!
                            ? () async {
                                await showDig(false);
                              }
                            : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Colors.red,
                          ),
                        ),
                        child: Text(
                          "Từ chối đơn hàng",
                          style: txtTheme.headlineSmall!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
