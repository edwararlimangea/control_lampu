import 'package:flutter/material.dart';
import '../constants/styles.dart';
import '../constants/colors.dart';

class RoomInfoCard extends StatelessWidget {
  final int activeLights;
  final int totalLights;
  final bool anyLightOn;

  const RoomInfoCard({
    Key? key,
    required this.activeLights,
    required this.totalLights,
    required this.anyLightOn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppStyles.defaultPadding),
      decoration: AppStyles.glassmorphicContainer,
      child: Row(
        children: [
          const Icon(
            Icons.living,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(width: AppStyles.mediumPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Meja Billiard',
                style: AppStyles.roomTitle,
              ),
              Text(
                '$totalLights Lampu Terhubung',
                style: AppStyles.roomSubtitle,
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: anyLightOn ? AppColors.primaryGreen : AppColors.primaryRed,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '$activeLights/$totalLights ON',
              style: AppStyles.statusText,
            ),
          ),
        ],
      ),
    );
  }
}
