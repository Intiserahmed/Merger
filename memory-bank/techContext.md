# Technical Context: Merger Game

## Technologies Used

*   **Flutter:** UI framework.
*   **Dart:** Programming language.
*   **Riverpod:** State management library.
*   **Isar:** Local NoSQL database.
*   **build_runner:** Code generation for Isar and Riverpod.

## Development Setup

*   **IDE:** VS Code (or preferred Flutter IDE).
*   **Flutter SDK:** Version 3.7.0 or later.
*   **Dart SDK:** Version compatible with Flutter SDK.
*   **Android SDK:** Required for Android builds.
*   **XCode:** Required for iOS builds.

## Dependencies

See `pubspec.yaml` for a complete list of dependencies and their versions. Key dependencies include:

*   `flutter_riverpod`: For state management.
*   `isar`: For local persistence.
*   `isar_flutter_libs`: For Isar Flutter integration.
*   `path_provider`: For getting the application documents directory.
*   `build_runner`: For code generation.
*   `isar_generator`: For Isar code generation.

## Tool Usage Patterns

*   **`flutter pub get`:** Used to install and update dependencies.
*   **`flutter pub run build_runner build --delete-conflicting-outputs`:** Used to generate code for Isar and Riverpod. This command should be run after modifying any Isar models or Riverpod providers that use code generation.
*   **`flutter run`:** Used to run the application on a connected device or emulator.
