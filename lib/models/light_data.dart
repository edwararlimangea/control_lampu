import 'dart:async';
import 'package:flutter/material.dart';

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
    this.timerMinutes = 30,
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
