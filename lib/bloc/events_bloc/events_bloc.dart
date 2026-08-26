import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/mock_data.dart';
import '../../data/model/event_model.dart';
import '../../data/repository/events_repository.dart';
import '../../services/enum.dart';
import '../../services/notification_service.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  final EventsRepository? eventsRepository;
  StreamSubscription<List<EventModel>>? _eventsSubscription;
  Timer? _reminderPeriodicTimer;
  final Set<String> _knownEventIds = {};
  final Map<String, EventStatus> _knownEventStatuses = {};

  EventsBloc({this.eventsRepository}) : super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<FilterEventsByStatus>(_onFilterEventsByStatus);
    on<SearchEventsQueryChanged>(_onSearchEventsQueryChanged);
    on<ToggleEventInterested>(_onToggleEventInterested);
    on<CreateEventRequested>(_onCreateEventRequested);
    on<UpdateEventRequested>(_onUpdateEventRequested);
    on<DeleteEventRequested>(_onDeleteEventRequested);

    _reminderPeriodicTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (state is EventsLoaded) {
        NotificationService().checkAndTriggerUpcomingReminders((state as EventsLoaded).allEvents);
      }
    });
  }

  Future<void> _onLoadEvents(LoadEvents event, Emitter<EventsState> emit) async {
    emit(EventsLoading());

    if (eventsRepository != null) {
      try {
        await emit.onEach<List<EventModel>>(
          eventsRepository!.getEventsStream(),
          onData: (eventsList) {
            final eventsToUse = eventsList.isEmpty ? MockData.initialEvents : eventsList;
            final currentStatus = state is EventsLoaded ? (state as EventsLoaded).selectedStatus : EventStatus.upcoming;
            final currentQuery = state is EventsLoaded ? (state as EventsLoaded).searchQuery : '';
            final filtered = _filter(eventsToUse, currentStatus, currentQuery);

            _checkAndNotifyChanges(eventsToUse);

            NotificationService().checkAndTriggerUpcomingReminders(eventsToUse);

            emit(EventsLoaded(
              allEvents: eventsToUse,
              filteredEvents: filtered,
              selectedStatus: currentStatus,
              searchQuery: currentQuery,
            ));
          },
          onError: (error, stackTrace) {
            _loadLocalMock(emit);
          },
        );
        return;
      } catch (_) {
        _loadLocalMock(emit);
        return;
      }
    }

    _loadLocalMock(emit);
  }

  void _checkAndNotifyChanges(List<EventModel> currentEvents) {

    if (_knownEventIds.isEmpty) {
      for (final e in currentEvents) {
        _knownEventIds.add(e.id);
        _knownEventStatuses[e.id] = e.status;
      }
      return;
    }

    for (final e in currentEvents) {

      if (!_knownEventIds.contains(e.id)) {
        _knownEventIds.add(e.id);
        _knownEventStatuses[e.id] = e.status;
        NotificationService().showNewEventNotification(e);
      } else {

        final oldStatus = _knownEventStatuses[e.id];
        if (oldStatus != null && oldStatus != EventStatus.ongoing && e.status == EventStatus.ongoing) {
          NotificationService().showEventLiveNotification(e);
        }
        _knownEventStatuses[e.id] = e.status;
      }
    }
  }

  void _loadLocalMock(Emitter<EventsState> emit) {
    final allEvents = List<EventModel>.from(MockData.initialEvents);
    final filtered = allEvents.where((e) => e.status == EventStatus.upcoming).toList();

    for (final e in allEvents) {
      _knownEventIds.add(e.id);
      _knownEventStatuses[e.id] = e.status;
    }

    emit(EventsLoaded(
      allEvents: allEvents,
      filteredEvents: filtered,
      selectedStatus: EventStatus.upcoming,
    ));
  }

  void _onFilterEventsByStatus(
    FilterEventsByStatus event,
    Emitter<EventsState> emit,
  ) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      final filtered = _filter(current.allEvents, event.status, current.searchQuery);
      emit(current.copyWith(
        selectedStatus: event.status,
        filteredEvents: filtered,
      ));
    }
  }

  void _onSearchEventsQueryChanged(
    SearchEventsQueryChanged event,
    Emitter<EventsState> emit,
  ) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      final filtered = _filter(current.allEvents, current.selectedStatus, event.query);
      emit(current.copyWith(
        searchQuery: event.query,
        filteredEvents: filtered,
      ));
    }
  }

  Future<void> _onToggleEventInterested(
    ToggleEventInterested event,
    Emitter<EventsState> emit,
  ) async {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      final targetEvent = current.allEvents.firstWhere(
        (e) => e.id == event.eventId,
        orElse: () => current.allEvents.first,
      );

      try {
        await eventsRepository?.toggleInterested(
          event.eventId,
          targetEvent.isInterested,
          targetEvent.attendeesCount,
        );
      } catch (_) {}

      final newInterested = !targetEvent.isInterested;
      if (newInterested) {
        NotificationService().showInterestedNotification(targetEvent);
      }

      final updatedList = current.allEvents.map((e) {
        if (e.id == event.eventId) {
          return e.copyWith(
            isInterested: newInterested,
            attendeesCount: newInterested ? e.attendeesCount + 1 : e.attendeesCount - 1,
          );
        }
        return e;
      }).toList();

      final filtered = _filter(updatedList, current.selectedStatus, current.searchQuery);
      emit(current.copyWith(
        allEvents: updatedList,
        filteredEvents: filtered,
      ));
    }
  }

  Future<void> _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventsState> emit,
  ) async {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      try {
        await eventsRepository?.createEvent(event.event);
      } catch (_) {}

      _knownEventIds.add(event.event.id);
      _knownEventStatuses[event.event.id] = event.event.status;
      NotificationService().showNewEventNotification(event.event);

      final updatedList = [event.event, ...current.allEvents];
      final filtered = _filter(updatedList, current.selectedStatus, current.searchQuery);
      emit(current.copyWith(
        allEvents: updatedList,
        filteredEvents: filtered,
      ));
    }
  }

  Future<void> _onUpdateEventRequested(
    UpdateEventRequested event,
    Emitter<EventsState> emit,
  ) async {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      try {
        await eventsRepository?.updateEvent(event.event);
      } catch (_) {}

      final oldStatus = _knownEventStatuses[event.event.id];
      if (oldStatus != EventStatus.ongoing && event.event.status == EventStatus.ongoing) {
        NotificationService().showEventLiveNotification(event.event);
      }
      _knownEventStatuses[event.event.id] = event.event.status;

      final updatedList = current.allEvents.map((e) {
        return e.id == event.event.id ? event.event : e;
      }).toList();
      final filtered = _filter(updatedList, current.selectedStatus, current.searchQuery);
      emit(current.copyWith(
        allEvents: updatedList,
        filteredEvents: filtered,
      ));
    }
  }

  Future<void> _onDeleteEventRequested(
    DeleteEventRequested event,
    Emitter<EventsState> emit,
  ) async {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      try {
        await eventsRepository?.deleteEvent(event.eventId);
      } catch (_) {}

      _knownEventIds.remove(event.eventId);
      _knownEventStatuses.remove(event.eventId);

      final updatedList = current.allEvents.where((e) => e.id != event.eventId).toList();
      final filtered = _filter(updatedList, current.selectedStatus, current.searchQuery);
      emit(current.copyWith(
        allEvents: updatedList,
        filteredEvents: filtered,
      ));
    }
  }

  List<EventModel> _filter(
    List<EventModel> events,
    EventStatus status,
    String query,
  ) {
    final q = query.trim().toLowerCase();
    return events.where((e) {
      final matchesStatus = e.status == status;
      final matchesQuery = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.location.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  @override
  Future<void> close() {
    _reminderPeriodicTimer?.cancel();
    _eventsSubscription?.cancel();
    return super.close();
  }
}
