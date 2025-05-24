import 'package:flutter/material.dart';
import '../models/light_data.dart';

class LightBulbWidget extends StatelessWidget {
  final LightData lightData;
  final Animation<double> pulseAnimation;
  final Animation<double> glowAnimation;
  final VoidCallback onTap;
  final int lightIndex;

  const LightBulbWidget({
    Key? key,
    required this.lightData,
    required this.pulseAnimation,
    required this.glowAnimation,
    required this.onTap,
    required this.lightIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Light Bulb Animation
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: lightData.isOn ? pulseAnimation.value : 1.0,
              child: AnimatedBuilder(
                animation: glowAnimation,
                builder: (context, child) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: lightData.isOn
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
                          gradient: lightData.isOn
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
                            color: lightData.isOn
                                ? Colors.yellow.withOpacity(0.8)
                                : Colors.grey.withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.lightbulb,
                          size: 60,
                          color: lightData.isOn
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
          'Lampu ${lightIndex + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 5),

        Text(
          lightData.isOn ? 'Menyala' : 'Mati',
          style: TextStyle(
            color: lightData.isOn ? Colors.green : Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        if (lightData.hasTimer) ...[
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue),
            ),
            child: Text(
              'Timer: ${lightData.timerText}',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],

        if (lightData.isManuallyControlled) ...[
          SizedBox(height: 10),
          Container(
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
          ),
        ],

        SizedBox(height: 10),

        Text(
          'Ketuk untuk ${lightData.isOn ? 'mematikan' : 'menyalakan'}',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
