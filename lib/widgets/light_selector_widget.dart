import 'package:flutter/material.dart';
import '../models/light_data.dart';

class LightSelectorWidget extends StatelessWidget {
  final List<LightData> lights;
  final int selectedLightIndex;
  final ValueChanged<int> onLightSelected;

  const LightSelectorWidget({
    required this.lights,
    required this.selectedLightIndex,
    required this.onLightSelected,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Hitung lebar tiap item berdasarkan jumlah lampu
        double itemWidth =
            (constraints.maxWidth - (10 * (lights.length - 1))) / lights.length;

        // Tinggi responsif, minimal 80
        double height = MediaQuery.of(context).size.height * 0.1;
        if (height < 80) height = 80;

        return SizedBox(
          height: height,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: lights.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onLightSelected(index),
                child: Container(
                  width: itemWidth,
                  padding: const EdgeInsets.all(10),
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
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'MEJA ${index + 1}',
                        style: const TextStyle(
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
        );
      },
    );
  }
}
