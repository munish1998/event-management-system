import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/model/event_model.dart';
import '../../../../services/enum.dart';
import '../../../../core/constants/mock_data.dart';
import 'events_event.dart';
import 'events_state.dart';

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc() : super(EventsInitial()) {
    on<LoadEvents>(_onLoadEvents);
    on<FilterEventsByStatus>(_onFilterEventsByStatus);
    on<SearchEventsQueryChanged>(_onSearchEventsQueryChanged);
    on<ToggleEventInterested>(_onToggleEventInterested);
    on<CreateEventRequested>(_onCreateEventRequested);
    on<UpdateEventRequested>(_onUpdateEventRequested);
    on<DeleteEventRequested>(_onDeleteEventRequested);
  }

  void _onLoadEvents(LoadEvents event, Emitter<EventsState> emit) {
    emit(EventsLoading());
    final allEvents = List<EventModel>.from(MockData.initialEvents);
    final filtered = allEvents
        .where((e) => e.status == EventStatus.upcoming)
        .toList();

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

  void _onToggleEventInterested(
    ToggleEventInterested event,
    Emitter<EventsState> emit,
  ) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      final updatedList = current.allEvents.map((e) {
        if (e.id == event.eventId) {
          final newInterested = !e.isInterested;
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

  void _onCreateEventRequested(
    CreateEventRequested event,
    Emitter<EventsState> emit,
  ) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
      final updatedList = [event.event, ...current.allEvents];
      final filtered = _filter(updatedList, current.selectedStatus, current.searchQuery);
      emit(current.copyWith(
        allEvents: updatedList,
        filteredEvents: filtered,
      ));
    }
  }

  void _onUpdateEventRequested(
    UpdateEventRequested event,
    Emitter<EventsState> emit,
  ) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
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

  void _onDeleteEventRequested(
    DeleteEventRequested event,
    Emitter<EventsState> emit,
  ) {
    if (state is EventsLoaded) {
      final current = state as EventsLoaded;
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
}
