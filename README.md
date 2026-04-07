# PokeAPI Flutter App

A modern Flutter application designed to explore the world of Pokémon using the PokeAPI. This app provides a rich user experience for browsing Pokémon, viewing detailed information, managing favorites, and organizing Pokémon by various categories like generations, types, and legendaries.

## Features

*   **Comprehensive Pokémon Listings:** Browse through all available Pokémon.
*   **Detailed Pokémon Profiles:** View extensive information for each Pokémon, including stats, abilities, types, and more.
*   **Favorites Management:** Mark and manage your favorite Pokémon for quick access.
*   **Categorized Exploration:** Explore Pokémon by generations, types, and legendary status.
*   **Pokémon Team Management:** Create and manage custom Pokémon teams.
*   **Locations Viewer:** Discover various Pokémon-related locations.
*   **Offline Data Access:** Utilizes a local database for efficient data caching and offline capabilities.
*   **Smooth User Interface:** Built with Flutter, featuring animations and a clean design.

## Technologies Used

*   **Flutter & Dart:** The core framework for building cross-platform applications.
*   **Dio:** A powerful HTTP client for making API requests to PokeAPI.
*   **Go Router:** Declarative routing solution for seamless navigation within the app.
*   **Isar Database:** A fast, cross-platform NoSQL database for local data storage and caching.
*   **Riverpod & Flutter Hooks:** Robust state management and utility hooks for reactive UIs.
*   **Freezed & JSON Serializable:** Code generation for immutable data models and JSON serialization/deserialization.
*   **Cached Network Image:** Efficiently loads and caches images from the network.
*   **Flutter Animate:** Provides easy-to-use animations for a dynamic user experience.
*   **Google Fonts:** Custom typography for enhanced aesthetics.
*   **Pull to Refresh:** Modern pull-to-refresh functionality for list views.

## Installation

To get a copy of the project up and running on your local machine for development and testing purposes, follow these steps.

### Prerequisites

*   **Flutter SDK:** Make sure you have the Flutter SDK installed. Follow the official Flutter installation guide: [Flutter Install](https://flutter.dev/docs/get-started/install)
*   **Dart SDK:** Included with Flutter.

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your_username/poke_api.git
    cd poke_api/poke_api
    ```
    *(Note: Replace `https://github.com/your_username/poke_api.git` with the actual repository URL if this project is hosted.)*

2.  **Get dependencies:**
    Navigate to the `poke_api` directory (where `pubspec.yaml` is located) and run:
    ```bash
    flutter pub get
    ```

3.  **Generate code (for Freezed, Isar, etc.):**
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

## Usage

To run the application on a connected device or emulator:

```bash
flutter run
```

You can also build the application for specific platforms:

*   **Android:**
    ```bash
    flutter build apk
    # or
    flutter build appbundle
    ```
*   **iOS:**
    ```bash
    flutter build ios
    ```
*   **Web:**
    ```bash
    flutter build web
    ```
*   **Desktop (Linux, macOS, Windows):**
    ```bash
    flutter build linux
    flutter build macos
    flutter build windows
    ```

## Project Structure

```
.
├── lib/
│   ├── main.dart             # Application entry point
│   ├── home.dart             # Home screen implementation
│   ├── poke_api.dart         # Core application setup/widgets
│   ├── elements/             # UI elements and screens for different categories (All, Favorites, Generations, etc.)
│   │   ├── all.dart
│   │   ├── favorites.dart
│   │   ├── generations.dart
│   │   ├── legendaries.dart
│   │   ├── pokemon_detail.dart
│   │   └── types.dart
│   ├── models/               # Data models (e.g., PokemonStats)
│   │   └── pokemon_stats.dart
│   ├── services/             # API integration and local database helpers
│   │   ├── database_helper.dart
│   │   └── pokemon_service.dart
│   └── views/                # Main application views/screens (Dashboard, Locations, Teams, Profile)
│       ├── dashboard.dart
│       ├── locations.dart
│       ├── profile.dart
│       ├── teams_details.dart
│       └── teams.dart
├── images/                   # Application assets (Pokémon, trainers, types)
├── pubspec.yaml              # Project dependencies and metadata
└── ...                       # Other Flutter project files (android/, ios/, web/, etc.)
```