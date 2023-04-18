import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:pharmacy_employee/main.dart';
import 'package:pharmacy_employee/models/order_detail.dart';

class UnitCheck extends StatelessWidget {
  const UnitCheck(
      {super.key,
      required this.product,
      required this.onCheck,
      required this.value});

  final OrderProducts product;

  final Function(bool) onCheck;
  final bool value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${product.quantity} ${product.unitName} - ${product.priceTotal!.convertCurrentcy()}",
              ),
              product.productNoteFromPharmacist != null
                  ? AutoSizeText(
                      product.productNoteFromPharmacist!,
                    )
                  : Container(),
            ],
          ),
          MSHCheckbox(
            value: value,
            size: 30,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: Colors.blue,
            ),
            style: MSHCheckboxStyle.stroke,
            onChanged: onCheck,
          )
        ],
      ),
    );
  }
}
