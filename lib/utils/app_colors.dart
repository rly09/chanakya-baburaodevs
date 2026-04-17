import 'package:flutter/material.dart';

class AppColors {
  // Base Surfaces (Monochromatic scale)
  static const Color background = Color(0xFFFFFFFF); // Pure White Background
  static const Color surface = Color(0xFFF9FAFB); // Very Light Gray
  static const Color surfaceElevated = Color(0xFFF3F4F6); // Light Gray
  static const Color surfaceHighlight = Color(0xFFE5E7EB); // Medium Light Gray
  
  // Brand Colors (Monochromatic)
  static const Color primary = Color(0xFF111827); // Absolute Dark Gray/Black
  static const Color primaryDark = Color(0xFF000000); // Pure Black
  static const Color primaryLight = Color(0xFF374151); // Medium Dark Gray
  
  // Outcome Colors (Keeping minimal colors here just in case logic breaks, but muted)
  static const Color success = Color(0xFF111827); // Using primary for static, uncolored feel
  static const Color error = Color(0xFF111827); // Using primary 
  
  // Accent Colors
  static const Color border = Color(0xFFD1D5DB); // Neutral Gray Border
  static const Color accent = Color(0xFF374151); // Dark Gray Accent

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Near Black
  static const Color textSecondary = Color(0xFF4B5563); // Gray
  static const Color textMuted = Color(0xFF9CA3AF); // Light Gray

  // ALIASES TO PREVENT BUILD BREAKAGE DURING REFACTORING (WILL REMOVE LATER)
  static const Color obsidianBackground = background;
  static const Color surfaceDeep = surface;
  static const Color surfaceBright = surfaceElevated;
  static const Color surfaceHighest = surfaceHighlight;
  static const Color legalGold = primary;
  static const Color goldBright = accent;
  static const Color emeraldWin = success;
  static const Color crimsonLoss = error;
  static const Color slateAccent = border;
  static const Color cyanTrend = accent;
}
