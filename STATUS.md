# Autism AVC Flutter — Project Status

Last updated: 2026-05-11 (rev 2)

## Overview

Flutter mobile companion to the [Rails web app](https://github.com/Autism-AVC/autism-avc-repo). Fully offline, standalone iOS/Android calendar/task management app. All data stored locally on device — no server dependency.

## Completed

### Core Infrastructure
- Drift database with Items, Reviews, ItemExceptions tables (mirrors Rails schema)
- RecurrenceService — RRULE expansion with exception filtering (replaces IceCube)
- TtsService — on-device TTS with en/ja, configurable pitch/rate (replaces AWS Polly)
- ImageStorageService — local save/resize to 550px max width (replaces Cloudinary)
- UnsplashService — search, download, track downloads
- ProfanityFilterService — blacklist.txt validation (mirrors `Item#profanity`)
- Riverpod providers for all services, database, preferences, and data streams
- GoRouter with bottom nav shell (Dashboard, Calendar, Settings, Child)
- Material 3 theme
- Environment config via flutter_dotenv

### Screens
- **DashboardScreen** — today's items with photo thumbnails and TTS play button
- **CalendarScreen** — table_calendar month view; tapping a day shows that day's items
- **ItemDetailScreen** — full item view with photo, TTS playback, review button, edit/delete with recurring edit dialog
- **ItemFormScreen** — create/edit with title, details, date/time pickers, recurring rule picker, camera/gallery/Unsplash photo picker
- **ReviewBottomSheet** — 1–4 emoji rating; rating == 1 shows MakeSentence happy message
- **SettingsScreen** — language toggle (en/ja), timezone picker, TTS pitch/rate sliders with preview
- **OnboardingScreen** — 5-page first-launch walkthrough
- **ChildScreen** — horizontal 7-day week view with image cards, inline emoji rating, TTS on tap, pink highlight glow (matches Rails parent portal `/items` index)
- **RecurringRulePicker** — daily/weekly/monthly rule selection
- **RecurringEditDialog** — "edit this one or all" choice for recurring items
- **UnsplashPickerScreen** — search and select Unsplash images

### Localization
- ARB files and generated localization classes for en and ja (35+ keys)
- All screens wired to `AppLocalizations.of(context)!` — UI text changes when language is toggled in Settings
- `MaterialApp` configured with `localizationsDelegates`, `supportedLocales`, and reactive `locale` from `languageProvider`

### Tests
- RecurrenceService tests
- ProfanityFilterService tests

### Intentionally Dropped (per offline-app spec)
- User authentication (Devise) — single-user offline app
- Cloudinary — replaced by local ImageStorageService
- AWS Polly — replaced by on-device flutter_tts
- Server/API dependency — all data local via Drift/SQLite

## Outstanding

### ~~1. Localization not wired into UI~~ ✅ Done

### 2. Search UI missing
`AppDatabase.searchItemsByTitle()` exists (LIKE-based) but no search bar in any screen. Spec calls for SQLite FTS on item title (matching Rails `pg_search`).

### 3. `lastOpened` not tracked
Items table has `lastOpened` column. Rails sets `@item.last_opened = DateTime.current` on show. `ItemDetailScreen` never updates this field.

### 4. `completed` status not in UI
Items table has `completed` boolean but no checkbox/toggle in any screen to mark an item complete.

### 5. `category` field not in UI
Database supports `category` but `ItemFormScreen` has no category picker. Rails item params include `:category`.

### ~~6. Onboarding not gated to first launch~~ ✅ Already done
`main.dart` checks `SharedPreferences` `onboarding_complete` flag and shows `OnboardingScreen` on first launch.

### 7. FullCalendar drag-and-drop equivalent
Rails has FullCalendar view with drag-and-drop date changes (`full_calendar_update`). Flutter CalendarScreen is view-only.

### 8. Previous photos reuse
Rails allows reattaching previously-uploaded photos (`photo_signed_ids_and_keys`). Flutter only offers camera/gallery/Unsplash — no "recent photos" option.
