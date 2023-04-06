// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({this.size = 30, super.key});
  double size;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.dotsTriangle(
        color: context.theme.primaryColor, size: size);
  }
}
