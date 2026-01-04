# Timebox AI

A minimalist, dark-themed timeboxing application built for macOS using Flutter. Designed to help you focus with a clean interface and essential timer features.

## Features

- **Focus Timer**: Set your desired duration and focus on your tasks.
- **Minimalist Design**: Dark mode UI with neon accents, frameless window, and reliable controls.
- **Smart Controls**:
  - Play/Pause/Stop functionality.
  - Interactive "Squircle" progress indicator.
  - Quick presets (5, 10, 15 minutes).
- **Draggable Window**: Custom draggable area (pan anywhere on the background).
- **Notifications**:
  - System-native macOS notifications upon completion.
  - Audio alert (plays system sound).
- **Flexible Input**: Click the timer text to edit duration directly (supports `HH:MM:SS` or minutes).
- **Background Support**: Timer continues accurately even when the app is in the background.

## Technology Stack

- **Framework**: Flutter (macOS Desktop)
- **State Management**: Provider
- **Window Management**: `window_manager`
- **Audio**: `audioplayers`
- **Notifications**: `flutter_local_notifications`

## specific Requirements

- macOS (Tested on macOS 14+)
- Flutter SDK

## Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/devmithunnath/timeboxai.git
   cd timeboxai
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run -d macos
   ```

## Development

The project structure is organized as follows:
- `lib/ui/`: Contains UI components and theme definitions.
- `lib/providers/`: State management logic for the timer.
- `lib/services/`: Services for notifications.
- `macos/`: Native macOS configuration files (Entitlements, Podfile).

## License

[MIT](LICENSE)