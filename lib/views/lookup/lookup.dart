import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';
import 'package:pharmacy_employee/helpers/input.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class ProductLookup extends StatefulWidget {
  const ProductLookup({super.key});

  @override
  State<ProductLookup> createState() => _ProductLookupState();
}

class _ProductLookupState extends State<ProductLookup> {
  final focusNode = FocusNode();
  int currentIndex = 1;
  String searchTerm = "";
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    appController.searchController.text = "";
    super.initState();
    reqFocus();
    appController.initLookup("", 1);
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (appController.productHaveNext.isTrue) {
          currentIndex++;
          appController.initLookup(searchTerm, currentIndex);
        }
      }
    });
  }

  void reqFocus() async {
    await Future.delayed(const Duration(milliseconds: 50));
    focusNode.requestFocus();
  }

  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  Widget build(BuildContext context) {
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
                searchTerm = res;
                appController.searchController.text = res;
                appController.initLookup(res, 1);
              }
            }
          });
        },
        child: const Icon(Icons.barcode_reader),
      ),
      appBar: AppBar(
        title: Input(
          inputController: appController.searchController,
          title: "Tìm",
          focus: focusNode,
          onChanged: (v) => debouncer(() {
            searchTerm = v;
            appController.initLookup(v, 1);
          }),
        ),
        actions: const [],
      ),
      body: GetX<AppController>(
        builder: (controller) {
          if (controller.isLoading.isTrue && controller.productList.isEmpty) {
            return Center(
              child: LoadingWidget(
                size: 60,
              ),
            );
          } else if (controller.isLoading.isFalse &&
              controller.productList.isEmpty) {
            return const Center(
              child: Text("Không Tìm Thấy Sản Phẩm Nào"),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: controller.productList.length + 1,
              itemBuilder: (context, index) {
                if (index < controller.productList.length) {
                  final item = controller.productList[index];
                  // item.
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        onTap: () => appController.toProductDetail(item.id!),
                        leading: CachedNetworkImage(
                          imageUrl: item.imageModel!.imageURL!,
                          height: 100,
                          width: 50,
                          placeholder: (context, url) => Center(
                            child: LoadingWidget(),
                          ),
                        ),
                        title: AutoSizeText(
                          item.name!,
                          style: TextStyle(
                            fontSize: appController.fontSize.value,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: item.productUnitReferences!
                              .map(
                                (e) => Text(
                                  "${e.price != e.priceAfterDiscount ? "Giá giảm ${e.priceAfterDiscount!.convertCurrentcy()} - " : ''}${e.price!.convertCurrentcy()} / ${e.unitName}",
                                  style: TextStyle(
                                    fontSize: appController.fontSize.value,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  );
                } else if (controller.isLoading.isTrue) {
                  return LoadingWidget();
                } else {
                  return const SizedBox();
                }
              },
            );
          }
        },
      ),
    );
  }
}
