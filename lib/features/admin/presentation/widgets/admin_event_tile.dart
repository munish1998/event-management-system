import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/pulsing_badge.dart';
import '../../../../data/model/event_model.dart';

import '../../../../widgets/cached_image.dart';

class AdminEventTile extends StatelessWidget {
  final EventModel event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback? onRegistrationsTap;

  const AdminEventTile({
    super.key,
    required this.event,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
    this.onRegistrationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: CachedImage(
                  url: event.images.isNotEmpty
                      ? event.images.first
                      : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: EventStatusBadge(status: event.status),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 16),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title.toUpperCase(),
                      style: AppTypography.headingSmall.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        shadows: [
                          const Shadow(color: Colors.black, blurRadius: 8),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          'Multiple Dates • ',
                          style: AppTypography.caption.copyWith(color: Colors.white70, fontSize: 11),
                        ),
                        Text(
                          '${event.location} 📍',
                          style: AppTypography.caption.copyWith(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ticket Sales', style: AppTypography.caption.copyWith(fontSize: 10)),
                            Text(
                              '${event.attendeesCount}',
                              style: AppTypography.headingSmall.copyWith(color: AppColors.accentGreen, fontSize: 16),
                            ),
                          ],
                        ),
                        const Icon(Icons.show_chart_rounded, color: AppColors.textMuted, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Checked In', style: AppTypography.caption.copyWith(fontSize: 10)),
                            Text(
                              '${(event.attendeesCount * 0.4).toInt()}',
                              style: AppTypography.headingSmall.copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                        const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppColors.border, height: 1),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(Icons.list_alt_rounded, 'Registrations', onRegistrationsTap ?? onTap),
                _buildActionItem(Icons.edit_note_rounded, 'Edit', onEdit),
                _buildActionItem(Icons.confirmation_number_outlined, 'Issue Ticket', onTap),
                _buildActionItem(Icons.delete_outline_rounded, 'Delete', onDelete, isDanger: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isDanger ? Colors.redAccent : AppColors.textSecondary, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 10,
              color: isDanger ? Colors.redAccent : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
