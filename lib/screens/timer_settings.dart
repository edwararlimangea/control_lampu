import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../models/light_data.dart';
import 'quick_timer_button.dart';

class TimerSettings extends StatelessWidget {
  final int selectedLightIndex;
  final int selectedHours;
  final int selectedMinutes;
  final LightData lightData;
  final Function(int, int) onTimeSelected;
  final VoidCallback onStartTimer;
  final VoidCallback onStopTimer;

  const TimerSettings({
    Key? key,
    required this.selectedLightIndex,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.lightData,
    required this.onTimeSelected,
    required this.onStartTimer,
    required this.onStopTimer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppStyles.defaultPadding),
        Container(
          padding: const EdgeInsets.all(AppStyles.mediumPadding),
          decoration: AppStyles.timerSettingsDecoration,
          child: Column(
            children: [
              Text(
                'Set Timer untuk Lampu ${selectedLightIndex + 1}:',
                style: AppStyles.timerLabel,
              ),
              const SizedBox(height: AppStyles.mediumPadding),
              _buildTimeDisplay(),
              const SizedBox(height: AppStyles.mediumPadding),
              _buildQuickTimerButtons(),
            ],
          ),
        ),
        const SizedBox(height: AppStyles.mediumPadding),
        _buildTimerActionButtons(),
      ],
    );
  }

  Widget _buildTimeDisplay() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTimeUnit('Jam', selectedHours),
        const Text(':', style: AppStyles.timerSeparator),
        _buildTimeUnit('Menit', selectedMinutes),
      ],
    );
  }

  Widget _buildTimeUnit(String label, int value) {
    return Column(
      children: [
        Text(label, style: AppStyles.timerSubLabel),
        const SizedBox(height: 5),
        Container(
          width: AppStyles.timerDisplaySize,
          height: AppStyles.timerDisplayHeight,
          decoration: AppStyles.timerDisplayDecoration,
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: AppStyles.timerDisplay,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTimerButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        QuickTimerButton(
          label: '15m',
          hours: 0,
          minutes: 15,
          selectedHours: selectedHours,
          selectedMinutes: selectedMinutes,
          onSelected: onTimeSelected,
        ),
        QuickTimerButton(
          label: '30m',
          hours: 0,
          minutes: 30,
          selectedHours: selectedHours,
          selectedMinutes: selectedMinutes,
          onSelected: onTimeSelected,
        ),
        QuickTimerButton(
          label: '1h',
          hours: 1,
          minutes: 0,
          selectedHours: selectedHours,
          selectedMinutes: selectedMinutes,
          onSelected: onTimeSelected,
        ),
        QuickTimerButton(
          label: '2h',
          hours: 2,
          minutes: 0,
          selectedHours: selectedHours,
          selectedMinutes: selectedMinutes,
          onSelected: onTimeSelected,
        ),
      ],
    );
  }

  Widget _buildTimerActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppStyles.buttonHeight,
          child: ElevatedButton(
            onPressed: onStartTimer,
            style: AppStyles.primaryButtonStyle,
            child: const Text(
              'Mulai Timer & Nyalakan',
              style: AppStyles.buttonText,
            ),
          ),
        ),
        if (lightData.hasTimer) ...[
          const SizedBox(height: AppStyles.smallPadding),
          SizedBox(
            width: double.infinity,
            height: AppStyles.buttonHeight,
            child: ElevatedButton(
              onPressed: onStopTimer,
              style: AppStyles.redButtonStyle,
              child: const Text(
                'Hentikan Timer',
                style: AppStyles.buttonText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
