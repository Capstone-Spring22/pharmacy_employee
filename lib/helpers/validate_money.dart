import 'package:flutter/material.dart';
import 'package:get/get.dart';

showValidateMoneyChange() {
  return showModalBottomSheet(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        title: const Text('Validate Money Change'),
        content: const Text('Please validate money change'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
