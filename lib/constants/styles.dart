import 'package:flutter/material.dart';
import 'colors.dart';

class AppStyles {
  // Text Styles
  static const TextStyle headerTitle = TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle roomTitle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static TextStyle roomSubtitle = TextStyle(
    color: AppColors.whiteOpacity70,
    fontSize: 14,
  );

  static const TextStyle statusText = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle lightSelectorText = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle timerModeText = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static TextStyle timerLabel = TextStyle(
    color: AppColors.whiteOpacity80,
    fontSize: 16,
  );

  static TextStyle timerSubLabel = TextStyle(
    color: AppColors.whiteOpacity70,
    fontSize: 14,
  );

  static const TextStyle timerDisplay = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle timerSeparator = TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle buttonText = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle quickTimerText = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Container Decorations
  static BoxDecoration glassmorphicContainer = BoxDecoration(
    color: AppColors.whiteOpacity10,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.whiteOpacity20,
      width: 1,
    ),
  );

  static BoxDecoration controlPanelDecoration = BoxDecoration(
    color: AppColors.whiteOpacity10,
    borderRadius: BorderRadius.circular(25),
    border: Border.all(
      color: AppColors.whiteOpacity20,
      width: 1,
    ),
  );

  static BoxDecoration timerSettingsDecoration = BoxDecoration(
    color: AppColors.whiteOpacity05,
    borderRadius: BorderRadius.circular(15),
  );

  static BoxDecoration timerDisplayDecoration = BoxDecoration(
    color: AppColors.whiteOpacity10,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: AppColors.whiteOpacity30,
    ),
  );

  // Button Styles
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 0,
  );

  static ButtonStyle redButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryRed,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 0,
  );

  static ButtonStyle greenButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryGreen,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    elevation: 0,
  );

  // Common Sizes
  static const double defaultPadding = 20.0;
  static const double smallPadding = 10.0;
  static const double mediumPadding = 15.0;
  static const double iconSize = 28.0;
  static const double smallIconSize = 20.0;
  static const double buttonHeight = 50.0;
  static const double lightSelectorWidth = 80.0;
  static const double lightSelectorHeight = 60.0;
  static const double timerDisplaySize = 60.0;
  static const double timerDisplayHeight = 40.0;
}
