import 'package:flutter/material.dart';
import 'package:pharmacy_employee/models/order_detail.dart';

class PrepOrder extends StatelessWidget {
  const PrepOrder({super.key, required this.order});

  final OrderHistoryDetail order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
