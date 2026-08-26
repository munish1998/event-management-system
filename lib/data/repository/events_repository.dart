import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/event_model.dart';

class EventsRepository {
  final FirebaseFirestore _firestore;

  EventsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _eventsCollection =>
      _firestore.collection('events');

  Stream<List<EventModel>> getEventsStream() {
    return _eventsCollection
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EventModel.fromJson(data);
      }).toList();
    });
  }

  Future<List<EventModel>> fetchEvents() async {
    final snapshot = await _eventsCollection.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return EventModel.fromJson(data);
    }).toList();
  }

  Future<void> createEvent(EventModel event) async {
    await _eventsCollection.doc(event.id).set(event.toJson());
  }

  Future<void> updateEvent(EventModel event) async {
    await _eventsCollection.doc(event.id).update(event.toJson());
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsCollection.doc(eventId).delete();
  }

  Future<void> toggleInterested(String eventId, bool currentInterested, int currentCount) async {
    final newInterested = !currentInterested;
    final newCount = newInterested ? currentCount + 1 : (currentCount > 0 ? currentCount - 1 : 0);

    await _eventsCollection.doc(eventId).update({
      'isInterested': newInterested,
      'attendeesCount': newCount,
    });
  }
}
