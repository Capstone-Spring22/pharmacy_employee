import 'package:flutter/material.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';

class OrderDetail extends StatefulWidget {
  const OrderDetail({super.key});

  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final String id = Get.arguments;
  late final OrderHistoryDetail order;
  bool isFetch = true;
  List<Map<String, dynamic>> mapStatus = [];

  _fetchOrderDetail() async {
    try {
      order = (await AppService().fetchOrderDetail(id))!;

      await AppService().fetchOrderStatus(order.orderTypeId!).then((value) {
        for (final i in value) {
          mapStatus
              .add({"id": i['orderStatusId'], "name": i['orderStatusName']});
        }
      });
      setState(() {
        isFetch = false;
      });
    } catch (e) {
      Get.log(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(id),
      ),
      body: isFetch
          ? Center(
              child: LoadingWidget(
                size: 60,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DetailContent(
                      title: "Tên Khách Hàng",
                      content: Text(
                        style:
                            TextStyle(fontSize: appController.fontSize.value),
                        order.orderContactInfo!.fullname ?? "Khách Vãng Lai",
                      ),
                    ),
                    if (order.orderContactInfo!.email != null &&
                        order.orderContactInfo!.email!.isNotEmpty)
                      DetailContent(
                        title: "Email",
                        content: Text(
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                          order.orderContactInfo!.email ?? "Không có email",
                        ),
                      ),
                    DetailContent(
                      title: "Số Điện Thoại",
                      content: Text(
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                          order.orderContactInfo!.phoneNumber ??
                              "Không có số điện thoại"),
                    ),
                    if (order.pharmacistId != appController.pharmacist.value.id)
                      DetailContent(
                        title: "Trạng Thái Thực Hiện",
                        content: Text(
                          order.actionStatus!.statusMessage!,
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                        ),
                      ),
                    DetailContent(
                        title: "Ngày Tạo",
                        content: Text(
                            style: TextStyle(
                                fontSize: appController.fontSize.value),
                            order.createdDate!.convertToDate)),
                    DetailContent(
                        title: "Loại Đơn Hàng",
                        content: Text(
                            style: TextStyle(
                                fontSize: appController.fontSize.value),
                            order.orderTypeName!)),
                    DetailContent(
                      title: "Trạng Thái",
                      content: Text(
                        mapStatus.singleWhere((element) =>
                            element['id'] == order.orderStatus!)['name'],
                        style: TextStyle(
                          fontSize: appController.fontSize.value,
                          color: context.theme.primaryColor,
                        ),
                      ),
                    ),
                    DetailContent(
                      title: "Tổng Tiền",
                      content: Text(
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                          order.totalPrice!.convertCurrentcy()),
                    ),
                    if (order.orderTypeId == 2)
                      DetailContent(
                        title: "Ngày Đến Nhận",
                        content: Text(
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                          order.orderPickUp!.datePickUp!,
                        ),
                      ),
                    if (order.orderTypeId == 2)
                      DetailContent(
                        title: "Khung Giờ Đến Nhận",
                        content: Text(
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                          order.orderPickUp!.timePickUp!,
                        ),
                      ),
                    if (order.orderTypeId == 3)
                      DetailContent(
                        title: "Địa Chỉ",
                        content: Text(
                          order.orderDelivery!.fullyAddress!,
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                        ),
                      ),
                    DetailContent(
                      title: "Ghi Chú",
                      content: Text(
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                          order.note!.length > 1
                              ? order.note!
                              : 'Không có ghi chú'),
                    ),
                    DetailContent(
                      title: "Hình Thức Thanh Toán",
                      content: Text(
                          style:
                              TextStyle(fontSize: appController.fontSize.value),
                          order.paymentMethod!),
                    ),
                    if (order.orderProducts!.isNotEmpty)
                      DetailContent(
                        title:
                            "Danh Sách Sản phẩm: ${order.orderProducts!.length} Sản phẩm",
                        content: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: order.orderProducts!.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () => Get.toNamed(
                                '/product_detail',
                                arguments:
                                    order.orderProducts![index].productId,
                              ),
                              title: Text(
                                  style: TextStyle(
                                      fontSize: appController.fontSize.value),
                                  order.orderProducts![index].productName!),
                              subtitle: Text(
                                style: TextStyle(
                                    fontSize: appController.fontSize.value),
                                "Số Lượng: ${order.orderProducts![index].quantity!} ${order.orderProducts![index].unitName}",
                              ),
                              trailing: Text(
                                style: TextStyle(
                                    fontSize: appController.fontSize.value),
                                order.orderProducts![index].priceTotal!
                                    .convertCurrentcy(),
                              ),
                            );
                          },
                        ),
                      ),
                    // if (order.orderStatus == '6')
                    //   FilledButton(
                    //       onPressed: () {}, child: const Text("Chuẩn bị hàng")),
                    if (order.pharmacistId == null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: SwipeButton.expand(
                          enabled: order.actionStatus!.canAccept!,
                          thumb: const Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.white,
                          ),
                          activeThumbColor: context.theme.primaryColor,
                          activeTrackColor: Colors.grey.shade300,
                          onSwipe: () {
                            Get.toNamed('/order_confirm', arguments: order.id);
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
                  ],
                ),
              ),
            ),
    );
  }
}
