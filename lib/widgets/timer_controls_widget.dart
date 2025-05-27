// Widget kontrol timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/light_data.dart';

class TimerControlsWidget extends StatefulWidget {
  final bool isTimerMode;
  final ValueChanged<bool> onTimerModeChanged;
  final int selectedHours;
  final int selectedMinutes;
  final ValueChanged<int> onHoursChanged;
  final ValueChanged<int> onMinutesChanged;
  final VoidCallback onStartTimer;
  final VoidCallback onStopTimer;
  final VoidCallback onToggleLight;
  final LightData light;

  const TimerControlsWidget({
    required this.isTimerMode,
    required this.onTimerModeChanged,
    required this.selectedHours,
    required this.selectedMinutes,
    required this.onHoursChanged,
    required this.onMinutesChanged,
    required this.onStartTimer,
    required this.onStopTimer,
    required this.onToggleLight,
    required this.light,
    Key? key,
  }) : super(key: key);

  @override
  _TimerControlsWidgetState createState() => _TimerControlsWidgetState();
}

class _TimerControlsWidgetState extends State<TimerControlsWidget> {
  late TextEditingController _hoursController;
  late TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    _hoursController = TextEditingController(
        text: widget.selectedHours.toString().padLeft(2, '0'));
    _minutesController = TextEditingController(
        text: widget.selectedMinutes.toString().padLeft(2, '0'));
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TimerControlsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedHours != oldWidget.selectedHours) {
      _hoursController.text = widget.selectedHours.toString().padLeft(2, '0');
    }
    if (widget.selectedMinutes != oldWidget.selectedMinutes) {
      _minutesController.text =
          widget.selectedMinutes.toString().padLeft(2, '0');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildTimerToggle(),
          if (widget.isTimerMode) ...[
            SizedBox(height: 20),
            _buildTimerSettings(),
            SizedBox(height: 15),
            _buildStartTimerButton(),
            if (widget.light.hasTimer) ...[
              SizedBox(height: 10),
              _buildStopTimerButton(),
            ],
          ],
          if (!widget.isTimerMode) ...[
            SizedBox(height: 15),
            _buildManualControlButton(),
          ],
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
            Icon(Icons.timer, color: Colors.white, size: 24),
            SizedBox(width: 10),
            Text(
              'Timer Mode',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Switch(
          value: widget.isTimerMode,
          onChanged: widget.onTimerModeChanged,
          activeColor: Colors.blue,
          activeTrackColor: Colors.blue.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildTimerSettings() {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            'Set Timer:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildManualTimeInput(
                  'Jam', _hoursController, 23, widget.onHoursChanged),
              Text(
                ':',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildManualTimeInput(
                  'Menit', _minutesController, 59, widget.onMinutesChanged),
            ],
          ),
          SizedBox(height: 15),
          _buildQuickTimerButtons(),
        ],
      ),
    );
  }

  Widget _buildManualTimeInput(String label, TextEditingController controller,
      int maxValue, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 5),
        Container(
          width: 80,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(2),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '00',
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                int intValue = int.tryParse(value) ?? 0;
                if (intValue > maxValue) {
                  intValue = maxValue;
                  controller.text = intValue.toString();
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
                onChanged(intValue);
              } else {
                onChanged(0);
              }
            },
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
        _buildQuickTimerButton('15m', 0, 15),
        _buildQuickTimerButton('30m', 0, 30),
        _buildQuickTimerButton('1h', 1, 0),
        _buildQuickTimerButton('2h', 2, 0),
        _buildQuickTimerButton('Reset', 0, 0),
      ],
    );
  }

  Widget _buildQuickTimerButton(String label, int hours, int minutes) {
    bool isSelected =
        widget.selectedHours == hours && widget.selectedMinutes == minutes;

    return GestureDetector(
      onTap: () {
        widget.onHoursChanged(hours);
        widget.onMinutesChanged(minutes);
        _hoursController.text = hours.toString().padLeft(2, '0');
        _minutesController.text = minutes.toString().padLeft(2, '0');
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.white.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStartTimerButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.onStartTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          'Mulai Timer & Nyalakan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStopTimerButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.onStopTimer,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          'Hentikan Timer',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildManualControlButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: widget.onToggleLight,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.light.isOn ? Colors.red : Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          widget.light.isOn ? 'Matikan Lampu' : 'Nyalakan Lampu',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
