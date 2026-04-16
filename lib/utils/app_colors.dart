import 'package:flutter/material.dart';

class AppColors {
  // Base Surfaces
  static const Color obsidianBackground = Color(0xFF0B1326);
  static const Color surfaceDeep = Color(0xFF060E20);
  static const Color surfaceElevated = Color(0xFF131B2E);
  static const Color surfaceBright = Color(0xFF171F33);
  static const Color surfaceHighest = Color(0xFF222A3D);

  // Brand Colors
  static const Color legalGold = Color(0xFFD4AF37);
  static const Color goldBright = Color(0xFFF2CA50);
  
  // Outcome Colors
  static const Color emeraldWin = Color(0xFF10B981);
  static const Color crimsonLoss = Color(0xFFEF4444);
  
  // Accent Colors
  static const Color slateAccent = Color(0xFF1E293B);
  static const Color cyanTrend = Color(0xFF0EA5E9);

  // Text Colors
  static const Color textPrimary = Color(0xFFDAE2FD);
  static const Color textSecondary = Color(0xFFD0C5AF);
  static const Color textMuted = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldBright, legalGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient obsidianGradient = LinearGradient(
    colors: [obsidianBackground, surfaceDeep],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
