import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../constants/colors.dart';
import '../models/light_data.dart';

class LightSelector extends StatelessWidget {
  final List<LightData> lights;
  final int selectedLightIndex;
  final Function(int) onLightSelected;

  const LightSelector({
    Key? key,
    required this.lights,
    required this.selectedLightIndex,
    required this.onLightSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppStyles.lightSelectorHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: lights.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => onLightSelected(index),
            child: Container(
              width: AppStyles.lightSelectorWidth,
              margin: const EdgeInsets.only(right: AppStyles.smallPadding),
              padding: const EdgeInsets.all(AppStyles.smallPadding),
              decoration: BoxDecoration(
                color: selectedLightIndex == index
                    ? AppColors.primaryBlue
                    : AppColors.whiteOpacity10,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: lights[index].isOn
                      ? AppColors.primaryYellow
                      : AppColors.whiteOpacity30,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb,
                    color: lights[index].isOn
                        ? AppColors.primaryYellow
                        : AppColors.whiteOpacity50,
                    size: AppStyles.smallIconSize,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'L${index + 1}',
                    style: AppStyles.lightSelectorText,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
