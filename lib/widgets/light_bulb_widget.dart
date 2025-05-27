// Widget bola lampu animasi
import 'package:flutter/material.dart';
import '../models/light_data.dart';

class LightBulbWidget extends StatelessWidget {
  final LightData light;
  final Animation<double> pulseAnimation;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;

  const LightBulbWidget({
    required this.light,
    required this.pulseAnimation,
    required this.glowAnimation,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: light.isOn ? pulseAnimation.value : 1.0,
          child: AnimatedBuilder(
            animation: glowAnimation,
            builder: (context, child) {
              return Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: light.isOn
                      ? [
                          BoxShadow(
                            color: Colors.yellow
                                .withOpacity(0.5 * glowAnimation.value),
                            blurRadius: 50,
                            spreadRadius: 20,
                          ),
                          BoxShadow(
                            color: Colors.orange
                                .withOpacity(0.3 * glowAnimation.value),
                            blurRadius: 80,
                            spreadRadius: 30,
                          ),
                        ]
                      : [],
                ),
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: light.isOn
                          ? RadialGradient(
                              colors: [
                                Colors.yellow.withOpacity(0.8),
                                Colors.orange.withOpacity(0.6),
                                Colors.deepOrange.withOpacity(0.4),
                              ],
                            )
                          : RadialGradient(
                              colors: [
                                Colors.grey.withOpacity(0.3),
                                Colors.grey.withOpacity(0.2),
                                Colors.grey.withOpacity(0.1),
                              ],
                            ),
                      border: Border.all(
                        color: light.isOn
                            ? Colors.yellow.withOpacity(0.8)
                            : Colors.grey.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.lightbulb,
                      size: 60,
                      color: light.isOn
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
    );
  }
}
