import 'package:flutter/material.dart';

class AnimationUtils {
  static AnimationController createPulseController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(seconds: 2),
      vsync: vsync,
    )..repeat(reverse: true);
  }

  static AnimationController createGlowController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
  }

  static Animation<double> createPulseAnimation(
      AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  static Animation<double> createGlowAnimation(AnimationController controller) {
    return Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }

  static void updateGlowAnimation(
    AnimationController glowController,
    bool shouldGlow,
  ) {
    if (shouldGlow) {
      glowController.forward();
    } else {
      glowController.reverse();
    }
  }
}
