import 'package:flutter/material.dart';

class CustomDropdownFormField<T> extends StatefulWidget {
  final T? selectedValue;
  final List<T> fetchedItems;
  final Function(T?) onChanged;
  final String Function(T) itemLabel;

  const CustomDropdownFormField({
    Key? key,
    required this.selectedValue,
    required this.fetchedItems,
    required this.onChanged,
    required this.itemLabel,
  }) : super(key: key);

  @override
  CustomDropdownFormFieldState<T> createState() => CustomDropdownFormFieldState<T>();
}

class CustomDropdownFormFieldState<T> extends State<CustomDropdownFormField<T>> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth > 600 ? 15.0 : 14.0;
        double paddingHorizontal = constraints.maxWidth > 600 ? 20.0 : 10.0;
        double paddingVertical = constraints.maxWidth > 600 ? 10.0 : 5.0;

        return Container(
          padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: paddingVertical),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(color: Colors.green),
          ),
          child: DropdownButtonFormField<T>(
            value: widget.selectedValue,
            onChanged: widget.onChanged,
            items: widget.fetchedItems.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  widget.itemLabel(item),
                  style: TextStyle(fontSize: fontSize),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return widget.fetchedItems.map((item) {
                return Text(
                  widget.itemLabel(item),
                  style: TextStyle(fontSize: fontSize),
                  overflow: TextOverflow.ellipsis,
                );
              }).toList();
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Select Item',
              labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
            ),
            icon: Icon(Icons.arrow_drop_down, size: fontSize),
            isExpanded: true,
          ),
        );
      },
    );
  }
}
