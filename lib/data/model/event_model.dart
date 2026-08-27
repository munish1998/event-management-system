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

  static const List<String> defaultEventImages = [
    'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
    'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800',
    'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800',
    'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
    'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800',
    'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800',
    'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
  ];

  static const List<String> defaultSampleVideos = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
    'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  ];

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final eventId = json['id'] ?? '';
    final eventTitle = json['title'] ?? '';
    final hash = (eventId + eventTitle).hashCode.abs();

    final rawImages = List<String>.from(json['images'] ?? []);
    final validImages = rawImages.where((img) => img.trim().isNotEmpty).toList();

    final List<String> finalImages = validImages.isNotEmpty
        ? validImages
        : [
            defaultEventImages[hash % defaultEventImages.length],
            defaultEventImages[(hash + 1) % defaultEventImages.length],
            defaultEventImages[(hash + 2) % defaultEventImages.length],
          ];

    final rawVideo = json['videoUrl'] as String?;
    final String video = (rawVideo != null && rawVideo.trim().isNotEmpty)
        ? rawVideo
        : defaultSampleVideos[hash % defaultSampleVideos.length];

    return EventModel(
      id: eventId,
      title: eventTitle,
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : DateTime.now(),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : DateTime.now().add(const Duration(hours: 4)),
      createdBy: json['createdBy'] ?? 'Admin',
      images: finalImages,
      videoUrl: video,
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
