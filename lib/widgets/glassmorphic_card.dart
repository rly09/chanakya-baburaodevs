import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 20.0,
    this.opacity = 0.05,
    this.borderRadius,
    this.padding,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceHighest.withOpacity(opacity),
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: borderColor ?? AppColors.slateAccent.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
