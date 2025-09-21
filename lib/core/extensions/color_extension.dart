import 'package:flutter/material.dart';

/// Extension for parsing color strings to Color objects
extension ColorExtension on String {
  /// Parses a hex color string to a Color object
  /// Returns Colors.grey if parsing fails
  Color parseColor() {
    try {
      return Color(int.parse(replaceFirst('#', '0xff')));
    } catch (e) {
      return Colors.grey;
    }
  }
}
