import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TileWidget extends StatelessWidget {
  final int value;
  final String colorSchemeName;

  const TileWidget({
    super.key,
    required this.value,
    required this.colorSchemeName,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bgColor = AppTheme.getTileColor(value, brightness, colorSchemeName);
    final textColor = AppTheme.getTileTextColor(value, brightness);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.tileRadius),
      ),
      alignment: Alignment.center,
      child: value == 0
          ? const SizedBox.shrink()
          : AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 150),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: value >= 1024 ? 22 : 28,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}