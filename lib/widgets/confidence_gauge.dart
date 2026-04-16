import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ConfidenceGauge extends StatefulWidget {
  final double confidence;
  final double size;

  const ConfidenceGauge({
    super.key,
    required this.confidence,
    this.size = 80,
  });

  @override
  State<ConfidenceGauge> createState() => _ConfidenceGaugeState();
}

class _ConfidenceGaugeState extends State<ConfidenceGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 2.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color = widget.confidence >= 0.8 ? AppColors.emeraldWin : AppColors.legalGold;

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: _glowAnimation.value,
                      spreadRadius: _glowAnimation.value / 4,
                    ),
                  ],
                ),
              ),
              // Base Ring
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugePainter(
                  progress: widget.confidence,
                  color: color,
                  backgroundColor: AppColors.slateAccent.withOpacity(0.2),
                ),
              ),
              // Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(widget.confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: widget.size * 0.25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'MATCH',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: widget.size * 0.1,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (min(size.width, size.height) / 2) - 4;
    final strokeWidth = size.width * 0.08;

    // Background Circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
