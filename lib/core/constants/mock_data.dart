import '../../data/model/user_model.dart';
import '../../data/model/event_model.dart';
import '../../services/enum.dart';

class MockData {
  static const UserModel defaultUser = UserModel(
    id: 'usr_001',
    email: 'user@eventhub.com',
    name: 'Sarah Connor',
    role: UserRole.user,
  );

  static const UserModel defaultAdmin = UserModel(
    id: 'adm_001',
    email: 'alex@admin.com',
    name: 'Alex Mercer (Admin)',
    role: UserRole.admin,
  );

  static final List<EventModel> initialEvents = [
    EventModel(
      id: 'evt_101',
      title: 'Global Tech Summit 2026',
      description: 'Join industry visionaries for discussions on AI, Cloud Infrastructure, and Next-Gen Mobile Architecture. Features keynote speakers, live workshops, and networking lounge.',
      location: 'Silicon Convention Center, San Francisco',
      startTime: DateTime.now().add(const Duration(days: 3, hours: 4)),
      endTime: DateTime.now().add(const Duration(days: 3, hours: 10)),
      createdBy: 'alex@admin.com',
      images: [
        'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
        'https://images.unsplash.com/photo-1511578314322-379afb476865?w=800',
        'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=800',
      ],
      videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
      attendeesCount: 342,
      status: EventStatus.upcoming,
      isInterested: true,
    ),
    EventModel(
      id: 'evt_102',
      title: 'Cyberpunk Music Festival',
      description: 'An immersive audio-visual electronic music experience featuring top international DJs, laser shows, and futuristic stage designs.',
      location: 'Neon Arena, Los Angeles',
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(hours: 5)),
      createdBy: 'alex@admin.com',
      images: [
        'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=800',
        'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800',
        'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=800',
      ],
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      attendeesCount: 1280,
      status: EventStatus.ongoing,
      isInterested: false,
    ),
    EventModel(
      id: 'evt_103',
      title: 'UI/UX Design Masterclass & Hackathon',
      description: 'Hands-on design sprint covering Figma design systems, dark mode palettes, glassmorphic UI, and Flutter micro-animations.',
      location: 'Design Lab, New York',
      startTime: DateTime.now().add(const Duration(days: 8, hours: 2)),
      endTime: DateTime.now().add(const Duration(days: 8, hours: 8)),
      createdBy: 'alex@admin.com',
      images: [
        'https://images.unsplash.com/photo-1531403009284-440f080d1e12?w=800',
        'https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=800',
        'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?w=800',
      ],
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      attendeesCount: 185,
      status: EventStatus.upcoming,
      isInterested: true,
    ),
    EventModel(
      id: 'evt_104',
      title: 'AI Robotics & Automation Expo 2026',
      description: 'Exhibition of autonomous systems, spatial computing, humanoid robots, and deep learning implementations.',
      location: 'Tech Dome, Austin, TX',
      startTime: DateTime.now().subtract(const Duration(days: 5)),
      endTime: DateTime.now().subtract(const Duration(days: 4)),
      createdBy: 'alex@admin.com',
      images: [
        'https://images.unsplash.com/photo-1485827404703-89b55fcc595e?w=800',
        'https://images.unsplash.com/photo-1518770660439-4636190af475?w=800',
        'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=800',
      ],
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      attendeesCount: 950,
      status: EventStatus.completed,
      isInterested: false,
    ),
  ];
}
