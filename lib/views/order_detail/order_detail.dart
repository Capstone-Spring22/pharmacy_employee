import 'package:auto_size_text/auto_size_text.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
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
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';

void showOrderDetailDialog(BuildContext context, int index, String type) {
  showModalExprollable(
    context,
    useSafeArea: false,
    useRootNavigator: false,
    builder: (context) => ExproPage(index: index, type: type),
  );
}

class ExproPage extends StatefulWidget {
  const ExproPage({super.key, required this.index, required this.type});

  final int index;
  final String type;

  @override
  State<ExproPage> createState() => _ExproPageState();
}

class _ExproPageState extends State<ExproPage> {
  late final ExprollablePageController exprollablePageController;

  @override
  void initState() {
    exprollablePageController = ExprollablePageController(
      initialPage: widget.index,
      overshootEffect: true,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    exprollablePageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = appController.list(widget.type);
    return ExprollablePageView(
      controller: exprollablePageController,
      itemCount: appController.list(widget.type).length,
      itemBuilder: (context, index) {
        return PageGutter(
          gutterWidth: 8,
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: OrderDetail(id: list[index].id!),
          ),
        );
      },
    );
  }
}

class OrderDetail extends StatefulWidget {
  const OrderDetail({super.key, this.id = ""});

  final String id;

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  String id = "";
  late OrderHistoryDetail order;
  bool isFetch = true;
  List<Map<String, dynamic>> mapStatus = [];
  // bool openStatusTile = false;
  // List<OrderStatusHistory> history = [];

