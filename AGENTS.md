# Repository Guidelines

## Project Structure & Module Organization
This is a Flutter application. Key locations:
- `lib/` contains Dart source code (entry point is `lib/main.dart`).
- `test/` holds Flutter and Dart tests (for example, `test/widget_test.dart`).
- `android/`, `ios/`, `macos/`, `windows/`, `linux/`, `web/` contain platform runners and build configs.
- `pubspec.yaml` defines dependencies and assets; `analysis_options.yaml` configures lints.

## Build, Test, and Development Commands
Run these from the repository root:
- `flutter pub get` to install dependencies.
- `flutter run` to launch the app on a connected device or simulator.
- `flutter test` to run the test suite in `test/`.
- `flutter analyze` to run static analysis using `analysis_options.yaml`.
- `flutter build <platform>` to produce release builds (for example, `flutter build apk`, `flutter build ios`, `flutter build web`).

## Coding Style & Naming Conventions
- Dart formatting is standard: 2-space indentation, trailing commas for multi-line arguments, and `dart format` defaults.
- Follow Flutter lints from `analysis_options.yaml` (`package:flutter_lints/flutter.yaml`).
- Naming: `lower_snake_case` for files, `UpperCamelCase` for classes, `lowerCamelCase` for variables and functions.

## Testing Guidelines
- Use `flutter_test` for widget and unit tests.
- Name tests `*_test.dart` and keep them under `test/`.
- Aim to cover new UI states and logic branches; no explicit coverage target is configured.

## Commit & Pull Request Guidelines
- No Git history is present in this repository, so there are no established commit conventions.
- Use short, imperative commit messages (for example, "Add login screen").
- PRs should describe changes, list testing performed, and include screenshots for UI changes.

## Configuration Tips
- Platform-specific settings live under their respective folders (`android/`, `ios/`, etc.).
- Asset and font declarations belong in `pubspec.yaml` under the `flutter:` section.
