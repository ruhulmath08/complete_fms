# Mobile app (Platform & Auth)

Flutter Clean Architecture app for owner signup, sign-in, profile, and farm settings with Bangla/English localization.

## Setup

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter run
```

## API base URL

Default: `http://10.0.2.2:8000` (Android emulator → host).

Override:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000
```

Use your machine LAN IP for a physical device.

## Structure

- `lib/domain` — entities, repository interfaces, use cases (pure Dart)
- `lib/data` — Dio API, token store, mappers, repository impl
- `lib/presentation` — pages, session/locale cubits, shell
- `lib/infrastructure` — DI, router, theme, config
- `lib/l10n` — English and Bangla ARB files
