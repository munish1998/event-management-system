import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary Palette (Vibrant Warm Gold / Amber from Screenshot)
  static const Color primary = Color(0xFFF5A623);             // Warm Golden Amber
  static const Color primaryColor = Color(0xFFF5A623);        // Warm Gold
  static const Color primaryDark = Color(0xFFD98E15);         // Deep Gold
  static const Color primaryLight = Color(0x33F5A623);        // Gold Tint
  static const Color goldAccent = Color(0xFFF5A623);          // Gold Accent
  static const Color goldLight = Color(0xFFFFC25C);           // Bright Gold

  // Background & Surfaces (Deep Luxury Black from Screenshot)
  static const Color background = Color(0xFF000000);          // Pure Black
  static const Color backgroundSecondary = Color(0xFF0A0A0A); // Dark Neutral
  static const Color surface = Color(0xFF141414);             // Dark Card Surface
  static const Color surfaceSecondary = Color(0xFF1E1E1E);    // Elevated Surface
  static const Color surfaceLight = Color(0xFF282828);        // Surface Highlight
  static const Color surfaceGlass = Color(0x22FFFFFF);
  
  // Accents & Indicators
  static const Color secondary = Color(0xFFF5A623);           // Golden Secondary
  static const Color accentGreen = Color(0xFF10B981);         // Emerald Green
  static const Color accentAmber = Color(0xFFF5A623);         // Gold Amber
  static const Color accentPurple = Color(0xFF9D65F5);        // Purple
  static const Color accentRose = Color(0xFFF43F5E);          // Rose

  // Status Colors
  static const Color statusUpcoming = Color(0xFFF5A623);
  static const Color statusOngoing = Color(0xFF10B981);
  static const Color statusCompleted = Color(0xFF71717A);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);         // Pure White
  static const Color textDark = Color(0xFF000000);            // Deep Black
  static const Color textSecondary = Color(0xFFF5A623);       // Gold Highlight
  static const Color textMuted = Color(0xFFA1A1AA);           // Muted Gray

  // Borders & Outlines matching Screenshot Golden Rim
  static const Color border = Color(0xFF333333);
  static const Color borderGold = Color(0xFFF5A623);          // Golden Border from Screenshot
  static const Color borderLight = Color(0x44F5A623);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF5A623), Color(0xFFD98E15)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldButtonGradient = LinearGradient(
    colors: [Color(0xFFF5A623), Color(0xFFEE9F26)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient blackCardGradient = LinearGradient(
    colors: [Color(0xFF181818), Color(0xFF0F0F0F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sageBackgroundGradient = LinearGradient(
    colors: [Color(0xFF080808), Color(0xFF000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient walletCardGradient = blackCardGradient;
  static const LinearGradient buttonGradient = goldButtonGradient;
  static const LinearGradient revenueCardGradient = blackCardGradient;
  static const LinearGradient userGradient = goldButtonGradient;
}
