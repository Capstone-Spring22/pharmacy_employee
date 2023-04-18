import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:restart_app/restart_app.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const ErrorScreen({super.key, required this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: Container(
              height: Get.height * .8,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset('assets/lottie/error.json'),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Oops! Something went wrong.',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    errorDetails.summary.toString(),
                    style: const TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  FilledButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Quay lại'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Restart.restartApp();
                    },
                    child: const Text('Khởi động lại ứng dụng'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
