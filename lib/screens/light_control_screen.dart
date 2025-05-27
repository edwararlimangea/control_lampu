// Screen utama
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/light_data.dart';
import '../widgets/room_info_widget.dart';
import '../widgets/light_selector_widget.dart';
import '../widgets/light_bulb_widget.dart';
import '../widgets/timer_controls_widget.dart';

class LightControlScreen extends StatefulWidget {
  @override
  _LightControlScreenState createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen>
    with TickerProviderStateMixin {
  final String arduinoIP = "192.168.18.30";

  List<LightData> lights = List.generate(4, (index) => LightData());
  int selectedLightIndex = 0;
  bool isTimerMode = false;
  int selectedHours = 0;
  int selectedMinutes = 0;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startUITimer();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  void _startUITimer() {
    _uiUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    _uiUpdateTimer?.cancel();
    _cancelAllTimers();
    super.dispose();
  }

  void _cancelAllTimers() {
    for (var light in lights) {
      light.stopTimer();
    }
  }

  Future<void> controlArduinoRelay(int lightIndex, bool turnOn) async {
    try {
      int relayNumber = (lightIndex % 2) + 1;
      String action = turnOn ? "on" : "off";
      String url = "http://$arduinoIP/relay$relayNumber/$action";
      print("🔄 Mengirim request ke: $url");

      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        print("Successfully controlled relay $relayNumber: $action");
      } else {
        print("Failed to control relay: ${response.statusCode}");
        _showErrorSnackBar("Gagal mengontrol lampu fisik");
      }
    } catch (e) {
      print("Error controlling Arduino: $e");
      _showErrorSnackBar("Tidak dapat terhubung ke Arduino");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void toggleLight() async {
    setState(() {
      lights[selectedLightIndex].toggleManual();
      _updateGlowAnimation();
    });
    await controlArduinoRelay(
        selectedLightIndex, lights[selectedLightIndex].isOn);
  }

  void _updateGlowAnimation() {
    bool anyLightOn = lights.any((light) => light.isOn);
    if (anyLightOn) {
      _glowController.forward();
    } else {
      _glowController.reverse();
    }
  }

  void startTimerForLight() async {
    if (selectedHours == 0 && selectedMinutes == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Waktu timer tidak boleh 0!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      lights[selectedLightIndex].timerHours = selectedHours;
      lights[selectedLightIndex].timerMinutes = selectedMinutes;
      lights[selectedLightIndex].isOn = true;
      lights[selectedLightIndex].startTimer(() async {
        setState(() => _updateGlowAnimation());
        await controlArduinoRelay(selectedLightIndex, false);
      });
      _updateGlowAnimation();
    });

    await controlArduinoRelay(selectedLightIndex, true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Timer dimulai untuk Lampu ${selectedLightIndex + 1} - ${selectedHours}h ${selectedMinutes}m',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  int get activeLights => lights.where((light) => light.isOn).length;

  @override
  Widget build(BuildContext context) {
    bool anyLightOn = lights.any((light) => light.isOn);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: anyLightOn
                ? [
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                    Color(0xFF0F3460),
                  ]
                : [
                    Color(0xFF0A0A0A),
                    Color(0xFF1A1A1A),
                    Color(0xFF2A2A2A),
                  ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 20),
                RoomInfoWidget(
                    anyLightOn: anyLightOn, activeLights: activeLights),
                SizedBox(height: 20),
                LightSelectorWidget(
                  lights: lights,
                  selectedLightIndex: selectedLightIndex,
                  onLightSelected: (index) {
                    setState(() => selectedLightIndex = index);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LightBulbWidget(
                          light: lights[selectedLightIndex],
                          pulseAnimation: _pulseAnimation,
                          glowAnimation: _glowAnimation,
                          onTap: toggleLight,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'MEJA ${selectedLightIndex + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          lights[selectedLightIndex].isOn ? 'Menyala' : 'Mati',
                          style: TextStyle(
                            color: lights[selectedLightIndex].isOn
                                ? Colors.green
                                : Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (lights[selectedLightIndex].hasTimer) ...[
                          SizedBox(height: 10),
                          _buildTimerDisplay(),
                        ],
                        if (lights[selectedLightIndex]
                            .isManuallyControlled) ...[
                          SizedBox(height: 10),
                          _buildManualControlIndicator(),
                        ],
                        SizedBox(height: 10),
                        _buildTapInstruction(),
                      ],
                    ),
                  ),
                ),
                TimerControlsWidget(
                  isTimerMode: isTimerMode,
                  onTimerModeChanged: (value) =>
                      setState(() => isTimerMode = value),
                  selectedHours: selectedHours,
                  selectedMinutes: selectedMinutes,
                  onHoursChanged: (hours) =>
                      setState(() => selectedHours = hours),
                  onMinutesChanged: (minutes) =>
                      setState(() => selectedMinutes = minutes),
                  onStartTimer: startTimerForLight,
                  onStopTimer: () {
                    setState(() => lights[selectedLightIndex].stopTimer());
                  },
                  onToggleLight: toggleLight,
                  light: lights[selectedLightIndex],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              'Smart Light Control',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue),
      ),
      child: Text(
        'Timer: ${lights[selectedLightIndex].timerText}',
        style: TextStyle(
          color: Colors.blue,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildManualControlIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange),
      ),
      child: Text(
        'Kontrol Manual',
        style: TextStyle(
          color: Colors.orange,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTapInstruction() {
    return Text(
      'Ketuk untuk ${lights[selectedLightIndex].isOn ? 'mematikan' : 'menyalakan'}',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: 14,
      ),
    );
  }
}
