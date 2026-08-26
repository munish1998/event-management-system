import 'package:equatable/equatable.dart';
import '../../../../data/model/event_model.dart';
import '../../../../services/enum.dart';

abstract class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<EventModel> allEvents;
  final List<EventModel> filteredEvents;
  final EventStatus selectedStatus;
  final String searchQuery;

  const EventsLoaded({
    required this.allEvents,
    required this.filteredEvents,
    required this.selectedStatus,
    this.searchQuery = '',
  });

  int get upcomingCount => allEvents.where((e) => e.status == EventStatus.upcoming).length;
  int get ongoingCount => allEvents.where((e) => e.status == EventStatus.ongoing).length;
  int get completedCount => allEvents.where((e) => e.status == EventStatus.completed).length;
  int get totalAttendees => allEvents.fold(0, (sum, e) => sum + e.attendeesCount);

  EventsLoaded copyWith({
    List<EventModel>? allEvents,
    List<EventModel>? filteredEvents,
    EventStatus? selectedStatus,
    String? searchQuery,
  }) {
    return EventsLoaded(
      allEvents: allEvents ?? this.allEvents,
      filteredEvents: filteredEvents ?? this.filteredEvents,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [allEvents, filteredEvents, selectedStatus, searchQuery];
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);

  @override
  List<Object?> get props => [message];
}
