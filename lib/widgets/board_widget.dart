import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'tile_widget.dart';

enum SwipeDirection { up, down, left, right }

class BoardWidget extends StatelessWidget {
  final List<int> board;
  final String colorSchemeName;
  final ValueChanged<SwipeDirection> onSwipe;

  const BoardWidget({
    super.key,
    required this.board,
    required this.colorSchemeName,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boardBg = isDark ? const Color(0xFF2C2A25) : const Color(0xFFBBADA0);

    return GestureDetector(
      onPanEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond;
        const minVelocity = 150.0; // Umbral mínimo para evitar toques accidentales

        if (velocity.dx.abs() < minVelocity && velocity.dy.abs() < minVelocity) {
          return;
        }

        if (velocity.dx.abs() > velocity.dy.abs()) {
          onSwipe(velocity.dx > 0 ? SwipeDirection.right : SwipeDirection.left);
        } else {
          onSwipe(velocity.dy > 0 ? SwipeDirection.down : SwipeDirection.up);
        }
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingSmall),
          decoration: BoxDecoration(
            color: boardBg,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppConstants.paddingSmall,
              mainAxisSpacing: AppConstants.paddingSmall,
            ),
            itemCount: 16,
            itemBuilder: (context, index) {
              return TileWidget(
                value: board[index],
                colorSchemeName: colorSchemeName,
              );
            },
          ),
        ),
      ),
    );
  }
}