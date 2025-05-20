import 'package:flutter/material.dart';

class AppStyles {
  static const Color backgroundColor = Colors.black54;
  static const Color textColor = Colors.white;

  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );

  static const BorderRadius borderRadius = BorderRadius.all(
    Radius.circular(12),
  );

  static const TextStyle titleTextStyle = TextStyle(
    color: textColor,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const IconThemeData iconTheme = IconThemeData(
    color: textColor,
    size: 30,
  );
}
