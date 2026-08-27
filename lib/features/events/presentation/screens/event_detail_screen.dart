import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/loading_widget.dart';
import '../../../../bloc/events_bloc/events_bloc.dart';
import '../../../../bloc/events_bloc/events_event.dart';
import '../../../../bloc/events_bloc/events_state.dart';
import '../../../../bloc/auth_bloc/auth_bloc.dart';
import '../../../../bloc/auth_bloc/auth_state.dart';
import '../../../../services/enum.dart';
import '../../../../services/utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/model/event_model.dart';
import '../../../../services/notification_service.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/image_carousel.dart';
import '../widgets/video_player_widget.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final ValueNotifier<Set<String>> registeredEventIdsNotifier = ValueNotifier<Set<String>>({});

  @override
  void dispose() {
    registeredEventIdsNotifier.dispose();
    super.dispose();
  }

  void _showRegistrationModal(BuildContext context, EventModel event) {
    const goldColor = Color(0xffF2AF34);
    final authState = context.read<AuthBloc>().state;
    final bool isAdmin =
        authState is Authenticated && authState.user.role == UserRole.admin;

    String userName = 'Attendee User';
    String userEmail = 'attendee@domain.com';

    if (authState is Authenticated && !isAdmin) {
      userName = authState.user.name.isNotEmpty
          ? authState.user.name
          : 'Attendee';
      userEmail = authState.user.email.isNotEmpty
          ? authState.user.email
          : 'user@domain.com';
    }

    final TextEditingController attendeeNameController =
        TextEditingController(text: isAdmin ? '' : userName);
    final TextEditingController attendeeEmailController =
        TextEditingController(text: isAdmin ? '' : userEmail);
    final ValueNotifier<int> ticketQuantityNotifier = ValueNotifier<int>(1);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return ValueListenableBuilder<int>(
          valueListenable: ticketQuantityNotifier,
          builder: (modalCtx, ticketQuantity, _) {
            final totalPrice = event.price * ticketQuantity;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isAdmin)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: goldColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: goldColor, width: 1),
                                ),
                                child: const Text(
                                  "ADMIN",
                                  style: TextStyle(
                                    color: goldColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            Text(
                              isAdmin
                                  ? "Issue Ticket to Attendee"
                                  : "Event Registration & Pass",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                          ),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    const SizedBox(height: 12),

                    // Event Summary Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xff2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: goldColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  event.location.isNotEmpty
                                      ? event.location
                                      : "Online / Venue",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      isAdmin ? "ATTENDEE DETAILS" : "YOUR DETAILS",
                      style: const TextStyle(
                        color: goldColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (isAdmin) ...[
                      TextField(
                        controller: attendeeNameController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Attendee Full Name (e.g. John Doe)',
                          hintStyle: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: goldColor,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xff2A2A2A),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: attendeeEmailController,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Attendee Email (e.g. attendee@mail.com)',
                          hintStyle: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: goldColor,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xff2A2A2A),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xff2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: goldColor,
                              radius: 18,
                              child: Text(
                                userName.isNotEmpty
                                    ? userName.substring(0, 1).toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    userEmail,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "PASS QUANTITY",
                              style: TextStyle(
                                color: goldColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "₹ ${event.price.toStringAsFixed(0)} / pass",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff2A2A2A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: ticketQuantity > 1
                                    ? () => ticketQuantityNotifier.value--
                                    : null,
                              ),
                              Text(
                                "$ticketQuantity",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: goldColor,
                                  size: 18,
                                ),
                                onPressed: ticketQuantity < 10
                                    ? () => ticketQuantityNotifier.value++
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount:",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          totalPrice == 0
                              ? "FREE"
                              : "₹ ${totalPrice.toStringAsFixed(0)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final String finalAttendeeName = isAdmin
                            ? (attendeeNameController.text.trim().isNotEmpty
                                ? attendeeNameController.text.trim()
                                : 'Registered Attendee')
                            : userName;

                        Navigator.pop(ctx);

                        if (!isAdmin) {
                          registeredEventIdsNotifier.value = {
                            ...registeredEventIdsNotifier.value,
                            event.id,
                          };
                        }

                        final updatedEvent = event.copyWith(
                          attendeesCount: event.attendeesCount + ticketQuantity,
                        );
                        context.read<EventsBloc>().add(
                          UpdateEventRequested(updatedEvent),
                        );

                        NotificationService().showInterestedNotification(event);

                        if (isAdmin) {
                          Utils.showFlushBar(
                            'Ticket successfully issued to $finalAttendeeName!',
                            FlushBarType.success,
                            context,
                          );
                        }

                        _showPassSuccessDialog(
                          context,
                          event,
                          finalAttendeeName,
                          ticketQuantity,
                          isAdmin: isAdmin,
                        );
                      },
                      child: Text(
                        isAdmin
                            ? "CONFIRM & ISSUE ATTENDEE PASS"
                            : "CONFIRM & GET DIGITAL PASS",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPassSuccessDialog(
    BuildContext context,
    EventModel event,
    String userName,
    int quantity, {
    bool isAdmin = false,
  }) {
    const goldColor = Color(0xffF2AF34);
    final bookingId =
        "EVENT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: const Color(0xff1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: goldColor, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0x2210B981),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xff10B981),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isAdmin ? "Ticket Issued Successfully!" : "Registration Confirmed!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin ? "Pass Generated • ID: $bookingId" : "Booking ID: $bookingId",
                  style: const TextStyle(
                    color: goldColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xff2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Event",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Attendee",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Passes Booked",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "$quantity Pass(es)",
                            style: const TextStyle(
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => Navigator.pop(dialogCtx),
                    child: const Text(
                      "CLOSE",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xffF2AF34);

    return Scaffold(
      backgroundColor: const Color(0xff0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xff0D0D0D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'EVENT DETAILS',
          style: TextStyle(
            color: goldColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          if (state is! EventsLoaded) {
            return const LoadingWidget(size: 40);
          }

          final eventList = state.allEvents
              .where((e) => e.id == widget.eventId)
              .toList();
          if (eventList.isEmpty) {
            return const Center(
              child: Text(
                'Event not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          final event = eventList.first;
          final isRegistered = registeredEventIdsNotifier.value.contains(event.id);
          final authState = context.read<AuthBloc>().state;
          final bool isAdmin =
              authState is Authenticated && authState.user.role == UserRole.admin;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 12,
                  bottom: 100,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xff1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x44F2AF34)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ImageCarouselWidget(
                          images: event.images,
                          height: 250,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(event.status),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: goldColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: goldColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.confirmation_number_rounded,
                            color: goldColor,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event.price == 0
                                ? "Entry: FREE"
                                : "Ticket Price: ₹ ${event.price.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: goldColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xff1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: goldColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Location: ${event.location}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                color: goldColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Organized by: ${event.createdBy}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white12, height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.people_rounded,
                                color: goldColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Attendees: ${event.attendeesCount} Registered",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "EVENT COUNTDOWN",
                      style: TextStyle(
                        color: goldColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CountdownTimerWidget(targetDate: event.startTime),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xff1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            color: goldColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Start Time",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                DateFormatter.formatFullDate(event.startTime),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (event.videoUrl != null &&
                        event.videoUrl!.isNotEmpty) ...[
                      const Text(
                        "EVENT VIDEO PREVIEW",
                        style: TextStyle(
                          color: goldColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      VideoPlayerWidget(videoUrl: event.videoUrl),
                      const SizedBox(height: 20),
                    ],

                    const Text(
                      "ABOUT THIS EVENT",
                      style: TextStyle(
                        color: goldColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description.isNotEmpty
                          ? event.description
                          : "Join us for an exciting real-time event experience featuring live Q&A, keynote speakers, interactive sessions, and networking.",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  children: [

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: event.isInterested
                              ? Colors.redAccent
                              : Colors.white24,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          event.isInterested
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: event.isInterested
                              ? Colors.redAccent
                              : Colors.white70,
                          size: 22,
                        ),
                        onPressed: () {
                          context.read<EventsBloc>().add(
                            ToggleEventInterested(event.id),
                          );
                          Utils.showFlushBar(
                            event.isInterested
                                ? "Removed from Interested"
                                : "Marked as Interested!",
                            FlushBarType.success,
                            context,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isAdmin
                              ? goldColor
                              : (isRegistered
                                  ? const Color(0xff10B981)
                                  : goldColor),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        icon: Icon(
                          isAdmin
                              ? Icons.confirmation_number_rounded
                              : (isRegistered
                                  ? Icons.check_circle_rounded
                                  : Icons.confirmation_number_rounded),
                          size: 20,
                          color: (!isAdmin && isRegistered)
                              ? Colors.white
                              : Colors.black,
                        ),
                        label: Text(
                          isAdmin
                              ? "ISSUE ATTENDEE TICKET • ₹ ${event.price.toStringAsFixed(0)}"
                              : (isRegistered
                                  ? "REGISTERED (VIEW PASS)"
                                  : event.price == 0
                                      ? "REGISTER NOW (FREE)"
                                      : "REGISTER NOW • ₹ ${event.price.toStringAsFixed(0)}"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            color: (!isAdmin && isRegistered)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        onPressed: () {
                          _showRegistrationModal(context, event);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(EventStatus status) {
    Color badgeColor = Colors.green;
    String statusText = "UPCOMING";

    if (status == EventStatus.ongoing) {
      badgeColor = Colors.orangeAccent;
      statusText = "ONGOING";
    } else if (status == EventStatus.completed) {
      badgeColor = Colors.blueAccent;
      statusText = "COMPLETED";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        border: Border.all(color: badgeColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
