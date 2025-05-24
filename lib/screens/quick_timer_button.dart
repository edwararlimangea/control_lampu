import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../constants/colors.dart';

class QuickTimerButton extends StatelessWidget {
  final String label;
  final int hours;
  final int minutes;
  final int selectedHours;
  final int selectedMinutes;
  final Function(int, int) onSelected;

  const QuickTimerButton({
    Key? key,
    required this.label,
    required this.hours,
    required this.minutes,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.onSelected,
  }) : super(key: key);

  bool get isSelected => selectedHours == hours && selectedMinutes == minutes;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelected(hours, minutes),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.whiteOpacity10,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color:
                isSelected ? AppColors.primaryBlue : AppColors.whiteOpacity30,
          ),
        ),
        child: Text(
          label,
          style: AppStyles.quickTimerText,
        ),
      ),
    );
  }
}
