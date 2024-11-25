import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtils {
  static void showCustomSnackbar({
    required String title,
    required String message,
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    Color backgroundColor = Colors.black,
    Color textColor = Colors.white,
    Duration duration = const Duration(seconds: 3),
    SnackStyle snackStyle = SnackStyle.FLOATING,
    IconData? icon,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      backgroundColor: backgroundColor,
      colorText: textColor,
      duration: duration,
      snackStyle: snackStyle,
      icon: icon != null ? Icon(icon, color: textColor) : null,
      margin: const EdgeInsets.all(8.0),
      borderRadius: 8.0,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}
