import 'package:flutter/material.dart';
export 'style.dart';

class AppStyles {
  static const Color backgroundColor = Colors.black54;
  static const Color textColor = Colors.white;
  static const Color backgroundPrediction = Colors.white;
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

/// Styl dla całej karty rośliny
final BoxDecoration plantCardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      offset: Offset(0, 2),
      blurRadius: 6,
    ),
  ],
);

/// Styl dla nagłówków (kluczy)
final TextStyle keyTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  color: Color(0xFF2A7D2E), // zielony
  fontSize: 16,
);

/// Styl dla wartości tekstowych
final TextStyle valueTextStyle = TextStyle(fontSize: 16, color: Colors.black87);

/// Styl dla elementów listy (np. subkluczy)
final TextStyle listItemTextStyle = TextStyle(
  fontSize: 15,
  color: Colors.black87,
);

final Map<String, String> iconMap = {
  'watering': 'fa-tint',
  'sunlight': 'fa-sun',
  'fertilizing': 'fa-leaf',
  'soil': 'fa-seedling',
  'temperature': 'fa-thermometer-half',
  'humidity': 'fa-water',
  'ph': 'fa-vial',
};
