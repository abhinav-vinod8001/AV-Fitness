# AV Fitness

A cross-platform strength training and workout tracking application built with **Flutter**, **Riverpod**, and **Firebase**, paired with a **Wear OS** health companion app.

## Features

- **Routine & Split Planning**: Build custom workout templates, organize routines into folders, map weekly training splits (`ScheduleBuilderTab`), and view sessions on an interactive calendar.
- **Live Active Workout Tracking**: Log sets, weight, and reps in real time with a built-in rest timer, lifecycle-safe state recovery (`WorkoutPersistenceService`), and a minimized active-workout banner.
- **Native Live Workout Experiences**:
  - **Android**: Ongoing workout foreground service notification (`WorkoutForegroundService`) with quick actions (`WorkoutActionReceiver`) plus 4 home screen widget sizes (`2x1`, `2x2`, `3x3`, `4x2`) via `home_widget`.
  - **iOS**: Lock Screen & Dynamic Island Live Activities (`WorkoutLiveActivity` in `iOS files/ios/WorkoutLiveActivity`).
- **315-Exercise Catalog & Search**: Pre-loaded exercise library across discrete muscle groups with anatomical visuals (`assets/images/anatomical/`), tokenized abbreviation search (`db press`, `ohp`, `rdl`), and custom exercise creation.
- **Progress Analytics & Tools**:
  - `fl_chart` visualizations: workout frequency heatmap, weekly volume, strength progression, and muscle group distribution.
  - Home dashboard cards: consistency rings, up-next routine, volume sparkline, and recent PRs.
  - Epley-formula **1RM Calculator** with percentage breakdowns, **Body Measurements** tracking, **Achievements**, **Weekly Recap**, and shareable **Profile Cards**.
- **AI Fitness Coach**: Context-aware coaching powered by the **Groq Chat Completions API** (using a user-supplied Groq API key in Settings) with automatic offline fallback tips.
- **Wear OS Companion (`wear_os_app`)**: Live heart rate (BPM) and skin temperature monitoring via Android Health Services, plus haptic feedback alerts.
- **Personalization & Sync**: Firebase Authentication (Email/Password & Google Sign-In), Cloud Firestore sync with scoped security rules, `kg`/`lbs` unit conversion, scheduled local notifications, and customizable light/dark Material themes.

## Tech Stack

- **Mobile / Client**: Flutter, Dart (`^3.12.1`)
- **State & Routing**: `flutter_riverpod`, `go_router`
- **Backend**: Firebase (`firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in`)
- **Charts & UI**: `fl_chart`, `google_fonts`, `screenshot`, `share_plus`
- **Notifications & Widgets**: `home_widget`, `flutter_local_notifications`, `timezone`, `shared_preferences`
- **AI Coaching**: Groq API via `http` (`openai/gpt-oss-20b` with `openai/gpt-oss-120b` fallback)
- **Wear OS**: Flutter + Kotlin (`androidx.health.services`, Wear OS 3.0+ / `minSdk 30`)

## Project Structure

```text
.
├── lib/
│   ├── core/            # Theme, colors, routes, 315-exercise catalog, services & utils
│   ├── models/          # User, exercise, workout, log, folder, measurement & coach models
│   ├── providers/       # Riverpod providers (auth, workouts, progress, AI coach, goals, etc.)
│   ├── repositories/    # Firestore data repositories
│   ├── screens/         # Home, workouts, active workout, progress, profile, calendar, tools
│   └── widgets/         # Shared UI components, modals, feed cards & banners
├── android/             # Android app, native home widgets & live workout foreground service
├── iOS files/ios/       # iOS Runner & WorkoutLiveActivity WidgetKit extension
├── wear_os_app/         # Companion Wear OS Flutter app & Health Services Kotlin bridge
├── assets/              # App icon, background & anatomical muscle group illustrations
├── test/                # Unit tests (exercise catalog & search verification)
├── firestore.rules      # Firestore schema validation & owner-scoped access rules
└── firestore.indexes.json
```

## Getting Started

### Prerequisites

- Flutter SDK (Dart `^3.12.1`)
- Android Studio / Xcode (for iOS builds, see `iOS files/ios/`)
- Firebase CLI & FlutterFire CLI (if connecting your own Firebase project)

### 1. Mobile App Setup

```bash
flutter pub get
```

If you are connecting your own Firebase project, configure FlutterFire and deploy the Firestore rules/indexes:

```bash
flutterfire configure
firebase deploy --only firestore:rules,firestore:indexes
```

Run or build a release APK:

```bash
flutter run
flutter build apk --release
```

### 2. AI Coach Setup (Optional)

1. Generate a free API key from [Groq Console](https://console.groq.com/).
2. Open **Profile → Settings** inside the app and enter your Groq API key.
3. Without an API key, the coach automatically falls back to offline training insights.

### 3. Wear OS Companion Setup

```bash
cd wear_os_app
flutter pub get
flutter run
```

> Requires a Wear OS 3.0+ (`minSdk 30`) device or emulator with body sensor / Health Services support.

## Testing

```bash
flutter test
```
