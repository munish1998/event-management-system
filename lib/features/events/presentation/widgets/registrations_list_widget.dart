import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../bloc/events_bloc/events_bloc.dart';
import '../../../../bloc/events_bloc/events_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../data/model/event_model.dart';
import '../../../../widgets/loading_widget.dart';

class AttendeeItem {
  final String name;
  final String ticketType;
  final String ticketCount;
  final bool isCheckedIn;
  final Color avatarColor;

  const AttendeeItem({
    required this.name,
    required this.ticketType,
    required this.ticketCount,
    required this.isCheckedIn,
    required this.avatarColor,
  });

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'U';
  }
}

class RegistrationsListWidget extends StatefulWidget {
  const RegistrationsListWidget({super.key});

  @override
  State<RegistrationsListWidget> createState() => _RegistrationsListWidgetState();
}

class _RegistrationsListWidgetState extends State<RegistrationsListWidget> {
  final ValueNotifier<int> selectedTabNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier<String>('');
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      searchQueryNotifier.value = searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    selectedTabNotifier.dispose();
    searchQueryNotifier.dispose();
    searchController.dispose();
    super.dispose();
  }

  List<AttendeeItem> _generateDynamicAttendees(List<EventModel> events, [String query = '']) {
    final List<AttendeeItem> list = [];
    final colors = [
      const Color(0xFFD946EF),
      const Color(0xFFF97316),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFFEC4899),
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
    ];

    final sampleNames = [
      'Sarah Johnson',
      'David Rodriguez',
      'Michael Thompson',
      'Jessica Davis',
      'Jennifer Garcia',
      'Alex Mercer',
      'Elena Rostova',
      'Rahul Sharma',
      'Priya Patel',
      'Chris Evans',
    ];

    var nameIndex = 0;
    for (final event in events) {
      final count = event.attendeesCount > 0 ? (event.attendeesCount > 5 ? 5 : event.attendeesCount) : 1;
      for (int i = 0; i < count; i++) {
        final name = sampleNames[nameIndex % sampleNames.length];
        final color = colors[nameIndex % colors.length];
        nameIndex++;

        list.add(
          AttendeeItem(
            name: name,
            ticketType: '${event.title} - Pass',
            ticketCount: '${i + 1}/$count',
            isCheckedIn: i % 2 == 0,
            avatarColor: color,
          ),
        );
      }
    }

    if (query.isNotEmpty) {
      return list.where((item) {
        return item.name.toLowerCase().contains(query) ||
            item.ticketType.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is! EventsLoaded) {
          return const Center(child: LoadingWidget(size: 32));
        }

        final events = state.allEvents;
        final totalAttendeesCount = events.fold<int>(0, (sum, e) => sum + e.attendeesCount);
        final checkInsCount = (totalAttendeesCount * 0.65).toInt();
        final leadsCount = (totalAttendeesCount * 1.4).toInt();

        return ValueListenableBuilder<String>(
          valueListenable: searchQueryNotifier,
          builder: (context, query, _) {
            final attendeesList = _generateDynamicAttendees(events, query);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

            ValueListenableBuilder<int>(
              valueListenable: selectedTabNotifier,
              builder: (context, selectedTab, child) {
                return Row(
                  children: [
                    _buildTab('Registrations ($totalAttendeesCount)', 0, selectedTab == 0, selectedTabNotifier),
                    _buildTab('Leads ($leadsCount)', 1, selectedTab == 1, selectedTabNotifier),
                    _buildTab('Check Ins ($checkInsCount)', 2, selectedTab == 2, selectedTabNotifier),
                  ],
                );
              },
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    style: AppTypography.bodyMedium.copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search Registrations or Events...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      fillColor: const Color(0xff2A2A2A),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xff2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (attendeesList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.people_outline_rounded, color: Colors.white38, size: 48),
                      const SizedBox(height: 10),
                      Text(
                        query.isEmpty ? "No registrations yet" : "No matching registrations found",
                        style: const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: attendeesList.length,
                itemBuilder: (context, index) {
                  final item = attendeesList[index];
                  final isHighlight = index == 0;

                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.95, end: 1.0),
                    duration: Duration(milliseconds: 200 + (index * 40)),
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: GlassContainer(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          borderColor: isHighlight ? AppColors.primary : Colors.white12,
                          boxShadow: isHighlight
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                          child: Row(
                            children: [

                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: item.avatarColor,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    item.initials,
                                    style: AppTypography.button.copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: AppTypography.headingSmall.copyWith(fontSize: 15, color: Colors.white),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.ticketType,
                                      style: AppTypography.caption.copyWith(color: Colors.white70),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Pass: ${item.ticketCount}',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.accentGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.5)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppColors.accentGreen, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      item.isCheckedIn ? 'In' : 'Pending',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.accentGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}

  Widget _buildTab(String title, int index, bool isSelected, ValueNotifier<int> notifier) {
    return Expanded(
      child: GestureDetector(
        onTap: () => notifier.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
