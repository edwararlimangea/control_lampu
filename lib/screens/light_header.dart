import 'package:flutter/material.dart';
import '../constants/styles.dart';

class LightHeader extends StatelessWidget {
  const LightHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Icon(
          Icons.menu,
          color: Colors.white,
          size: AppStyles.iconSize,
        ),
        const Text(
          'Smart Light Control',
          style: AppStyles.headerTitle,
        ),
        const Icon(
          Icons.settings,
          color: Colors.white,
          size: AppStyles.iconSize,
        ),
      ],
    );
  }
}
