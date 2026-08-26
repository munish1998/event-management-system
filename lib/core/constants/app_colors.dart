import 'package:flutter/material.dart';

class AppColors {

  static const Color primary = Color(0xFFF5A623);
  static const Color primaryColor = Color(0xFFF5A623);
  static const Color primaryDark = Color(0xFFD98E15);
  static const Color primaryLight = Color(0x33F5A623);
  static const Color goldAccent = Color(0xFFF5A623);
  static const Color goldLight = Color(0xFFFFC25C);

  static const Color background = Color(0xFF000000);
  static const Color backgroundSecondary = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceSecondary = Color(0xFF1E1E1E);
  static const Color surfaceLight = Color(0xFF282828);
  static const Color surfaceGlass = Color(0x22FFFFFF);

  static const Color secondary = Color(0xFFF5A623);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentAmber = Color(0xFFF5A623);
  static const Color accentPurple = Color(0xFF9D65F5);
  static const Color accentRose = Color(0xFFF43F5E);

  static const Color statusUpcoming = Color(0xFFF5A623);
  static const Color statusOngoing = Color(0xFF10B981);
  static const Color statusCompleted = Color(0xFF71717A);

  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF000000);
  static const Color textSecondary = Color(0xFFF5A623);
  static const Color textMuted = Color(0xFFA1A1AA);

  static const Color border = Color(0xFF333333);
  static const Color borderGold = Color(0xFFF5A623);
  static const Color borderLight = Color(0x44F5A623);

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
