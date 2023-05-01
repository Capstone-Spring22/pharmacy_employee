import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
import 'package:pharmacy_employee/helpers/loading.dart';
import 'package:pharmacy_employee/service/app_service.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacist'),
        actions: [
          IconButton(
            onPressed: () => appController.logout(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          FutureBuilder(
              future: AppService().fetchDetailPharmacist(
                appController.pharmacist.value.token!,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingWidget(),
                  );
                }
                final detailPharmacist = snapshot.data;
                Get.log(detailPharmacist.toString());
                return Obx(() {
                  final font = appController.fontSize;
                  return Column(
                    children: [
                      DetailContent(
                        title: "Mã Nhân Viên",
                        haveDivider: false,
                        content: Text(
                          detailPharmacist!.code!,
                          style: TextStyle(fontSize: font.value),
                        ),
                      ),
                      DetailContent(
                        title: "Tên dược sĩ",
                        haveDivider: false,
                        content: Text(
                          appController.pharmacist.value.name!,
                          style: TextStyle(fontSize: font.value),
                        ),
                      ),
                      DetailContent(
                        title: "Điện thoại",
                        haveDivider: false,
                        content: Text(
                          detailPharmacist.phoneNo!,
                          style: TextStyle(fontSize: font.value),
                        ),
                      ),
                      DetailContent(
                        title: "Mail",
                        haveDivider: false,
                        content: Text(
                          detailPharmacist.email!,
                          style: TextStyle(fontSize: font.value),
                        ),
                      ),
                      CupertinoListTile(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        title: Text("Cỡ chữ",
                            style: TextStyle(fontSize: font.value)),
                        trailing: Row(
                          children: [
                            IconButton(
                              onPressed: () => appController.decreaseFontSize(),
                              icon: const Icon(Icons.remove),
                            ),
                            Text(appController.fontSize.value.toString()),
                            IconButton(
                              onPressed: () => appController.increaseFontSize(),
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                });
              }),
        ],
      )),
    );
  }
}
