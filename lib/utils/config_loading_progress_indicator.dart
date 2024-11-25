import 'package:flutter/material.dart';
import 'package:colorful_circular_progress_indicator/colorful_circular_progress_indicator.dart';

Widget configloadingProgressIndicator() {
  return const Center(
      child: ColorfulCircularProgressIndicator(
    colors: [Colors.blue, Colors.red, Colors.amber, Colors.green],
    strokeWidth: 2,
    indicatorHeight: 40,
    indicatorWidth: 40,
  ));
}
