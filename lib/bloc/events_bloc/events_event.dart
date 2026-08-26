import 'package:equatable/equatable.dart';
import '../../data/model/event_model.dart';
import '../../services/enum.dart';

abstract class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class LoadEvents extends EventsEvent {}

class FilterEventsByStatus extends EventsEvent {
  final EventStatus status;

  const FilterEventsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class SearchEventsQueryChanged extends EventsEvent {
  final String query;

  const SearchEventsQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleEventInterested extends EventsEvent {
  final String eventId;

  const ToggleEventInterested(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

class CreateEventRequested extends EventsEvent {
  final EventModel event;

  const CreateEventRequested(this.event);

  @override
  List<Object?> get props => [event];
}

class UpdateEventRequested extends EventsEvent {
  final EventModel event;

  const UpdateEventRequested(this.event);

  @override
  List<Object?> get props => [event];
}

class DeleteEventRequested extends EventsEvent {
  final String eventId;

  const DeleteEventRequested(this.eventId);

  @override
  List<Object?> get props => [eventId];
}
