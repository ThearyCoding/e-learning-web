import 'package:flutter/material.dart';

import '../utils/responsive_layout.dart';

// ignore: must_be_immutable
class CustomizTextFormFieldV1 extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final bool autoFocus;
  String? Function(String?)? validator;
  CustomizTextFormFieldV1({
    super.key,
    required this.controller,
     this.labelText,
     this.hintText,
     this.autoFocus = false,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.isDesktop(context) ? 50 : 20),
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: null,
        autofocus: autoFocus,
        style: TextStyle(
            fontSize: ResponsiveLayout.fontSize(context, 16.0),
            color: Colors.black),
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.green, width: 1.0)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.green, width: 1.0)),
          contentPadding: EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: ResponsiveLayout.isDesktop(context) ? 15.0 : 10.0),
          labelText: labelText,
          hintText: hintText,
          labelStyle: TextStyle(
              fontSize: ResponsiveLayout.fontSize(context, 18.0),
              color: Colors.grey),
        ),
      ),
    );
  }
}
