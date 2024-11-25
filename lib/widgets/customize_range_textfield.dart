import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TextFieldType { price, percentage }

class RangeTextField<T extends num> extends StatefulWidget {
  final T initialValue;
  final T minValue;
  final T maxValue;
  final Function(T) onChanged;
  final double height;
  final double width;
  final double iconsize;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final TextFieldType fieldType;

  const RangeTextField({
    Key? key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    this.iconsize = 14,
    this.height = 40.0,
    this.width = 120.0,
    this.textStyle,
    this.padding,
    required this.fieldType, // Added required fieldType parameter
  }) : super(key: key);

  @override
  RangeTextFieldState<T> createState() => RangeTextFieldState<T>();
}

class RangeTextFieldState<T extends num> extends State<RangeTextField<T>> {
  late TextEditingController _controller;
  late T _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    _controller = TextEditingController(text: formatValue(widget.initialValue));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatValue(T value) {
    if (widget.fieldType == TextFieldType.price) {
      // Format value with $ sign and fixed decimal places for price
      return '\$${value.toStringAsFixed(2)}';
    } else if (widget.fieldType == TextFieldType.percentage) {
      // Format value with $ sign and no decimal places for percentage
      return '%${value.toString()}';
    } else {
      // Default fallback format
      return '$value';
    }
  }

  void _increment() {
    if (_currentValue < widget.maxValue) {
      setState(() {
        _currentValue = (_currentValue + 1) as T;
        _controller.text = formatValue(_currentValue);
        widget.onChanged(_currentValue);
      });
    }
  }

  void _decrement() {
    if (_currentValue > widget.minValue) {
      setState(() {
        _currentValue = (_currentValue - 1) as T;
        _controller.text = formatValue(_currentValue);
        widget.onChanged(_currentValue);
      });
    }
  }

  void _updateText(String value) {
    // Remove $ or % sign for processing
    String cleanValue = value.replaceAll('\$', '').replaceAll('%', '');

    // Determine parsing logic based on field type
    num? newValue;
    if (widget.fieldType == TextFieldType.price) {
      newValue = num.tryParse(cleanValue);
    } else if (widget.fieldType == TextFieldType.percentage) {
      newValue = num.tryParse(cleanValue);
      if (newValue != null) {
        newValue /= 100; // Convert percentage to decimal
      }
    }

    // Validate against minValue and maxValue
    if (newValue != null &&
        newValue >= widget.minValue &&
        newValue <= widget.maxValue) {
      setState(() {
        _currentValue = newValue as T;
        widget.onChanged(_currentValue);
      });
    } else {
      // Restore previous valid value within range
      if (newValue != null && newValue > widget.maxValue) {
        _controller.text = formatValue(widget.maxValue);
      } else {
        _controller.text = formatValue(_currentValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              widget.fieldType == TextFieldType.percentage ? LengthLimitingTextInputFormatter(3): LengthLimitingTextInputFormatter(10),
              widget.fieldType == TextFieldType.price
                  ? FilteringTextInputFormatter.allow(
                      RegExp(r'^\$?\d*\.?\d{0,2}$'),
                    )
                  : FilteringTextInputFormatter.digitsOnly
            ],
            style: widget.textStyle,
            decoration: InputDecoration(
              prefixIcon: IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _decrement,
                padding: EdgeInsets.zero,
                iconSize: widget.iconsize,
                constraints: const BoxConstraints(),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _increment,
                padding: EdgeInsets.zero,
                iconSize: widget.iconsize,
                constraints: const BoxConstraints(),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.green, width: 1.0),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.green, width: 1.0),
              ),
              contentPadding: widget.padding ??
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            ),
            onChanged: _updateText,
            onTap: () {
              if (_controller.text == formatValue(widget.initialValue)) {
                _controller.clear();
              }
            },
          ),
        ),
      ],
    );
  }
}
