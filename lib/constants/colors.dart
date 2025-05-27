import 'package:flutter/material.dart';

class AppColors {
  // Background Gradients
  static const List<Color> lightOnGradient = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F3460),
  ];

  static const List<Color> lightOffGradient = [
    Color(0xFF0A0A0A),
    Color(0xFF1A1A1A),
    Color(0xFF2A2A2A),
  ];

  // Primary Colors
  static const Color primaryBlue = Colors.blue;
  static const Color primaryWhite = Colors.white;
  static const Color primaryGreen = Colors.green;
  static const Color primaryRed = Colors.red;
  static const Color primaryYellow = Colors.yellow;

  // Opacity Colors
  static Color whiteOpacity10 = Colors.white.withOpacity(0.1);
  static Color whiteOpacity20 = Colors.white.withOpacity(0.2);
  static Color whiteOpacity30 = Colors.white.withOpacity(0.3);
  static Color whiteOpacity50 = Colors.white.withOpacity(0.5);
  static Color whiteOpacity70 = Colors.white.withOpacity(0.7);
  static Color whiteOpacity80 = Colors.white.withOpacity(0.8);
  static Color whiteOpacity05 = Colors.white.withOpacity(0.05);

  // Specific Use Colors
  static Color blueOpacity30 = Colors.blue.withOpacity(0.3);
}
