# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is "Autism AVC Flutter" — a fully offline, standalone iOS/Android calendar/task management app for users with autism. All data (events, images, TTS audio) is stored locally on the device with no server dependency. It is the mobile companion to the [Rails web app](https://github.com/Autism-AVC/autism-avc-repo). See `docs/flutter_app_spec.md` in the Rails repo for the full design spec.

## Tech Stack

- Flutter 3.x / Dart 3.x
- **State management**: Riverpod (`flutter_riverpod`)
- **Database**: Drift (SQLite) with code generation (`drift_dev`, `build_runner`)
- **Routing**: GoRouter
- **TTS**: flutter_tts (on-device, supports en/ja)
- **Calendar**: table_calendar
- **Recurring rules**: rrule (RFC 5545 RRULE strings)
- **Images**: image_picker (camera/gallery) + Unsplash API (searched in-app, downloaded and saved locally)
- **Localization**: flutter_localizations + intl, ARB files in `lib/l10n/`
- **Environment config**: flutter_dotenv (`.env` for Unsplash API key)

## Build & Run Commands

```
flutter pub get                             # install dependencies
dart run build_runner build                 # generate Drift database code (database.g.dart)
dart run build_runner watch                 # watch mode for code generation
flutter run                                 # run on connected device/emulator
flutter build apk                           # build Android APK
flutter build ios                           # build iOS (requires Xcode)
```

### Tests
```
flutter test                                # run all tests
flutter test test/services/recurrence_test.dart  # run a single test file
```

### Lint
```
flutter analyze                             # Dart static analysis
```

## Architecture

### Directory Structure
- `lib/core/database/` — Drift database definition (tables, queries). `database.dart` defines Items, Reviews, ItemExceptions tables. `database.g.dart` is generated.
- `lib/core/services/` — Business logic services: RecurrenceService (RRULE expansion), TtsService, ImageStorageService, UnsplashService, ProfanityFilterService.
- `lib/core/providers/` — Riverpod providers for database, services, and user preferences.
- `lib/core/router/` — GoRouter configuration with bottom nav shell (Dashboard, Calendar, Settings).
- `lib/core/theme/` — Material 3 theme configuration.
- `lib/features/` — Feature screens organized by domain: dashboard, calendar, items, reviews, settings, onboarding.
- `lib/l10n/` — ARB localization files for en and ja.
- `assets/` — Bundled assets (blacklist.txt for profanity filter).

### Database Schema (Drift/SQLite)
Three tables mirroring the Rails schema:
- **Items** — id, title, details, startDate, endDate, recurringRule (RRULE string), completed, category, imagePath (local file), createdAt, updatedAt
- **Reviews** — id, itemId (FK), rating (1–4), date, createdAt
- **ItemExceptions** — id, itemId (FK), startTime, createdAt

### Key Domain Logic Ported from Rails
- **Recurring event expansion**: `RecurrenceService` uses the `rrule` package to expand items into occurrences within a date range, filtering out exceptions. This replaces the Rails IceCube + `Item#calendar_items` logic.
- **Single-occurrence edit**: Same split pattern as `ItemsController#update_recurring` — create an ItemException for that date + duplicate as a non-recurring item.
- **MakeSentence (happy message)**: `AppDatabase.getNextHappyItem()` finds the next upcoming item with rating ≥ 3, used in ReviewBottomSheet when rating == 1.
- **Profanity filter**: `ProfanityFilterService` loads `assets/blacklist.txt` and validates title/details before save, matching `Item#profanity`.
- **Recurring rule display**: `RecurrenceService.describeRule()` converts raw RRULE strings into locale-aware natural language (e.g. `RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR` → "Every week on Mon, Wed, Fri" / "毎週 月・水・金"). Supports DAILY/WEEKLY/MONTHLY frequencies, INTERVAL, BYDAY, BYMONTHDAY, and UNTIL. Used in both `ItemDetailScreen` and `ItemFormScreen`.

### Child View Encouragement Flow
When a child gives a low rating (1 or 2) to an event in the Child view, the app encourages them by:
1. Looking up the closest future event (relative to the sad event's date) that has a positive review (rating ≥ 3). The search uses `AppDatabase.getNextHappyItem(after:)` and is **not** limited to the current week.
2. Speaking a TTS encouragement message: *"Thank you for telling me how you feel. Just remember you have this to look forward to on {day}, {date}!"* (localized into Japanese as *"気持ちを教えてくれてありがとう。{day}の{date}に楽しみなことがあるよ！"*).
3. Navigating to the happy event's detail page.
4. Displaying the encouragement message in a styled banner at the top of the page.
5. Playing a shooting fireworks animation (`FireworksOverlay`) over the page for 5 seconds.

This also triggers when the user **re-rates** a previously happy event (≥ 3) to sad (≤ 2) from the detail page, provided the detail page was opened from the child view. The `childView=true` query parameter propagates through navigations so the behaviour carries across chained encouragement pages.

**Key files:**
- `lib/features/items/fireworks_overlay.dart` — Custom `CustomPainter`-based fireworks animation (7 staggered rockets, app colour palette).
- `lib/features/child/child_screen.dart` — `_encourageWithHappyItem()` handles first-time low ratings.
- `lib/features/items/item_detail_screen.dart` — `_triggerEncouragement()` handles happy→sad re-ratings; encouragement banner displayed when `showFireworks` is true.
- `lib/core/router/app_router.dart` — Passes `fireworks` and `childView` query parameters to `ItemDetailScreen`.
- `lib/l10n/app_en.arb`, `lib/l10n/app_ja.arb` — `encourageMessage` localised string with `{day}` and `{date}` placeholders.
- `test/features/fireworks_overlay_test.dart` — Widget tests for the fireworks overlay.
- `test/database/happy_item_test.dart` — Database integration tests for `getNextHappyItem()` including the `after` parameter.

### Environment Variables
The `.env` file (not committed) must contain:
- `UNSPLASH_ACCESS_KEY` — Unsplash API access key for image search

### Code Generation
After modifying Drift table definitions or Riverpod annotations, regenerate with:
```
dart run build_runner build --delete-conflicting-outputs
```
