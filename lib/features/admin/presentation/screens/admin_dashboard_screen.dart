import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../services/utils.dart';
import '../../../../services/enum.dart';
import '../../../../main.dart';
import '../../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../../bloc/auth_bloc/auth_event.dart';
import '../../../../bloc/events_bloc/events_bloc.dart';
import '../../../../bloc/events_bloc/events_event.dart';
import '../../../../bloc/events_bloc/events_state.dart';
import '../../../../data/model/user_model.dart';
import '../../../../data/model/event_model.dart';
import '../../../analytics/presentation/screens/analytics_screen.dart';
import '../../../events/presentation/screens/event_detail_screen.dart';
import '../../../events/presentation/widgets/live_insights_notifications_widget.dart';
import '../../../events/presentation/widgets/registrations_list_widget.dart';
import '../widgets/admin_event_tile.dart';
import '../widgets/revenue_dashboard_card.dart';
import 'create_edit_event_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserModel admin;

  const AdminDashboardScreen({super.key, required this.admin});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final ValueNotifier<int> currentScreenNotifier = ValueNotifier<int>(0);
  final ValueNotifier<List<String>> valueListNotifier = ValueNotifier(
    List.generate(12, (index) => "${index + 1}"),
  );
  final ValueNotifier<String> selectedValueNotifier = ValueNotifier(
    "${DateTime.now().month}",
  );
  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);
  String selectedType = "monthly";

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsBloc, EventsState>(
      builder: (context, state) {
        final allEvents = state is EventsLoaded
            ? state.allEvents
            : <EventModel>[];
        final totalRevenue = allEvents.fold<double>(
          0.0,
          (sum, e) => sum + (e.attendeesCount * e.price),
        );
        final totalAttendees = allEvents.fold<int>(
          0,
          (sum, e) => sum + e.attendeesCount,
        );
        final completedEventsCount = allEvents
            .where((e) => e.status == EventStatus.completed)
            .length;
        final interestedCount = allEvents.where((e) => e.isInterested).length;
        final visitsCount =
            (totalAttendees * 1.8).toInt() + (allEvents.isNotEmpty ? 45 : 0);
        final pageViewsCount =
            (totalAttendees * 2.5).toInt() + (allEvents.isNotEmpty ? 110 : 0);
        final revenueFormatted = NumberFormat.currency(
          symbol: '₹ ',
          decimalDigits: 0,
        ).format(totalRevenue);

        return Scaffold(
          backgroundColor: const Color(0xff1E1E1E),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Profile Bar matching Astro Dashboard Header
                ListTile(
                  tileColor: const Color(0xff2A2A2A),
                  title: Text(
                    widget.admin.name.isEmpty
                        ? 'Alex Mercer (Admin)'
                        : widget.admin.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    widget.admin.email.isEmpty
                        ? 'alex@admin.com'
                        : widget.admin.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.account_balance_wallet_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              revenueFormatted,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                        onPressed: () {
                          Utils.showLogoutDialog(
                            context,
                            onConfirmLogout: () {
                              context.read<AuthBloc>().add(
                                AuthLogoutRequested(),
                              );
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
                    ],
                  ),
                ),

                // Screen Content
                Expanded(
                  child: ValueListenableBuilder<int>(
                    valueListenable: currentScreenNotifier,
                    builder: (context, currentScreen, child) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<EventsBloc>().add(LoadEvents());
                          await Future.delayed(const Duration(seconds: 1));
                        },
                        color: const Color(0xffF2AF34),
                        backgroundColor: Colors.white,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (currentScreen == 0) ...[
                                // Create Event Action Button matching "Go Live"
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 4,
                                  ),
                                  icon: const Icon(
                                    Icons.add_circle_rounded,
                                    size: 22,
                                  ),
                                  label: const Text(
                                    "Create New Event +",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CreateEditEventScreen(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Online Toggle Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Live Platform Mode",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: isOnlineNotifier,
                                      builder: (context, isOnline, child) {
                                        return Switch(
                                          value: isOnline,
                                          activeThumbColor: const Color(
                                            0xffF2AF34,
                                          ),
                                          onChanged: (val) {
                                            isOnlineNotifier.value = val;
                                            Utils.showFlushBar(
                                              val
                                                  ? 'Platform Status: ONLINE'
                                                  : 'Platform Status: OFFLINE',
                                              val
                                                  ? FlushBarType.success
                                                  : FlushBarType.warn,
                                              context,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Filter Header: Your Dashboard + Monthly/Yearly Dropdown
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Your Dashboard",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 140,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff2A2A2A),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white12,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            dropdownColor: const Color(
                                              0xff2A2A2A,
                                            ),
                                            value: selectedType,
                                            icon: const Icon(
                                              Icons.calendar_month,
                                              color: Color(0xffF2AF34),
                                              size: 18,
                                            ),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                            items: const [
                                              DropdownMenuItem(
                                                value: "monthly",
                                                child: Text("Monthly"),
                                              ),
                                              DropdownMenuItem(
                                                value: "yearly",
                                                child: Text("Yearly"),
                                              ),
                                            ],
                                            onChanged: (value) {
                                              if (value == null) return;
                                              setState(() {
                                                selectedType = value;
                                                if (selectedType == "monthly") {
                                                  valueListNotifier.value =
                                                      List.generate(
                                                        12,
                                                        (index) =>
                                                            "${index + 1}",
                                                      );
                                                  selectedValueNotifier.value =
                                                      "${DateTime.now().month}";
                                                } else {
                                                  selectedValueNotifier.value =
                                                      "${DateTime.now().year}";
                                                  valueListNotifier
                                                      .value = List.generate(
                                                    DateTime.now().year - 2024,
                                                    (index) =>
                                                        "${2025 + index}",
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Horizontal Month / Year Selector Pills
                                SizedBox(
                                  height: 38,
                                  child: ValueListenableBuilder<List<String>>(
                                    valueListenable: valueListNotifier,
                                    builder: (context, list, child) {
                                      return ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: list.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(width: 8),
                                        itemBuilder: (context, index) {
                                          return ValueListenableBuilder<String>(
                                            valueListenable:
                                                selectedValueNotifier,
                                            builder: (context, selected, child) {
                                              final isSelected =
                                                  selected == list[index];
                                              final titleText =
                                                  selectedType == "monthly"
                                                  ? DateFormat("MMM").format(
                                                      DateTime(
                                                        DateTime.now().year,
                                                        int.parse(list[index]),
                                                      ),
                                                    )
                                                  : list[index];

                                              return GestureDetector(
                                                onTap: () {
                                                  selectedValueNotifier.value =
                                                      list[index];
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 8,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? const Color(
                                                            0xffF2AF34,
                                                          )
                                                        : const Color(
                                                            0xff2A2A2A,
                                                          ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      titleText,
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? Colors.black
                                                            : Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Revenue Card matching Astro Dashboard First Card
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff2A2A2A),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Text(
                                            "Live Revenue",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            "Details",
                                            style: TextStyle(
                                              color: Color(0xffF2AF34),
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                revenueFormatted,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "$totalAttendees total tickets sold\nacross all live events",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.08,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.white12,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Total Revenue",
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .monetization_on_rounded,
                                                      color: Color(0xffF2AF34),
                                                      size: 22,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      revenueFormatted,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Total Orders & Ratings Row matching Astro Dashboard Second Row
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff2A2A2A),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.white12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons
                                                      .confirmation_number_rounded,
                                                  color: Color(0xffF2AF34),
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Completed \nEvents",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.08,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "$completedEventsCount Completed",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff2A2A2A),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.white12,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons.star_rounded,
                                                  color: Colors.amber,
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Customer \nRatings",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.08,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "4.9 / 5 ⭐",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Real-time Event Insights
                                const LiveInsightsNotificationsWidget(),
                                const SizedBox(height: 16),

                                // Events List Header
                                const Text(
                                  "My Live Events (Firebase Sync)",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Real-time Events List from BLoC / Firestore
                                BlocBuilder<EventsBloc, EventsState>(
                                  builder: (context, state) {
                                    if (state is EventsLoading) {
                                      return const LoadingWidget(size: 40);
                                    } else if (state is EventsLoaded) {
                                      if (state.allEvents.isEmpty) {
                                        return const Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Center(
                                            child: Text(
                                              'No events found',
                                              style: TextStyle(
                                                color: Colors.white70,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: state.allEvents.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final event = state.allEvents[index];
                                          return AdminEventTile(
                                            event: event,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EventDetailScreen(
                                                        eventId: event.id,
                                                      ),
                                                ),
                                              );
                                            },
                                            onEdit: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      CreateEditEventScreen(
                                                        initialEvent: event,
                                                      ),
                                                ),
                                              );
                                            },
                                            onDelete: () {
                                              context.read<EventsBloc>().add(
                                                DeleteEventRequested(event.id),
                                              );
                                              Utils.showFlushBar(
                                                'Event deleted from Firebase',
                                                FlushBarType.warn,
                                                context,
                                              );
                                            },
                                          );
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ] else if (currentScreen == 1) ...[
                                // Events Tab
                                BlocBuilder<EventsBloc, EventsState>(
                                  builder: (context, state) {
                                    if (state is EventsLoaded) {
                                      return ListView.separated(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: state.allEvents.length,
                                        separatorBuilder: (context, index) =>
                                            const SizedBox(height: 10),
                                        itemBuilder: (context, index) {
                                          final event = state.allEvents[index];
                                          return AdminEventTile(
                                            event: event,
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EventDetailScreen(
                                                        eventId: event.id,
                                                      ),
                                                ),
                                              );
                                            },
                                            onEdit: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      CreateEditEventScreen(
                                                        initialEvent: event,
                                                      ),
                                                ),
                                              );
                                            },
                                            onDelete: () {
                                              context.read<EventsBloc>().add(
                                                DeleteEventRequested(event.id),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    }
                                    return const LoadingWidget(size: 40);
                                  },
                                ),
                              ] else if (currentScreen == 2) ...[
                                // Attendees Tab
                                const RegistrationsListWidget(),
                              ] else if (currentScreen == 3) ...[
                                // Revenue Tab
                                RevenueDashboardCard(
                                  totalRevenue: totalRevenue,
                                  soldCount: totalAttendees,
                                  checkedInCount: (totalAttendees * 0.65)
                                      .toInt(),
                                  interestedCount: interestedCount > 0
                                      ? interestedCount
                                      : (totalAttendees * 0.3).toInt(),
                                  visitsCount: visitsCount,
                                  pageViewsCount: pageViewsCount,
                                ),
                              ] else if (currentScreen == 4) ...[
                                // Analytics Tab
                                const AnalyticsScreen(),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Exact Bottom Navigation Bar matching HomeBar reference
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.85),
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: currentScreenNotifier,
              builder: (context, current, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AdminBottomItemWidget(
                      icon: Icons.dashboard_rounded,
                      title: "Home",
                      selected: current == 0,
                      onTap: () => currentScreenNotifier.value = 0,
                    ),
                    AdminBottomItemWidget(
                      icon: Icons.event_available_rounded,
                      title: "Events",
                      selected: current == 1,
                      onTap: () => currentScreenNotifier.value = 1,
                    ),
                    AdminBottomItemWidget(
                      icon: Icons.people_alt_rounded,
                      title: "Attendees",
                      selected: current == 2,
                      onTap: () => currentScreenNotifier.value = 2,
                    ),
                    AdminBottomItemWidget(
                      icon: Icons.account_balance_wallet_rounded,
                      title: "Revenue",
                      selected: current == 3,
                      onTap: () => currentScreenNotifier.value = 3,
                    ),
                    AdminBottomItemWidget(
                      icon: Icons.analytics_rounded,
                      title: "Analytics",
                      selected: current == 4,
                      onTap: () => currentScreenNotifier.value = 4,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class AdminBottomItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const AdminBottomItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xffF2AF34);
    final inactiveColor = activeColor.withValues(alpha: 0.6);

    return Expanded(
      child: InkWell(
        overlayColor: WidgetStateColor.resolveWith(
          (states) => Colors.transparent,
        ),
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
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
