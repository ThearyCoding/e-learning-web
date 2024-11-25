import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';

class DropdownField<T> extends StatefulWidget {
  final String hintText;
  final T? initialItem;
  final ValueChanged<T?> onChanged;
  final List<T> items;
  final Widget Function(BuildContext, T, bool, void Function()) listItemBuilder;

  const DropdownField({
    required this.hintText,
    this.initialItem,
    required this.onChanged,
    required this.items,
    required this.listItemBuilder,
    Key? key,
  }) : super(key: key);

  @override
  _DropdownFieldState<T> createState() => _DropdownFieldState<T>();
}

class _DropdownFieldState<T> extends State<DropdownField<T>> {
  @override
  Widget build(BuildContext context) {
    return CustomDropdown<T>(
      hintText: widget.hintText,
      initialItem: widget.initialItem,
      items: widget.items,
      onChanged: widget.onChanged,
      listItemBuilder: widget.listItemBuilder,
      overlayHeight: 200,
      closedHeaderPadding: const EdgeInsets.all(8.0),
      expandedHeaderPadding: const EdgeInsets.all(8.0),
      itemsListPadding: const EdgeInsets.symmetric(vertical: 8.0),
      listItemPadding: const EdgeInsets.all(8.0),
    );
  }
}
