import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/controller/app_controller.dart';
import 'package:pharmacy_employee/helpers/input.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
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
        if (appController.haveNext.isTrue) {
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
      appBar: AppBar(
        title: Input(
          inputController: appController.searchController,
          title: "Search",
          focus: focusNode,
          onChanged: (v) => debouncer(() {
            searchTerm = v;
            appController.initLookup(v, 1);
          }),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.barcode_reader),
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
          ),
        ],
      ),
      body: GetX<AppController>(
        builder: (controller) {
          if (controller.isSearching.isTrue) {
            return Center(
              child: LoadingWidget(
                size: 60,
              ),
            );
          } else if (controller.list.isEmpty) {
            return const Center(
              child: Text("No Product Found"),
            );
          } else {
            return ListView.builder(
              shrinkWrap: true,
              controller: scrollController,
              itemCount: controller.list.length,
              itemBuilder: (context, index) {
                final item = controller.list[index];
                // item.
                return ListTile(
                  onTap: () => appController.toProductDetail(item.id!),
                  leading: CachedNetworkImage(
                    imageUrl: item.imageModel!.imageURL!,
                    height: 100,
                    width: 50,
                    placeholder: (context, url) => Center(
                      child: LoadingWidget(),
                    ),
                  ),
                  title: AutoSizeText(item.name!),
                  subtitle: Text(item.price.toString()),
                );
              },
            );
          }
        },
      ),
    );
  }
}
