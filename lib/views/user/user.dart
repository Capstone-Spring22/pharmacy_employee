import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';
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
        child: Obx(
          () {
            final font = appController.fontSize;
            return Column(
              children: [
                DetailContent(
                  title: "Tên dược sĩ",
                  haveDivider: false,
                  content: Text(
                    appController.pharmacist.value.name!,
                    style: TextStyle(fontSize: font.value),
                  ),
                ),
                // DetailContent(
                //   title: "Số điện thoại",
                //   haveDivider: false,
                //   content: Text(
                //     appController.pharmacist.value.!,
                //     style: TextStyle(fontSize: appController.fontSize.value),
                //   ),
                // ),
                CupertinoListTile(
                  title:
                      Text("Font chữ", style: TextStyle(fontSize: font.value)),
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
          },
        ),
      ),
    );
  }
}
