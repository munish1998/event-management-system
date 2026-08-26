import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';

class RevenueDashboardCard extends StatelessWidget {
  final double totalRevenue;
  final int soldCount;
  final int checkedInCount;
  final int interestedCount;
  final int visitsCount;
  final int pageViewsCount;

  const RevenueDashboardCard({
    super.key,
    this.totalRevenue = 1090.00,
    this.soldCount = 56,
    this.checkedInCount = 0,
    this.interestedCount = 11,
    this.visitsCount = 99,
    this.pageViewsCount = 133,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.revenueCardGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL REVENUE',
                style: AppTypography.caption.copyWith(
                  color: Colors.white70,
                  letterSpacing: 1.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${totalRevenue.toStringAsFixed(2)}',
                style: AppTypography.headingLarge.copyWith(
                  fontSize: 34,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSubStat('SOLD', '$soldCount'),
                  Container(height: 24, width: 1, color: Colors.white24),
                  _buildSubStat('CHECKED IN', '$checkedInCount'),
                  Container(height: 24, width: 1, color: Colors.white24),
                  _buildSubStat('INTERESTED', '$interestedCount'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'VISITS',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$visitsCount',
                      style: AppTypography.headingLarge.copyWith(
                        fontSize: 26,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAGE VIEWS',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pageViewsCount',
                      style: AppTypography.headingLarge.copyWith(
                        fontSize: 26,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        GlassContainer(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Sales by Ticket Sources',
                    style: AppTypography.headingSmall.copyWith(fontSize: 15),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'All Slots',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSourceRow('Others', 23, 0.40, AppColors.accentGreen),
              const SizedBox(height: 12),
              _buildSourceRow('Untracked', 20, 0.36, AppColors.accentAmber),
              const SizedBox(height: 12),
              _buildSourceRow('AllEvents', 12, 0.22, AppColors.accentPurple),
              const SizedBox(height: 12),
              _buildSourceRow('Facebook', 4, 0.08, AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.headingMedium.copyWith(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildSourceRow(String label, int count, double percentage, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium),
            Text(
              '$count • ${(percentage * 100).toInt()}%',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: AppColors.border,
          color: color,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }
}
