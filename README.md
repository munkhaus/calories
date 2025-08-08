# Flutter Template

Production-grade Flutter template with:

- Feature-first architecture and Cursor rules
- Strict lints (very_good_analysis) and import boundary enforcement
- DI with get_it, routing with go_router
- Networking with dio, design tokens via `KSizes`
- CI workflow (format, analyze, tests with coverage)

## Getting Started

### Use this template

1) Create your repo from this template (Use this template → Create new repository)
2) Clone your new repo
3) Install dependencies

```
flutter pub get
```

4) Verify lints and tests

```
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
```

5) Run locally

```
flutter run -d chrome
```

### Codegen (optional when using freezed/json_serializable later)

```
dart run build_runner build --delete-conflicting-outputs
```

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Credits

- Cursor rules inspired by and adapted from [erkansahin/vibe_coding_tutorial_weather_app](https://github.com/erkansahin/vibe_coding_tutorial_weather_app).
