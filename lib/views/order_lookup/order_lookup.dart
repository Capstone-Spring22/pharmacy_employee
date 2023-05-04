// ignore_for_file: prefer_final_fields

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/input.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class OrderLookUpScreen extends StatefulWidget {
  const OrderLookUpScreen({super.key});

  @override
  State<OrderLookUpScreen> createState() => _OrderLookUpScreenState();
}

class _OrderLookUpScreenState extends State<OrderLookUpScreen> {
  final TextEditingController _txtSearch = TextEditingController();
  ScrollController pageScrollController = ScrollController();
  List<OrderHistory> orderList = [];

  bool _isLoading = false;
  bool _isLoadMore = false;
  bool _isSearch = false;
  bool _haveNext = false;

  bool _notAccepted = false;
  bool _showOnlyPharmacist = false;
  bool _isCompleted = false;
  int _page = 1;

  final debouncer = Debouncer(delay: 300.ms);

  @override
  void initState() {
    _fetchList();
    super.initState();
    pageScrollController.addListener(() {
      if (pageScrollController.position.pixels ==
          pageScrollController.position.maxScrollExtent) {
        if (_haveNext) {
          Get.log("FETCH MORE");
          _page++;
          _fetchList();
        }
      }
    });
  }

  Future _fetchList() async {
    if (_page > 1) {
      setState(() {
        _isLoadMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }
    List<OrderHistory> tempList = [];

    _haveNext ? _page++ : _page = 1;
    Map<String, dynamic>? res;
    if (_txtSearch.text.isEmpty) {
      res = await AppService().orderLookup('', _page, _isCompleted);
    } else {
      res =
          await AppService().orderLookup(_txtSearch.text, _page, _isCompleted);
    }
    if (res != null) {
      _haveNext = res['hasNextPage'];
      for (final item in res['items']) {
        final order = OrderHistory.fromJson(item);
        tempList.add(order);
      }
    }

    if (_page > 1) {
      orderList.addAll(tempList);
    } else {
      orderList = tempList;
    }

    if (_page > 1) {
      setState(() {
        _isLoadMore = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String dateRender = "";
    final fontSize = appController.fontSize;
    final theme = context.theme;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var res = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SimpleBarcodeScannerPage(),
              ));
          setState(() {
            if (res is String) {
              if (res != "-1") {
                Get.toNamed('/order_detail', arguments: res);
              }
            }
          });
        },
        child: const Icon(Icons.barcode_reader),
      ),
      appBar: AppBar(
        toolbarHeight: 60,
        actions: [
          SizedBox(
            width: Get.width * .9,
            child: Input(
              clearBtn: () {
                setState(() {
                  _txtSearch.clear();
                  orderList.clear();
                });
              },
              inputController: _txtSearch,
              onChanged: (p0) {
                if (p0.isNotEmpty) {
                  debouncer.cancel();
                  debouncer.call(() {
                    _fetchList();
                  });
                } else {
                  setState(() {
                    orderList.clear();
                  });
                }
              },
              hint: 'Nhập mã đơn hàng hoặc số điện thoại',
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: LoadingWidget(
                size: 60,
              ),
            )
          : orderList.isEmpty
              ? const Center(
                  child: Text('Nhập thông tin để tìm kiếm'),
                )
              : ListView.builder(
                  controller: pageScrollController,
                  itemCount: orderList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == orderList.length) {
                      return _isLoadMore && _haveNext
                          ? Center(
                              child: LoadingWidget(),
                            )
                          : const SizedBox();
                    }
                    final item = orderList[index];
                    bool dif = dateRender == item.createdDate!.convertToDate;
                    if (!dif) {
                      dateRender = item.createdDate!.convertToDate;
                    }
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed('/order_detail', arguments: item.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                            Container(
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
                                color: appController.isProcessMode.isTrue
                                    ? appController.orderProcessList
                                            .contains(item.id)
                                        ? theme.secondaryHeaderColor
                                        : Colors.white
                                    : Colors.white,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
