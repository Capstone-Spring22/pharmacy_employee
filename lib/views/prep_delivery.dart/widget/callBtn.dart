import 'package:flutter/material.dart';
import 'package:pharmacy_employee/views/order_detail/widget/content_info.dart';

import '../../../models/order_detail.dart';

class CallButton extends StatelessWidget {
  const CallButton({
    super.key,
    required this.orders,
    required this.i,
  });

  final List<OrderHistoryDetail?> orders;
  final int i;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DetailContent(
            title: 'Số điện thoại',
            content: Text(orders[i]!.orderContactInfo!.phoneNumber!),
            haveDivider: false,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 20),
          child: CircleAvatar(
            child: Icon(Icons.call),
          ),
        )
      ],
    );
  }
}
