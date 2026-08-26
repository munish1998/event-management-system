# 🎟️ Real-Time Event Management System (Flutter + Firebase)

A modern, production-grade Flutter application featuring **Real-Time Synchronisation**, **Role-Based Access Control (Admin vs Attendee)**, **Multi-Media Upload with Compression**, **Offline Persistence**, and an **Ultra-Luxury Black & Gold Aesthetics**.

---

## 🌟 Key Features & Requirements Checklist

### 1. 🔐 Role-Based Authentication & Social Login
- **Email & Password Authentication**: Validated with strong regex checks (Upper/Lowercase, Digits, Special Characters).
- **Google Sign-In**: One-tap social authentication.
- **Dynamic Role Assignment**:
  - Accounts with emails ending in `@admin.com` automatically receive `Admin` permissions.
  - All other email domains are assigned the `User` (Attendee) role.
- **Isolated Loading States**: Button-specific indicators for seamless UX during auth operations.

---

### 2. 📅 Event Management Module & Categorisation
- **Category Tabs**:
  - 🟢 **Upcoming Events**
  - 🟡 **Ongoing Events**
  - ⚪ **Completed Events**
- **Rich Event Schema**:
  - `id`, `title`, `description`, `location`, `startTime`, `endTime`, `createdBy`
  - `images: List<String>`, `videoUrl: String?`, `attendeesCount: int`
  - `status: upcoming | ongoing | completed`, `isInterested: bool`
- **Admin-Exclusive Capabilities**:
  - ➕ Create new events with real-time stream publishing.
  - ✏️ Edit existing event information and media.
  - 🗑️ Delete events with immediate sync across all connected clients.
  - 📷 Multi-image upload (at least 3 images).
  - 🎬 Short video clips upload (max 15 seconds).

---

### 3. 📤 Media Upload & On-Device Compression
- **Firebase Storage Integration**: Media is uploaded directly to secure Firebase Storage buckets.
- **Multiple Image Picker**: Select and preview at least 3 images simultaneously.
- **Real-Time Upload Progress**: Visual percentage bar and indicators during upload.
- **Compression & Validation**:
  - Images compressed to under **300 KB**.
  - Videos validated under **15 seconds** and compressed under **5 MB**.
- **Interactive Video Player**: Integrated custom video player with play/pause, seek-bar, and full playback controls.

---

### 4. ⚡ Real-Time Firestore Synchronization & Offline Mode
- **Real-Time Stream Subscriptions**: Uses Firestore snapshots (`snapshots()`) so any admin create/update/delete action reflects on all attendee devices instantly.
- **Offline First**:
  - Firestore offline cache enabled (`PersistenceSettings(synchronizeTabs: true)`).
  - Queues operations locally when network is offline and automatically syncs when connection resumes.

---

### 5. 🔍 Advanced Event Detail Screen
- 🎠 **Interactive Image Carousel**: Smooth image slider with custom page indicators.
- ⏳ **Live Countdown Timer**: Real-time ticker counting down Days, Hours, Minutes, and Seconds until event start.
- ❤️ **"Mark Interested" Action**: Instant toggling with live count updates.
- 🎟️ **Pass Booking Modal**: Ticket counter, live price calculator, and instant booking pass generation with unique Booking IDs.

---

### 6. 📊 Real-Time Analytics Dashboard
- Live total revenue calculations and attendee numbers.
- Check-in ratios, page views, and engagement metrics.
- Visual revenue and category distribution charts.

---

## 🏗️ Architecture & State Management

This project follows **Clean Architecture** combined with **BLoC (Business Logic Component)** pattern for predictable state flow and separation of concerns.

```
lib/
├── bloc/                         # Business Logic Components
│   ├── auth_bloc/                # Auth state, events, and logic
│   └── events_bloc/              # Real-time event streams & mutations
├── core/                         # Core infrastructure
│   ├── constants/                # App colors (Black & Gold), typography, mock data
│   ├── theme/                    # Global dark theme configuration
│   ├── utils/                    # Date formatters & helpers
│   └── widgets/                  # Reusable UI (AppLogo, PulsingBadge, GlassContainer)
├── data/                         # Data layer
│   ├── model/                    # UserModel, EventModel, ImageModel
│   └── repository/               # Firebase Auth, Firestore, and Storage Repositories
├── features/                     # Feature modules
│   ├── admin/                    # Admin dashboard, event creation/edit, revenue cards
│   ├── analytics/                # Real-time charts and metrics
│   ├── auth/                     # Login, Signup, OTP, Role handling
│   ├── events/                   # User dashboard, event details, countdown, carousels
│   └── onboarding/               # Splash and onboarding screens
├── services/                     # Application services
│   ├── notification_service.dart # Local Push Notifications
│   └── utils.dart                # Top SnackBar FlushBar utilities
└── main.dart                     # App entry point & Bloc providers setup
```

---

## 🚀 Setup & Installation Instructions

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.12.0`)
- Android Studio / VS Code with Flutter extensions
- Android Device or Emulator / iOS Simulator

### 1. Clone the Repository
```bash
git clone https://github.com/munish1998/event-management-system.git
cd event-management-system
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Firebase Configuration
Firebase is already integrated via `google-services.json` (Android) and `firebase_options.dart`.
Ensure your Firebase project has:
- **Authentication**: Email/Password & Google Sign-In enabled.
- **Cloud Firestore**: Database created with default read/write rules.
- **Firebase Storage**: Default bucket enabled for media uploads.

### 4. Run the Application
```bash
# Debug Mode
flutter run

# Release Mode
flutter run --release
```

---

## 🔑 Test Credentials

| Role | Email | Password | Access Level |
| :--- | :--- | :--- | :--- |
| **Admin / Organizer** | `alex@admin.com` | `Admin@123` | Full CRUD, Media Upload, Revenue, Analytics |
| **Normal User** | `sarah@user.com` | `User@123` | Browse, Filter, Search, Mark Interested, Book Pass |

> 💡 *Any email ending in `@admin.com` registered in the app automatically gets Admin privileges.*

---

## 📱 Tech Stack & Packages

- **Framework**: Flutter 3.x (Dart 3.x)
- **State Management**: `flutter_bloc: ^9.1.1`
- **Backend & Cloud**: `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`
- **Social Login**: `google_sign_in: ^6.3.0`
- **Local Notifications**: `flutter_local_notifications: ^22.3.0`
- **Media**: `image_picker: ^1.1.2`, `video_player: ^2.9.2`
- **UI & Aesthetics**: `google_fonts: ^8.2.1`, `loading_animation_widget: ^1.3.0`, `another_flushbar: ^1.12.30`
