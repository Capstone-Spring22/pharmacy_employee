import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pharmacy_employee/constant/controller.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacist'),
        actions: [
          IconButton(
              onPressed: () => appController.logout(),
              icon: const Icon(Icons.logout))
        ],
      ),
      body: SingleChildScrollView(
        child: Obx(
          () => Column(
            children: [
              CupertinoListTile(
                  title: Text("Font chữ",
                      style: TextStyle(fontSize: appController.fontSize.value)),
                  trailing: Row(
                    children: [
                      IconButton(
                          onPressed: () => appController.decreaseFontSize(),
                          icon: const Icon(Icons.remove)),
                      Text(appController.fontSize.value.toString()),
                      IconButton(
                          onPressed: () => appController.increaseFontSize(),
                          icon: const Icon(Icons.add)),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
