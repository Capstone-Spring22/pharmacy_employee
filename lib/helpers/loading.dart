// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({this.size = 30, this.color, super.key});
  double size;
  Color? color;

  @override
  Widget build(BuildContext context) {
    color = color ?? context.theme.primaryColor;
    return LoadingAnimationWidget.dotsTriangle(color: color!, size: size);
  }
}
