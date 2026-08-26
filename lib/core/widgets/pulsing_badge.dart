import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../../services/enum.dart';

class EventStatusBadge extends StatelessWidget {
  final EventStatus status;

  const EventStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String label;
    IconData icon;

    switch (status) {
      case EventStatus.upcoming:
        badgeColor = AppColors.statusUpcoming;
        label = 'UPCOMING';
        icon = Icons.calendar_today_rounded;
        break;
      case EventStatus.ongoing:
        badgeColor = AppColors.statusOngoing;
        label = 'LIVE NOW';
        icon = Icons.sensors_rounded;
        break;
      case EventStatus.completed:
        badgeColor = AppColors.statusCompleted;
        label = 'COMPLETED';
        icon = Icons.check_circle_outline_rounded;
        break;
    }

    if (status == EventStatus.ongoing) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.7, end: 1.0),
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
        onEnd: () {},
        builder: (context, scale, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeColor, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: badgeColor.withOpacity(0.4 * scale),
                  blurRadius: 10 * scale,
                  spreadRadius: 2 * scale,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: badgeColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: badgeColor, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
