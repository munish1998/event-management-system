import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../bloc/events_bloc/events_bloc.dart';
import '../../../../bloc/events_bloc/events_state.dart';
import '../widgets/stat_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is! EventsLoaded) {
          return const LoadingWidget(size: 40);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                  'Overview & Real-time Metrics',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Total Events',
                        value: '${state.allEvents.length}',
                        subtitle: 'Created by Admin',
                        icon: Icons.event_available_rounded,
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: StatCard(
                        title: 'Total Interested',
                        value: '${state.totalAttendees}',
                        subtitle: 'Platform User Interest',
                        icon: Icons.people_alt_rounded,
                        accentColor: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Live Now',
                        value: '${state.ongoingCount}',
                        subtitle: 'Active Stream Events',
                        icon: Icons.sensors_rounded,
                        accentColor: AppColors.statusOngoing,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: StatCard(
                        title: 'Upcoming',
                        value: '${state.upcomingCount}',
                        subtitle: 'Scheduled Events',
                        icon: Icons.schedule_rounded,
                        accentColor: AppColors.statusUpcoming,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                Text(
                  'Status Breakdown',
                  style: AppTypography.headingSmall,
                ),
                const SizedBox(height: 12),
                GlassContainer(
                  child: Column(
                    children: [
                      _buildProgressBar(
                        context,
                        label: 'Upcoming Events',
                        count: state.upcomingCount,
                        total: state.allEvents.length,
                        color: AppColors.statusUpcoming,
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(
                        context,
                        label: 'Live Ongoing Events',
                        count: state.ongoingCount,
                        total: state.allEvents.length,
                        color: AppColors.statusOngoing,
                      ),
                      const SizedBox(height: 16),
                      _buildProgressBar(
                        context,
                        label: 'Completed Events',
                        count: state.completedCount,
                        total: state.allEvents.length,
                        color: AppColors.statusCompleted,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                GlassContainer(
                  borderColor: AppColors.primary.withOpacity(0.4),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_done_rounded, color: AppColors.secondary, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline Sync Ready',
                              style: AppTypography.headingSmall.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Local cache active with Hive/BLoC state.',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
        },
      );
  }

  Widget _buildProgressBar(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final double ratio = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyLarge.copyWith(fontSize: 14)),
            Text(
              '$count (${(ratio * 100).toInt()}%)',
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: AppColors.surfaceLight,
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
