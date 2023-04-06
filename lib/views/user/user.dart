import 'package:flutter/material.dart';
import 'package:pharmacy_employee/constant/controller.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacist'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FilledButton(
              onPressed: () => appController.logout(),
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}
