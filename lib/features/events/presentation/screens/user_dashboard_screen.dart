import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../../bloc/auth_bloc/auth_event.dart';
import '../../../../bloc/events_bloc/events_bloc.dart';
import '../../../../bloc/events_bloc/events_event.dart';
import '../../../../bloc/events_bloc/events_state.dart';
import '../../../../data/model/user_model.dart';
import '../../../../data/model/event_model.dart';
import '../../../../services/enum.dart';
import '../../../../services/utils.dart';
import '../../../../services/notification_service.dart';
import '../../../../main.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  final UserModel user;

  const UserDashboardScreen({super.key, required this.user});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  static const Color goldColor = Color(0xffF2AF34);
  final ValueNotifier<int> currentTabNotifier = ValueNotifier<int>(0);
  final ValueNotifier<String> categoryFilterNotifier = ValueNotifier<String>(
    'ALL',
  );
  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    currentTabNotifier.dispose();
    categoryFilterNotifier.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xff0D0D0D),
        elevation: 0,
        title: ValueListenableBuilder<int>(
          valueListenable: currentTabNotifier,
          builder: (context, currentTab, _) {
            String title = 'EVENT PORTAL';
            if (currentTab == 1) title = 'MY INTERESTED EVENTS';
            if (currentTab == 2) title = 'MY PROFILE';

            return Text(
              title,
              style: const TextStyle(
                color: goldColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                letterSpacing: 1.2,
              ),
            );
          },
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xff2A2A2A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: goldColor, width: 1),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person_outline_rounded,
                  color: goldColor,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.user.name.isEmpty
                      ? 'USER'
                      : widget.user.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () {
              Utils.showLogoutDialog(
                context,
                onConfirmLogout: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                  Utils.showFlushBar(
                    'Logged out successfully',
                    FlushBarType.success,
                    context,
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthWrapper()),
                    (route) => false,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: currentTabNotifier,
          builder: (context, currentTab, _) {
            if (currentTab == 0) {
              return _buildEventsTab(goldColor);
            } else if (currentTab == 1) {
              return _buildInterestedTab(goldColor);
            } else {
              return _buildProfileTab(goldColor);
            }
          },
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.95),
          border: const Border(
            top: BorderSide(color: Color(0x33F2AF34), width: 1),
          ),
        ),
        child: ValueListenableBuilder<int>(
          valueListenable: currentTabNotifier,
          builder: (context, current, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  Icons.event_rounded,
                  "Events",
                  current == 0,
                  () => currentTabNotifier.value = 0,
                ),
                _buildNavItem(
                  Icons.favorite_rounded,
                  "Interested",
                  current == 1,
                  () => currentTabNotifier.value = 1,
                ),
                _buildNavItem(
                  Icons.person_rounded,
                  "Profile",
                  current == 2,
                  () => currentTabNotifier.value = 2,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Tab 0: All Live Events
  Widget _buildEventsTab(Color goldColor) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<EventsBloc>().add(LoadEvents());
        await Future.delayed(const Duration(seconds: 1));
      },
      color: goldColor,
      backgroundColor: Colors.black,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 14,
          right: 14,
          top: 12,
          bottom: 90,
        ),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Search Bar
            TextField(
              controller: searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (val) {
                context.read<EventsBloc>().add(SearchEventsQueryChanged(val));
              },
              decoration: InputDecoration(
                hintText: 'Search upcoming, ongoing, completed events...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: goldColor),
                fillColor: const Color(0xff1E1E1E),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0x55F2AF34)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0x55F2AF34)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: goldColor),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Filter Pills
            ValueListenableBuilder<String>(
              valueListenable: categoryFilterNotifier,
              builder: (context, selectedCategory, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterCategoryPill(
                        'ALL',
                        'All Events',
                        Icons.event_available_rounded,
                        selectedCategory,
                      ),
                      _buildFilterCategoryPill(
                        'UPCOMING',
                        'Upcoming Events',
                        Icons.upcoming_rounded,
                        selectedCategory,
                      ),
                      _buildFilterCategoryPill(
                        'ONGOING',
                        'Ongoing Events',
                        Icons.play_circle_fill_rounded,
                        selectedCategory,
                      ),
                      _buildFilterCategoryPill(
                        'COMPLETED',
                        'Completed Events',
                        Icons.task_alt_rounded,
                        selectedCategory,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Hero Banner Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff2A2A2A), Color(0xff1A1A1A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x44F2AF34)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Real-Time Event Portal",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Discover live tech summits, music festivals & workshops in real-time.",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.explore_rounded, size: 16),
                          label: const Text(
                            "Explore All",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            categoryFilterNotifier.value = 'ALL';
                            context.read<EventsBloc>().add(LoadEvents());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: goldColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.event_rounded,
                      color: Colors.black,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Event List
            ValueListenableBuilder<String>(
              valueListenable: categoryFilterNotifier,
              builder: (context, selectedCategory, child) {
                return BlocBuilder<EventsBloc, EventsState>(
                  builder: (context, state) {
                    if (state is EventsLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: LoadingWidget(size: 40),
                      );
                    } else if (state is EventsLoaded) {
                      List<EventModel> filtered = List<EventModel>.from(
                        state.allEvents,
                      );

                      // Apply search query if present
                      if (searchController.text.trim().isNotEmpty) {
                        final q = searchController.text.trim().toLowerCase();
                        filtered = filtered.where((e) {
                          return e.title.toLowerCase().contains(q) ||
                              e.location.toLowerCase().contains(q) ||
                              e.description.toLowerCase().contains(q);
                        }).toList();
                      }

                      // Apply Category Filter
                      if (selectedCategory == 'UPCOMING') {
                        filtered = filtered
                            .where((e) => e.status == EventStatus.upcoming)
                            .toList();
                      } else if (selectedCategory == 'ONGOING') {
                        filtered = filtered
                            .where((e) => e.status == EventStatus.ongoing)
                            .toList();
                      } else if (selectedCategory == 'COMPLETED') {
                        filtered = filtered
                            .where((e) => e.status == EventStatus.completed)
                            .toList();
                      }

                      if (filtered.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(40),
                          alignment: Alignment.center,
                          child: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                color: Colors.white38,
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No events found in this category.',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          final event = filtered[index];
                          return EventCardWidget(
                            event: event,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailScreen(eventId: event.id),
                                ),
                              );
                            },
                            onToggleInterested: () {
                              context.read<EventsBloc>().add(
                                ToggleEventInterested(event.id),
                              );
                            },
                          );
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Tab 1: Interested Events
  Widget _buildInterestedTab(Color goldColor) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return const Center(child: LoadingWidget(size: 40));
        } else if (state is EventsLoaded) {
          final interestedEvents = state.allEvents
              .where((e) => e.isInterested)
              .toList();

          if (interestedEvents.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xff1E1E1E),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x33F2AF34)),
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white38,
                        size: 54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "No Interested Events Yet",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Mark events as interested on the dashboard to track them here in real-time.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.explore_rounded, size: 18),
                      label: const Text(
                        "Browse Events",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => currentTabNotifier.value = 0,
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(
              left: 14,
              right: 14,
              top: 16,
              bottom: 90,
            ),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SAVED EVENTS (${interestedEvents.length})",
                  style: TextStyle(
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: interestedEvents.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final event = interestedEvents[index];
                    return EventCardWidget(
                      event: event,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EventDetailScreen(eventId: event.id),
                          ),
                        );
                      },
                      onToggleInterested: () {
                        context.read<EventsBloc>().add(
                          ToggleEventInterested(event.id),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Tab 2: User Profile Screen
  Widget _buildProfileTab(Color goldColor) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final allEvents = state is EventsLoaded
            ? state.allEvents
            : <EventModel>[];
        final interestedCount = allEvents.where((e) => e.isInterested).length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // User Card Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff2A2A2A), Color(0xff1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x44F2AF34)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // User Avatar with Golden Ring
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: goldColor, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xff333333),
                        child: Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name.substring(0, 1).toUpperCase()
                              : 'U',
                          style: TextStyle(
                            color: goldColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.user.name.isNotEmpty
                          ? widget.user.name
                          : 'Event Attendee',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.email.isNotEmpty
                          ? widget.user.email
                          : 'user@domain.com',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: goldColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: goldColor,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "ROLE: USER (Standard Access)",
                            style: TextStyle(
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Activity Stats Row
              Row(
                children: [
                  Expanded(
                    child: _buildProfileStatCard(
                      title: "INTERESTED",
                      value: "$interestedCount",
                      subtitle: "Saved Events",
                      icon: Icons.favorite_rounded,
                      color: goldColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildProfileStatCard(
                      title: "AVAILABLE",
                      value: "${allEvents.length}",
                      subtitle: "Live Events",
                      icon: Icons.event_available_rounded,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Account Options List
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xff1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    _buildProfileOptionTile(
                      icon: Icons.favorite_rounded,
                      title: "My Saved Events",
                      subtitle: "Quick access to your interested events",
                      onTap: () => currentTabNotifier.value = 1,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _buildProfileOptionTile(
                      icon: Icons.notifications_active_rounded,
                      title: "Test Push Notification",
                      subtitle: "Tap to test instant phone notification alert",
                      onTap: () {
                        NotificationService().showTestNotification();
                        Utils.showFlushBar(
                          "Triggered test push notification!",
                          FlushBarType.success,
                          context,
                        );
                      },
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _buildProfileOptionTile(
                      icon: Icons.cloud_done_rounded,
                      title: "Offline Sync Status",
                      subtitle: "Local caching enabled for offline support",
                      onTap: () {
                        Utils.showFlushBar(
                          "Offline data caching is active",
                          FlushBarType.success,
                          context,
                        );
                      },
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    _buildProfileOptionTile(
                      icon: Icons.security_rounded,
                      title: "Role-Based Access",
                      subtitle: "Standard user permissions verified",
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2A2A2A),
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.redAccent, width: 1),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    "LOGOUT FROM ACCOUNT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 1,
                    ),
                  ),
                  onPressed: () {
                    Utils.showLogoutDialog(
                      context,
                      onConfirmLogout: () {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        Utils.showFlushBar(
                          'Logged out successfully',
                          FlushBarType.success,
                          context,
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AuthWrapper(),
                          ),
                          (route) => false,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xff2A2A2A),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xffF2AF34), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 11),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white38,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFilterCategoryPill(
    String code,
    String label,
    IconData icon,
    String selectedCategory,
  ) {
    final bool isSelected = selectedCategory == code;
    const goldColor = Color(0xffF2AF34);

    return GestureDetector(
      onTap: () {
        categoryFilterNotifier.value = code;
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? goldColor : const Color(0xff1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: goldColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.black : goldColor, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String title,
    bool selected,
    VoidCallback onTap,
  ) {
    const activeColor = Color(0xffF2AF34);
    final inactiveColor = activeColor.withValues(alpha: 0.6);

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: selected ? activeColor : inactiveColor),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected ? activeColor : inactiveColor,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
