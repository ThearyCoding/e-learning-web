import 'package:flutter/material.dart';

class StatusContainer extends StatelessWidget {
  final bool? status;

  const StatusContainer({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color containerColor;
    Color textColor;
    Color iconColor;

    if (status == true) {
      statusText = 'Active';
      containerColor = Colors.greenAccent;
      textColor = Colors.green;
      iconColor = Colors.green;
    } else if (status == false) {
      statusText = 'Pending';
      containerColor = Colors.yellowAccent;
      textColor = Colors.orange;
      iconColor = Colors.orange;
    } else {
      statusText = 'Unknown';
      containerColor = Colors.grey[400]!;
      textColor = Colors.black;
      iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: containerColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 12,
            color: iconColor,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}