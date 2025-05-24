import 'package:control_lampu/screens/control_panel.dart';
import 'package:control_lampu/screens/light_header.dart';
import 'package:control_lampu/screens/light_selector.dart';
import 'package:control_lampu/screens/room_info_card.dart';
import 'package:control_lampu/widgets/light_bulb.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../models/light_data.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../utils/animation_utils.dart';

class LightControlScreen extends StatefulWidget {
  @override
  _LightControlScreenState createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen>
    with TickerProviderStateMixin {
  // State Variables
  List<LightData> lights = List.generate(4, (index) => LightData());
  int selectedLightIndex = 0;
  bool isTimerMode = false;
  int selectedHours = 0;
  int selectedMinutes = 30;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startUIUpdateTimer();
  }

  void _initializeAnimations() {
    _pulseController = AnimationUtils.createPulseController(this);
    _glowController = AnimationUtils.createGlowController(this);
    _pulseAnimation = AnimationUtils.createPulseAnimation(_pulseController);
    _glowAnimation = AnimationUtils.createGlowAnimation(_glowController);
  }

  void _startUIUpdateTimer() {
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _uiUpdateTimer?.cancel();

    // Cancel semua timer lampu
    for (var light in lights) {
      light.stopTimer();
    }
    super.dispose();
  }

  // Light Control Methods
  void _toggleLight() {
    setState(() {
      lights[selectedLightIndex].toggleManual();
      _updateGlowAnimation();
    });
  }

  void _updateGlowAnimation() {
    bool anyLightOn = lights.any((light) => light.isOn);
    AnimationUtils.updateGlowAnimation(_glowController, anyLightOn);
  }

  void _onLightSelected(int index) {
    setState(() {
      selectedLightIndex = index;
    });
  }

  // Timer Methods
  void _onTimerModeChanged(bool value) {
    setState(() {
      isTimerMode = value;
    });
  }

  void _onTimeSelected(int hours, int minutes) {
    setState(() {
      selectedHours = hours;
      selectedMinutes = minutes;
    });
  }

  void _startTimerForLight() {
    if (selectedHours == 0 && selectedMinutes == 0) {
      _showSnackBar('Waktu timer tidak boleh 0!', AppColors.primaryRed);
      return;
    }

    setState(() {
      lights[selectedLightIndex].timerHours = selectedHours;
      lights[selectedLightIndex].timerMinutes = selectedMinutes;
      lights[selectedLightIndex].isOn = true;
      lights[selectedLightIndex].startTimer(() {
        setState(() {
          _updateGlowAnimation();
        });
      });
      _updateGlowAnimation();
    });

    _showSnackBar(
      'Timer dimulai untuk Lampu ${selectedLightIndex + 1} - ${selectedHours}h ${selectedMinutes}m',
      AppColors.primaryGreen,
    );
  }

  void _stopTimerForLight() {
    setState(() {
      lights[selectedLightIndex].stopTimer();
    });
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  // Computed Properties
  int get activeLights => lights.where((light) => light.isOn).length;
  bool get anyLightOn => lights.any((light) => light.isOn);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: anyLightOn 
                ? AppColors.lightOnGradient 
                : AppColors.lightOffGradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            child: Column(
              children: [
                // Header
                const LightHeader(),
                
                const SizedBox(height: AppStyles.defaultPadding),

                // Room Info
                RoomInfoCard(
                  activeLights: activeLights,
                  totalLights: lights.length,
                  anyLightOn: anyLightOn,
                ),

                const SizedBox(height: AppStyles.defaultPadding),

                // Light Selection
                LightSelector(
                  lights: lights,
                  selectedLightIndex: selectedLightIndex,
                  onLightSelected: _onLightSelected,
                ),

                // Light Bulb Display
                Expanded(
                  child: Center(
                    child: LightBulbWidget(
                      lightData: lights[selectedLightIndex],
                      pulseAnimation: _pulseAnimation,
                      glowAnimation: _glowAnimation,
                      onTap: _toggleLight,
                      lightIndex: selectedLightIndex,
                    ),
                  ),
                ),

                // Control Panel
                ControlPanel(
                  isTimerMode: isTimerMode,
                  selectedLightIndex: selectedLightIndex,
                  selectedHours: selectedHours,
                  selectedMinutes: selectedMinutes,
                  selectedLight: lights[selectedLightIndex],
                  onTimerModeChanged: _onTimerModeChanged,
                  onTimeSelected: _onTimeSelected,
                  onStartTimer: _startTimerForLight,
                  onStopTimer: _stopTimerForLight,
                  onToggleLight: _toggleLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}