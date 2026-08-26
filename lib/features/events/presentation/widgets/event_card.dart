import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../bloc/events_bloc/events_bloc.dart';
import '../../../../bloc/events_bloc/events_event.dart';
import '../../../../data/model/event_model.dart';
import '../../../../services/enum.dart';
import '../../../../services/utils.dart';
import '../../../../widgets/cached_image.dart';

class EventCardWidget extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback? onToggleInterested;

  const EventCardWidget({
    super.key,
    required this.event,
    required this.onTap,
    this.onToggleInterested,
  });

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xffF2AF34);

    return Slidable(
      key: ValueKey(event.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.5,
        children: [
          SlidableAction(
            onPressed: (context) {
              if (onToggleInterested != null) {
                onToggleInterested!();
              } else {
                context.read<EventsBloc>().add(ToggleEventInterested(event.id));
              }
              Utils.showFlushBar(
                event.isInterested
                    ? "Removed from Interested"
                    : "Marked as Interested!",
                FlushBarType.success,
                context,
              );
            },
            backgroundColor: goldColor,
            foregroundColor: Colors.black,
            icon: event.isInterested
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: 'Interested',
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 8),
          SlidableAction(
            onPressed: (context) => onTap(),
            backgroundColor: goldColor,
            foregroundColor: Colors.black,
            icon: Icons.info_outline_rounded,
            label: 'Details',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff1E1E1E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x44F2AF34), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [

              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff2A2A2A), Color(0xff1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  children: [

                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CachedImage(
                        url: event.images.isNotEmpty
                            ? event.images.first
                            : 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
                        width: 90,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  event.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildStatusBadge(event.status),
                            ],
                          ),
                          const SizedBox(height: 6),
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
                                  event.location,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline_rounded,
                                color: Colors.white54,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "Organized by ${event.createdBy}",
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.people_rounded,
                                color: goldColor,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${event.attendeesCount} Attendees Registered",
                                style: const TextStyle(
                                  color: goldColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xff141414),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          color: goldColor,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.formatFullDate(event.startTime),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            event.isInterested
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: event.isInterested
                                ? Colors.redAccent
                                : goldColor,
                            size: 20,
                          ),
                          onPressed: () {
                            if (onToggleInterested != null) {
                              onToggleInterested!();
                            } else {
                              context.read<EventsBloc>().add(
                                ToggleEventInterested(event.id),
                              );
                            }
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: goldColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: onTap,
                          child: const Text(
                            "Event Details",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
          fontSize: 10,
        ),
      ),
    );
  }
}

typedef EventCard = EventCardWidget;
