import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pharmacy_employee/models/map/waypoint.dart';
import 'package:pharmacy_employee/models/order_detail.dart';

List<OrderHistoryDetail> rearrangeList(
  List<OrderHistoryDetail?> listA,
  List<Waypoint> listB,
) {
  List<OrderHistoryDetail> rearrangedList = [];
  listB.removeAt(0);
  for (int i = 1; i < listA.length + 1; i++) {
    innerloop:
    for (int x = 0; x < listB.length; x++) {
      if (listB[x].waypointIndex == i) {
        rearrangedList.add(listA[x]!);
        break innerloop;
      }
    }
  }

  return rearrangedList;
}

List<Location> rearrangeLocationList(
    List<Location> listA, List<Waypoint> listB) {
  List<Location> rearrangedList = [];
  listB.removeAt(0);
  for (int i = 1; i < listA.length + 1; i++) {
    innerloop:
    for (int x = 0; x < listB.length; x++) {
      if (listB[x].waypointIndex == i) {
        rearrangedList.add(listA[x]);
        break innerloop;
      }
    }
  }

  return rearrangedList;
}

List<Color> genColorList(int count) {
  List<Color> colorList = [];
  while (colorList.length < count) {
    Color color = getRandomBrightColor();
    if (!colorList.contains(color)) {
      colorList.add(color);
    }
  }
  return colorList;
}

Color getRandomBrightColor() {
  // Define a list of common bright colors
  List<Color> brightColors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.pink,
    Colors.purple,
    Colors.teal,
    Colors.cyan,
  ];

  // Randomly select a color from the list
  Color randomColor = brightColors[Random().nextInt(brightColors.length)];

  return randomColor;
}
