import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackType { success, error, info, warning }

showSnack(String title, String msg, SnackType type,
    {Widget? mainBtn, Function(GetSnackBar)? onTap}) {
  Get.showSnackbar(GetSnackBar(
      onTap: onTap,
      mainButton: mainBtn,
      title: title,
      message: msg,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      backgroundColor: type == SnackType.success
          ? Colors.green
          : type == SnackType.error
              ? Colors.red
              : type == SnackType.info
                  ? Colors.blue
                  : Colors.orange,
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      icon: type == SnackType.success
          ? const Icon(Icons.check_circle, color: Colors.white)
          : type == SnackType.error
              ? const Icon(Icons.error, color: Colors.white)
              : type == SnackType.info
                  ? const Icon(Icons.info, color: Colors.white)
                  : const Icon(Icons.warning, color: Colors.white)));
}
