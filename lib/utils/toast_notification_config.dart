import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void toastificationUtils(String message,
    {ToastificationType toastType = ToastificationType.success,
    String title = 'Error',
    Color primaryColor = Colors.red,
    Color BackgroundColor = const Color.fromARGB(255, 149, 254, 153),
    bool showProgressBar = false,
    Color foregroundColor = Colors.black,
    Color TextColor = Colors.black,
    IconData icon = Icons.error}) {
  toastification.show(
    type: toastType,
    autoCloseDuration: const Duration(seconds: 3),
    title: Text(
      title,
      style: TextStyle(color: TextColor),
    ),
    description: RichText(
        text: TextSpan(text: message, style: TextStyle(color: TextColor))),
    alignment: Alignment.topRight,
    direction: TextDirection.ltr,
    animationDuration: const Duration(milliseconds: 500),
    icon: Icon(icon),
    primaryColor: primaryColor,
    backgroundColor: BackgroundColor,
    foregroundColor: foregroundColor,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    borderRadius: BorderRadius.circular(12),
    showProgressBar: showProgressBar,
    closeButtonShowType: CloseButtonShowType.onHover,
    applyBlurEffect: false,
    dragToClose: false,
    callbacks: ToastificationCallbacks(
      onDismissed: (toastItem) {
        toastification.dismissAll();
      },
    ),
  );
}
