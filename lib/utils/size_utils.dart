import 'package:flutter/material.dart';

class SizeUtils {
  static Map<String, dynamic> getCrossAxisCountAndChildAspectRatio(
      BuildContext context, double maxWidth) {
    int crossAxisCount;
    double childAspectRatio;

    if (maxWidth < 480) {
      crossAxisCount = 1; // Smallest Mobile view
      childAspectRatio = 1.0;
      debugPrint('Size of 480: $maxWidth');
    } else if (maxWidth < 600) {
      crossAxisCount = 2; // Small Mobile view
      childAspectRatio = 1.3;
      debugPrint('Size of 600: $maxWidth');
    } else if (maxWidth < 800) {
      crossAxisCount = 2; // Tablet view
      childAspectRatio = 1.2;
      debugPrint('Size of 800: $maxWidth');
    } else if (maxWidth >= 800 && maxWidth < 900) {
      crossAxisCount = 3; // Small Desktop view
      childAspectRatio = 1;
      debugPrint('Size of 800-900: $maxWidth');
    } else if (maxWidth >= 900 && maxWidth < 1000) {
      crossAxisCount = 3; // Small Desktop view
      childAspectRatio = 1.2;
      debugPrint('Size of 900-1000: $maxWidth');
    } else if (maxWidth >= 1000 && maxWidth < 1100) {
      crossAxisCount = 4; // Medium Desktop view
      childAspectRatio = 1;
      debugPrint('Size of 1000-1100: $maxWidth');
    } else if (maxWidth >= 1100 && maxWidth < 1200) {
      crossAxisCount = 4; // Medium-Large Desktop view
      childAspectRatio = 1.1;
      debugPrint('Size of 1100-1200: $maxWidth');
    } else if (maxWidth >= 1200 && maxWidth < 1300) {
      crossAxisCount = 4; // Large Desktop view
      childAspectRatio = 1.2;
      debugPrint('Size of 1200-1300: $maxWidth');
    } else if (maxWidth >= 1300 && maxWidth < 1400) {
      crossAxisCount = 4; // Extra Large Desktop view
      childAspectRatio = 1.3;
      debugPrint('Size of 1300-1400: $maxWidth');
    } else if (maxWidth >= 1400 && maxWidth < 1500) {
      crossAxisCount = 5; // Ultra Large Desktop view
      childAspectRatio = 1.1;
      debugPrint('Size of 1400-1500: $maxWidth');
    } else if (maxWidth >= 1500 && maxWidth < 1600) {
      crossAxisCount = 5; // Extra Ultra Large Desktop view
      childAspectRatio = 1.2;
      debugPrint('Size of 1500-1600: $maxWidth');
    } else if (maxWidth >= 1600 && maxWidth < 1700) {
      crossAxisCount = 5; // Very Large Desktop view
      childAspectRatio = 1.2;
      debugPrint('Size of 1600-1700: $maxWidth');
    } else {
      crossAxisCount = 6; // Ultra Large Desktop view
      childAspectRatio = 1.0;
      debugPrint('Size of else: $maxWidth');
    }

    return {
      'crossAxisCount': crossAxisCount,
      'childAspectRatio': childAspectRatio,
    };
  }
}
