import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';

class TrendChartsWidget extends StatelessWidget {
  const TrendChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ANALYTICS',
          style: AppTypography.caption.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Live Analytics. Zero Guesswork.',
          style: AppTypography.headingSmall,
        ),
        const SizedBox(height: 14),

        // Tickets Trend Card (Image 5 style - Gold Amber bars)
        GlassContainer(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TICKETS TREND',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentAmber,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.bar_chart_rounded, color: AppColors.accentAmber, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '10',
                style: AppTypography.headingLarge.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 16),

              // Bar Chart Visualization
              SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar('Apr/28', 0.3, AppColors.accentAmber),
                    _buildBar('29', 0.1, AppColors.border),
                    _buildBar('30', 0.9, AppColors.accentAmber),
                    _buildBar('May/1', 0.3, AppColors.accentAmber),
                    _buildBar('2', 0.05, AppColors.border),
                    _buildBar('3', 0.05, AppColors.border),
                    _buildBar('4', 0.05, AppColors.border),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Visits Trend Card (Image 5 style - Green bars)
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VISITS TREND',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.show_chart_rounded, color: AppColors.accentGreen, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '26',
                style: AppTypography.headingLarge.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 16),

              // Bar Chart Visualization
              SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBar('Apr/28', 0.2, AppColors.accentGreen),
                    _buildBar('29', 0.3, AppColors.accentGreen),
                    _buildBar('30', 0.4, AppColors.accentGreen),
                    _buildBar('May/1', 0.2, AppColors.accentGreen),
                    _buildBar('2', 0.7, AppColors.accentGreen),
                    _buildBar('3', 0.1, AppColors.accentGreen),
                    _buildBar('4', 0.3, AppColors.accentGreen),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBar(String label, double ratio, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 18,
          height: 60 * ratio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTypography.caption.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
