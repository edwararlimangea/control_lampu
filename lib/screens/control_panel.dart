import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../constants/colors.dart';
import '../models/light_data.dart';
import 'timer_settings.dart';

class ControlPanel extends StatelessWidget {
  final bool isTimerMode;
  final int selectedLightIndex;
  final int selectedHours;
  final int selectedMinutes;
  final LightData selectedLight;
  final Function(bool) onTimerModeChanged;
  final Function(int, int) onTimeSelected;
  final VoidCallback onStartTimer;
  final VoidCallback onStopTimer;
  final VoidCallback onToggleLight;

  const ControlPanel({
    Key? key,
    required this.isTimerMode,
    required this.selectedLightIndex,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.selectedLight,
    required this.onTimerModeChanged,
    required this.onTimeSelected,
    required this.onStartTimer,
    required this.onStopTimer,
    required this.onToggleLight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.controlPanelDecoration,
      child: Column(
        children: [
          _buildTimerToggle(),
          if (isTimerMode)
            TimerSettings(
              selectedLightIndex: selectedLightIndex,
              selectedHours: selectedHours,
              selectedMinutes: selectedMinutes,
              lightData: selectedLight,
              onTimeSelected: onTimeSelected,
              onStartTimer: onStartTimer,
              onStopTimer: onStopTimer,
            )
          else
            _buildManualControl(),
        ],
      ),
    );
  }

  Widget _buildTimerToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.timer,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: AppStyles.smallPadding),
            const Text(
              'Timer Mode',
              style: AppStyles.timerModeText,
            ),
          ],
        ),
        Switch(
          value: isTimerMode,
          onChanged: onTimerModeChanged,
          activeColor: AppColors.primaryBlue,
          activeTrackColor: AppColors.blueOpacity30,
        ),
      ],
    );
  }

  Widget _buildManualControl() {
    return Column(
      children: [
        const SizedBox(height: AppStyles.mediumPadding),
        SizedBox(
          width: double.infinity,
          height: AppStyles.buttonHeight,
          child: ElevatedButton(
            onPressed: onToggleLight,
            style: selectedLight.isOn
                ? AppStyles.redButtonStyle
                : AppStyles.greenButtonStyle,
            child: Text(
              selectedLight.isOn
                  ? 'Matikan Lampu ${selectedLightIndex + 1}'
                  : 'Nyalakan Lampu ${selectedLightIndex + 1}',
              style: AppStyles.buttonText,
            ),
          ),
        ),
      ],
    );
  }
}