  Future _fetchOrderDetail() async {
    if (isFetch == false) {
      setState(() {
        isFetch = true;
      });
    }
    try {
      order = (await AppService().fetchOrderDetail(id))!;
      // history = await AppService().fetchOrderStatusHistory(id);
      mapStatus.clear();
      await AppService().fetchOrderStatus(order.orderTypeId!).then((value) {
        for (final i in value) {
          mapStatus
              .add({"id": i['orderStatusId'], "name": i['orderStatusName']});
        }

        setState(() {
          isFetch = false;
        });
      });
    } catch (e) {
      Get.log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.id.isNotEmpty) {
      id = widget.id;
    } else {
      try {
        id = Get.arguments;
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    _fetchOrderDetail();
  }

  dialogCancelOrder(String id) {
    final txt = TextEditingController();
    final key = GlobalKey<FormState>();
    final debouncer = Debouncer(delay: 100.milliseconds);
    Get.defaultDialog(
        backgroundColor: Colors.white,
        radius: 20,
        barrierDismissible: true,
        title: 'Bạn có chắc chắn muốn hủy đơn hàng này không?',
        actions: [
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
                  setState(() {});
                  appController.triggerOrderLoad();
                  await _fetchOrderDetail();
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

  @override
  Widget build(BuildContext context) {
    final font = appController.fontSize;
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          id,
          maxLines: 1,
        ),
      ),
      body: isFetch
          ? Center(
              child: LoadingWidget(
                size: 60,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                controller: PageContentScrollController.of(context),
                child: Builder(builder: (context) {
                  final contactInfo = order.orderContactInfo;
                  final products = order.orderProducts;
                  final grouped = products!.groupProductByName();
                  return Column(
                    children: [
                      DetailContent(
                        title: "Tên Khách Hàng",
                        content: Text(
                          style: TextStyle(fontSize: font.value),
                          order.orderContactInfo?.fullname ?? "Khách Vãng Lai",
                        ),
                      ),
                      if (contactInfo!.email != null &&
                          contactInfo.email!.isNotEmpty)
                        DetailContent(
                          title: "Email",
                          content: Text(
                            style: TextStyle(fontSize: font.value),
                            order.orderContactInfo!.email ?? "Không có email",
                          ),
                        ),
                      contactInfo.phoneNumber!.isEmpty
                          ? Container()
                          : DetailContent(
                              title: "Số Điện Thoại",
                              content: Text(
                                style: TextStyle(fontSize: font.value),
                                contactInfo.phoneNumber ??
                                    "Không có số điện thoại",
                              ),
                            ),
                      if (order.pharmacistId !=
                          appController.pharmacist.value.id)
                        DetailContent(
                          title: "Trạng Thái Thực Hiện",
                          content: Text(
                            order.actionStatus!.statusMessage!,
                            style: TextStyle(fontSize: font.value),
                          ),
                        ),
                      DetailContent(
                        title: "Ngày Tạo",
                        content: Text(
                          style: TextStyle(
                            fontSize: font.value,
                          ),
                          order.createdDate!.convertToDate,
                        ),
                      ),
                      DetailContent(
                        title: "Loại Đơn Hàng",
                        content: Text(
                          style: TextStyle(
                            fontSize: font.value,
                          ),
                          order.orderTypeName!,
                        ),
                      ),
                      DetailContent(
                        title: "Trạng Thái",
                        content: Text(
                          mapStatus.singleWhere((element) =>
                              element['id'] == order.orderStatus!)['name'],
                          style: TextStyle(
                            fontSize: font.value,
                            color: theme.primaryColor,
                          ),
                        ),
                      ),
                      // ExpansionTile(
                      //   tilePadding: EdgeInsets.zero,
                      //   title: DetailContent(
                      //     title: "Trạng Thái",
                      //     content: Text(
                      //       mapStatus.singleWhere((element) =>
                      //           element['id'] == order.orderStatus!)['name'],
                      //       style: TextStyle(
                      //         fontSize: font.value,
                      //         color: theme.primaryColor,
                      //       ),
                      //     ),
                      //   ),
                      //   children: history
                      //       .map((e) => Padding(
                      //             padding: const EdgeInsets.symmetric(
                      //                 vertical: 5, horizontal: 10),
                      //             child: Container(
                      //               padding: const EdgeInsets.symmetric(
                      //                   vertical: 8, horizontal: 8),
                      //               decoration: BoxDecoration(
                      //                 boxShadow: [
                      //                   BoxShadow(
                      //                     color: Colors.grey.withOpacity(0.5),
                      //                     spreadRadius: 1,
                      //                     blurRadius: 1,
                      //                     offset: const Offset(0,
                      //                         1), // changes position of shadow
                      //                   ),
                      //                 ],
                      //                 borderRadius: BorderRadius.circular(10),
                      //                 color: Colors.white,
                      //               ),
                      //               child: ListView(
                      //                 shrinkWrap: true,
                      //                 children: [
                      //                   Row(
                      //                     children: [
                      //                       const Text('Trạng thái'),
                      //                       const Spacer(),
                      //                       Text(e.statusName!)
                      //                     ],
                      //                   ),
                      //                   Column(
                      //                     children: [
                      //                       const Text('Mô tả'),
                      //                       Text(
                      //                         e.statusDescriptions![0]
                      //                             .description!,
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ))
                      //       .toList(),
                      // ),
                      DetailContent(
                        title: "Tổng Tiền",
                        content: Text(
                          style: TextStyle(fontSize: font.value),
                          order.totalPrice!.convertCurrentcy(),
                        ),
                      ),
                      if (order.orderTypeId == 2)
                        DetailContent(
                          title: "Ngày Đến Nhận",
                          content: Text(
                            style: TextStyle(fontSize: font.value),
                            order.orderPickUp!.datePickUp!,
                          ),
                        ),
                      if (order.orderTypeId == 2)
                        DetailContent(
                          title: "Khung Giờ Đến Nhận",
                          content: Text(
                            style: TextStyle(fontSize: font.value),
                            order.orderPickUp!.timePickUp!,
                          ),
                        ),
                      if (order.orderTypeId == 3)
                        DetailContent(
                          title: "Địa Chỉ",
                          content: Text(
                            order.orderDelivery!.fullyAddress!,
                            style: TextStyle(fontSize: font.value),
                          ),
                        ),
                      DetailContent(
                        title: "Ghi Chú",
                        content: Text(
                          style: TextStyle(fontSize: font.value),
                          order.note!.length > 1
                              ? order.note!
                              : 'Không có ghi chú',
                        ),
                      ),
                      DetailContent(
                        title: "Hình Thức Thanh Toán",
                        content: Text(
                          style: TextStyle(fontSize: font.value),
                          order.paymentMethod!,
                        ),
                      ),
                      if (order.orderProducts!.isNotEmpty)
                        DetailContent(
                          title:
                              "Danh Sách Sản phẩm: ${grouped.length} Sản phẩm",
                          content: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: grouped.length,
                            itemBuilder: (context, index) {
                              final item = grouped[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 1,
                                          offset: const Offset(0,
                                              1), // changes position of shadow
                                        ),
                                      ]),
                                  child: ListTile(
                                    onTap: () => Get.toNamed(
                                      '/product_detail',
                                      arguments:
                                          order.orderProducts![index].productId,
                                    ),
                                    title: Text(
                                      style: TextStyle(fontSize: font.value),
                                      products[index].productName!,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              AutoSizeText(
                                                "Tổng Tiền: ",
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontSize: font.value),
                                              ),
                                              Text(
                                                item
                                                    .map((e) => e.priceTotal)
                                                    .reduce((a, b) => a! + b!)!
                                                    .convertCurrentcy(),
                                                style: TextStyle(
                                                    fontSize: font.value),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Divider(),
                                        ...item.map(
                                          (e) {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize: font.value,
                                                  ),
                                                  "Số Lượng: ${e.quantity!} ${e.unitName}",
                                                ),
                                                e.productNoteFromPharmacist ==
                                                        null
                                                    ? Container()
                                                    : Text(
                                                        style: TextStyle(
                                                          fontSize: font.value,
                                                        ),
                                                        "Ghi Chú: ${e.productNoteFromPharmacist!}",
                                                      ),
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (order.pharmacistId == null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: SwipeButton.expand(
                            enabled: order.actionStatus!.canAccept!,
                            thumb: const Icon(
                              Icons.double_arrow_rounded,
                              color: Colors.white,
                            ),
                            activeThumbColor: theme.primaryColor,
                            activeTrackColor: Colors.grey[300],
                            onSwipe: () {
                              Get.toNamed('/order_confirm',
                                  arguments: order.id);
                            },
                            child: Text(
                              "Xác Nhận Đơn Hàng",
                              style: context.textTheme.headlineSmall,
                            ),
                          ),
                        ),
                      if (order.orderStatus == "9")
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          child: SwipeButton.expand(
                            thumb: const Icon(
                              Icons.double_arrow_rounded,
                              color: Colors.white,
                            ),
                            activeThumbColor: context.theme.primaryColor,
                            activeTrackColor: Colors.grey.shade300,
                            onSwipe: () async {
                              showDialog(
                                context: context,
                                builder: (context) => Center(
                                  child: LoadingWidget(
                                    size: 60,
                                  ),
                                ),
                              );
                              await appController
                                  .updateOrderStatus(
                                      orderId: order.id!, status: "4")
                                  .then((value) async {
                                await appController.triggerOrderLoad();

                                Get.back();
                                Get.back();
                              });
                            },
                            child: Text(
                              "Khách đã nhận hàng, hoàn thành đơn",
                              style: context.textTheme.titleSmall,
                            ),
                          ),
                        ),
                      if (appController.isProcessMode.isTrue &&
                          (order.orderStatus == '6' ||
                              order.orderStatus == '3' ||
                              order.orderStatus == '7'))
                        Obx(
                          () => FilledButton(
                            onPressed: () {
                              if (appController.orderProcessList
                                  .contains(order.id!)) {
                                appController.orderProcessList
                                    .remove(order.id!);
                              } else {
                                appController.orderProcessList.add(order.id!);
                              }
                            },
                            child: Text(appController.orderProcessList
                                    .contains(order.id!)
                                ? "Đã có trong danh sách xử lý, loại bỏ?"
                                : "Thêm vào đơn xử lý"),
                          ),
                        ),
                      if (order.orderStatus == '9')
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: FilledButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                              onPressed: () => dialogCancelOrder(
                                order.id!,
                              ),
                              child: const Text('Hủy Đơn Hàng'),
                            ),
                          ),
                        )
                    ],
                  );
                }),
              ),
            ),
    );
  }
}
