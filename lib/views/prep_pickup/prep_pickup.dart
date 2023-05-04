import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/input.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/helpers/showSnack.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';
import 'package:pharmacy_employee/views/prep_order.dart/widget/unitcheck.dart';

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
  List<String> finished = [];

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

  dialogCancelOrder(String id) {
    final txt = TextEditingController();
    final key = GlobalKey<FormState>();
    final debouncer = Debouncer(delay: 100.ms);
    Get.defaultDialog(
        backgroundColor: Colors.white,
        radius: 20,
        barrierDismissible: true,
        title: 'Bạn có chắc chắn muốn hủy đơn hàng này không?',
        actions: [
          // SizedBox(
          //   width: Get.width * .3,
          //   child: const SwipeButton.expand(child: Text('Hủy Đơn Hàng')),
          // )
          FilledButton(
            onPressed: () => Get.back(),
            child: const Text('Không'),
          ),
          FilledButton(
            onPressed: () async {
              if (key.currentState!.validate()) {
                Get.dialog(LoadingWidget());
                var res = await AppService().cancelOrder(id, txt.text);
                if (res == 200) {
                  setState(() {
                    appController.orderProcessList
                        .removeWhere((element) => element == id);
                    final order = orderDetails
                        .singleWhere((element) => element!.id == id);
                    for (var element in order!.orderProducts!) {
                      Get.log('id to remove: ${element.id}');
                      finished.removeWhere((e) {
                        Get.log('finished: $e');
                        return e == element.id;
                      });
                    }
                    orderDetails.remove(order);
                    totalProduct = 0;
                    for (var i = 0; i < orderDetails.length; i++) {
                      totalProduct += orderDetails[i]!.orderProducts!.length;
                    }

                    isCompletePrep = finished.length == totalProduct;
                  });
                  appController.triggerOrderLoad();
                  Get.back();
                  Get.back();
                } else {
                  Get.back();
                  Get.back();
                  Get.snackbar('Lỗi', 'Hủy đơn hàng thất bại');
                }
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
            child: const Text('Hủy Đơn Hàng'),
          ),
        ],
        content: Form(
          key: key,
          child: Column(
            children: [
              Input(
                title: 'Lý do hủy đơn (tối thiểu 10 ký tự)',
                inputController: txt,
                autofocus: true,
                txtHeight: Get.height * .1,
                expands: true,
                inputType: TextInputType.multiline,
                isFormField: true,
                validator: (p0) {
                  if (p0!.length < 10) {
                    return 'Lý do hủy đơn phải có ít nhất 10 ký tự';
                  }
                  return null;
                },
                onChanged: (p0) {
                  debouncer.cancel();
                  debouncer.call(() {
                    key.currentState!.validate();
                  });
                },
              ),
            ],
          ),
        ));
  }

  finishOrder(String index) {
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingWidget(
                    size: 60,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  appController.orderProcessList.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Không có đơn hàng nào',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Hãy chọn đơn hàng để chuẩn bị',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: appController.orderProcessList.length,
                          itemBuilder: (context, index) {
                            final contactInfo =
                                orderDetails[index]!.orderContactInfo!;
                            final products =
                                orderDetails[index]!.orderProducts!;
                            final grouped = orderDetails[index]!
                                .orderProducts!
                                .groupProductByName();
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
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
                                    appController.orderProcessList[index],
                                    maxLines: 1,
                                  ),
                                  expandedCrossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    DetailContent(
                                      title: "Tên khách hàng",
                                      content: AutoSizeText(
                                        "${contactInfo.fullname}",
                                      ),
                                      haveDivider: false,
                                    ),
                                    DetailContent(
                                      title: "Số điện thoại",
                                      content: AutoSizeText(
                                        "${contactInfo.phoneNumber}",
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
                                    ),
                                    productList(grouped, products),
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: FilledButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.red),
                                          ),
                                          onPressed: () => dialogCancelOrder(
                                            orderDetails[index]!.id!,
                                          ),
                                          child: const Text('Hủy Đơn Hàng'),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                  if (appController.orderProcessList.isNotEmpty)
                    PickupOrderPrepButton(
                      isCompletePrep: isCompletePrep,
                      orderDetails: orderDetails,
                      totalProduct: totalProduct,
                      finished: finished,
                    ),
                ],
              ),
            ),
    );
  }

  DetailContent productList(
    List<List<OrderProducts>> grouped,
    List<OrderProducts> products,
  ) {
    return DetailContent(
      title: "Danh sách sản phẩm",
      haveDivider: false,
      content: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: grouped.length,
        itemBuilder: (context, i) {
          final item = grouped[i];
          return Padding(
            padding: const EdgeInsets.all(8.0),
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
                  ]),
              child: ListTile(
                title: Text(
                  products[i].productName!,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...item.map(
                      (e) => UnitCheck(
                        product: e,
                        onCheck: (v) {
                          setState(() {
                            if (v) {
                              finishOrder(e.id!);
                            } else {
                              finished.remove(
                                e.id,
                              );
                              isCompletePrep = finished.length == totalProduct;
                            }
                          });
                        },
                        value: finished.contains(
                          e.id,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().slideX(delay: (i * 80).ms).fade();
        },
      ),
    );
  }
}

class PickupOrderPrepButton extends StatelessWidget {
  const PickupOrderPrepButton(
      {super.key,
      required this.isCompletePrep,
      required this.orderDetails,
      required this.totalProduct,
      required this.finished});

  final bool isCompletePrep;
  final List<OrderHistoryDetail?> orderDetails;
  final int totalProduct;
  final List<String> finished;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Get.dialog(Center(
            child: LoadingWidget(
              size: 60,
            ),
          ));
          for (var e in orderDetails) {
            await appController.updateOrderStatus(
              orderId: e!.id!,
              status: "9",
              desc: "",
            );
          }

          appController.orderProcessList.clear();
          appController.isProcessMode.value = false;
          await appController.triggerOrderLoad().then((value) {
            Get.offNamedUntil(
                '/order_view', (route) => route.settings.name == '/order_view');
          });

          showSnack('Thông báo', 'Chuẩn bị hàng thành công, đợi khách đến lấy',
              SnackType.success);
        },
        child: Text(
          isCompletePrep
              ? "Hoàn tất chuẩn bị"
              : "Còn ${totalProduct - finished.length} sản phẩm",
        ),
      ),
    );
  }
}
