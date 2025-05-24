import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Light Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0A0A),
      ),
      home: LightControlScreen(),
    );
  }
}

class LightData {
  bool isOn;
  bool hasTimer;
  int timerHours;
  int timerMinutes;
  int remainingSeconds;
  Timer? timer;
  bool isManuallyControlled;

  LightData({
    this.isOn = false,
    this.hasTimer = false,
    this.timerHours = 0,
    this.timerMinutes = 1,
    this.remainingSeconds = 0,
    this.timer,
    this.isManuallyControlled = false,
  });

  void startTimer(VoidCallback onTimerEnd) {
    if (timer != null) {
      timer!.cancel();
    }

    remainingSeconds = (timerHours * 3600) + (timerMinutes * 60);
    hasTimer = true;
    isManuallyControlled = false;

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      remainingSeconds--;
      if (remainingSeconds <= 0) {
        timer.cancel();
        hasTimer = false;
        isOn = false;
        onTimerEnd();
      }
    });
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    hasTimer = false;
    remainingSeconds = 0;
  }

  void toggleManual() {
    isManuallyControlled = true;
    stopTimer();
    isOn = !isOn;
  }

  String get timerText {
    if (!hasTimer) return '';
    int hours = remainingSeconds ~/ 3600;
    int minutes = (remainingSeconds % 3600) ~/ 60;
    int seconds = remainingSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class LightControlScreen extends StatefulWidget {
  @override
  _LightControlScreenState createState() => _LightControlScreenState();
}

class _LightControlScreenState extends State<LightControlScreen>
    with TickerProviderStateMixin {
  // TAMBAHKAN VARIABEL INI
  final String arduinoIP = "192.168.18.30"; // Ganti dengan IP Arduino kamu

  List<LightData> lights = List.generate(4, (index) => LightData());
  int selectedLightIndex = 0;
  bool isTimerMode = false;
  int selectedHours = 0;
  int selectedMinutes = 1;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  Timer? _uiUpdateTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Update UI setiap detik untuk timer
    _uiUpdateTimer = Timer.periodic(Duration(seconds: 1), (timer) {
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

  Future<void> controlArduinoRelay(int lightIndex, bool turnOn) async {
    try {
      // Mapping light index ke relay (hanya 2 relay fisik tersedia)
      int relayNumber = (lightIndex % 2) + 1; // relay 1 atau 2
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
    // TAMBAHKAN async
    setState(() {
      lights[selectedLightIndex].toggleManual();
      _updateGlowAnimation();
    });

    // TAMBAHKAN BARIS INI
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
    // TAMBAHKAN async
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
        // TAMBAHKAN async
        setState(() {
          _updateGlowAnimation();
        });
        // TAMBAHKAN BARIS INI
        await controlArduinoRelay(selectedLightIndex, false);
      });
      _updateGlowAnimation();
    });

    // TAMBAHKAN BARIS INI
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
                // Header
                Row(
                  children: [
                    // Icon(
                    //   Icons.menu,
                    //   color: Colors.white,
                    //   size: 28,
                    // ),
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
                    // Icon(
                    //   Icons.settings,
                    //   color: Colors.white,
                    //   size: 28,
                    // ),
                  ],
                ),

                SizedBox(height: 20),

                // Room Info
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.living,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meja Billiard',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '4 Lampu Terhubung',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: anyLightOn ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          '$activeLights/4 ON',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Light Selection
                Container(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedLightIndex = index;
                          });
                        },
                        child: Container(
                          width: 80,
                          margin: EdgeInsets.only(right: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: selectedLightIndex == index
                                ? Colors.blue
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: lights[index].isOn
                                  ? Colors.yellow
                                  : Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: lights[index].isOn
                                    ? Colors.yellow
                                    : Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'L${index + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Light Bulb Animation
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: lights[selectedLightIndex].isOn
                                  ? _pulseAnimation.value
                                  : 1.0,
                              child: AnimatedBuilder(
                                animation: _glowAnimation,
                                builder: (context, child) {
                                  return Container(
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: lights[selectedLightIndex].isOn
                                          ? [
                                              BoxShadow(
                                                color: Colors.yellow
                                                    .withOpacity(0.5 *
                                                        _glowAnimation.value),
                                                blurRadius: 50,
                                                spreadRadius: 20,
                                              ),
                                              BoxShadow(
                                                color: Colors.orange
                                                    .withOpacity(0.3 *
                                                        _glowAnimation.value),
                                                blurRadius: 80,
                                                spreadRadius: 30,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: GestureDetector(
                                      onTap: toggleLight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient:
                                              lights[selectedLightIndex].isOn
                                                  ? RadialGradient(
                                                      colors: [
                                                        Colors.yellow
                                                            .withOpacity(0.8),
                                                        Colors.orange
                                                            .withOpacity(0.6),
                                                        Colors.deepOrange
                                                            .withOpacity(0.4),
                                                      ],
                                                    )
                                                  : RadialGradient(
                                                      colors: [
                                                        Colors.grey
                                                            .withOpacity(0.3),
                                                        Colors.grey
                                                            .withOpacity(0.2),
                                                        Colors.grey
                                                            .withOpacity(0.1),
                                                      ],
                                                    ),
                                          border: Border.all(
                                            color: lights[selectedLightIndex]
                                                    .isOn
                                                ? Colors.yellow.withOpacity(0.8)
                                                : Colors.grey.withOpacity(0.3),
                                            width: 3,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.lightbulb,
                                          size: 60,
                                          color: lights[selectedLightIndex].isOn
                                              ? Colors.white
                                              : Colors.grey.withOpacity(0.5),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 20),

                        Text(
                          'Lampu ${selectedLightIndex + 1}',
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
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
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
                          ),
                        ],

                        if (lights[selectedLightIndex]
                            .isManuallyControlled) ...[
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 8),
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
                          ),
                        ],

                        SizedBox(height: 10),

                        Text(
                          'Ketuk untuk ${lights[selectedLightIndex].isOn ? 'mematikan' : 'menyalakan'}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Control Panel
                Container(
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
                      // Timer Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                color: Colors.white,
                                size: 24,
                              ),
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
                            value: isTimerMode,
                            onChanged: (value) {
                              setState(() {
                                isTimerMode = value;
                              });
                            },
                            activeColor: Colors.blue,
                            activeTrackColor: Colors.blue.withOpacity(0.3),
                          ),
                        ],
                      ),

                      if (isTimerMode) ...[
                        SizedBox(height: 20),

                        // Timer Settings
                        Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Set Timer untuk Lampu ${selectedLightIndex + 1}:',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),

                              SizedBox(height: 15),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Hours
                                  Column(
                                    children: [
                                      Text(
                                        'Jam',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 60,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            selectedHours
                                                .toString()
                                                .padLeft(2, '0'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  Text(
                                    ':',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  // Minutes
                                  Column(
                                    children: [
                                      Text(
                                        'Menit',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Container(
                                        width: 60,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            selectedMinutes
                                                .toString()
                                                .padLeft(2, '0'),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              SizedBox(height: 15),

                              // Quick Timer Buttons
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildQuickTimerButton('15m', 0, 15),
                                  _buildQuickTimerButton('30m', 0, 30),
                                  _buildQuickTimerButton('1h', 1, 0),
                                  _buildQuickTimerButton('2h', 2, 0),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 15),

                        // Start Timer Button
                        Container(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: startTimerForLight,
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
                        ),

                        if (lights[selectedLightIndex].hasTimer) ...[
                          SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  lights[selectedLightIndex].stopTimer();
                                });
                              },
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
                          ),
                        ],
                      ],

                      if (!isTimerMode) ...[
                        SizedBox(height: 15),

                        // Manual Control Button
                        Container(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: toggleLight,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: lights[selectedLightIndex].isOn
                                  ? Colors.red
                                  : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              lights[selectedLightIndex].isOn
                                  ? 'Matikan Lampu ${selectedLightIndex + 1}'
                                  : 'Nyalakan Lampu ${selectedLightIndex + 1}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTimerButton(String label, int hours, int minutes) {
    bool isSelected = selectedHours == hours && selectedMinutes == minutes;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHours = hours;
          selectedMinutes = minutes;
        });
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
}
