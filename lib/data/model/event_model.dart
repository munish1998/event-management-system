import 'package:equatable/equatable.dart';
import '../../services/enum.dart';

class EventModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final String createdBy;
  final List<String> images;
  final String? videoUrl;
  final int attendeesCount;
  final double price;
  final EventStatus status;
  final bool isInterested;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.images,
    this.videoUrl,
    required this.attendeesCount,
    this.price = 299.0,
    required this.status,
    this.isInterested = false,
  });

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    String? createdBy,
    List<String>? images,
    String? videoUrl,
    int? attendeesCount,
    double? price,
    EventStatus? status,
    bool? isInterested,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdBy: createdBy ?? this.createdBy,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      attendeesCount: attendeesCount ?? this.attendeesCount,
      price: price ?? this.price,
      status: status ?? this.status,
      isInterested: isInterested ?? this.isInterested,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdBy': createdBy,
      'images': images,
      'videoUrl': videoUrl,
      'attendeesCount': attendeesCount,
      'price': price,
      'status': status.name,
      'isInterested': isInterested,
    };
  }

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      createdBy: json['createdBy'] ?? 'Admin',
      images: List<String>.from(json['images'] ?? []),
      videoUrl: json['videoUrl'],
      attendeesCount: json['attendeesCount'] ?? 0,
      price: (json['price'] != null) ? (json['price'] as num).toDouble() : 299.0,
      status: EventStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EventStatus.upcoming,
      ),
      isInterested: json['isInterested'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        location,
        startTime,
        endTime,
        createdBy,
        images,
        videoUrl,
        attendeesCount,
        price,
        status,
        isInterested,
      ];
}
