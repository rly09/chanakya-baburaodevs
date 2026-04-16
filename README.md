# Chanakya Frontend

A Flutter application for Legal Intelligence, built to consume a FastAPI backend.

## Prerequisites
- Flutter SDK
- Android Emulator or Physical Device
- Python Backend running on port 8000

## Setup

1.  **Dependencies**:
    ```bash
    flutter pub get
    ```

2.  **Backend Connection**:
    - The app is configured to connect to `http://10.0.2.2:8000` (Android Emulator localhost).
    - If running on a physical device, update `baseUrl` in `lib/services/api_service.dart` to your machine's local IP (e.g., `http://192.168.1.x:8000`).

## Running the App

```bash
flutter run
```

## Features
- **Find Similar Cases**: Enter a case description to find precedents.
- **Win Probability**: See historical win/loss rates.
- **Act Trends**: View visualizations of case trends over time.
