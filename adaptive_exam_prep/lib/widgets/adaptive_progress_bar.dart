import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Animated progress bar with smooth fill and subtle gradient.
class AdaptiveProgressBar extends StatelessWidget {
  final double value; // 0..1

  const AdaptiveProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          height: 14,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x15000000), blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Stack(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              width: width * clamped,
              decoration: BoxDecoration(
                gradient: AppTheme.appGradient,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ]),
        );
      },
    );
  }
}
