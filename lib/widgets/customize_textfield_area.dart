import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/responsive_layout.dart';

class ResizableTextField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final double minHeight;
  final double maxHeight;
  final double minWidth;
  final double maxWidth;
  final EdgeInsets? padding;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autoFocus;

  const ResizableTextField({
    Key? key,
    this.labelText,
    this.hintText,
    this.minHeight = 200,
    this.maxHeight = double.infinity,
    this.minWidth = 100,
    this.maxWidth = double.infinity,
    this.padding,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  ResizableTextFieldState createState() => ResizableTextFieldState();
}

class ResizableTextFieldState extends State<ResizableTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: widget.minHeight,
        maxHeight: widget.maxHeight,
        minWidth: widget.minWidth,
        maxWidth: widget.maxWidth,
      ),
      child: TextField(
        controller: widget.controller,
        maxLines: null,
        expands: true,
        selectionHeightStyle: BoxHeightStyle.strut,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
               labelStyle: TextStyle(
              fontSize: ResponsiveLayout.fontSize(context, 18.0),
              color: Colors.grey),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.green, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          contentPadding:
              widget.padding ?? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          labelText: widget.labelText,
          hintText: widget.hintText,
          alignLabelWithHint: true,
        ),
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        autofocus: widget.autoFocus,
      ),
    );
  }
}
