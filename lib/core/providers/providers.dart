import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:autism_avc_flutter/core/database/database.dart';
import 'package:autism_avc_flutter/core/services/image_storage_service.dart';
import 'package:autism_avc_flutter/core/services/profanity_filter_service.dart';
import 'package:autism_avc_flutter/core/services/recurrence_service.dart';
import 'package:autism_avc_flutter/core/services/tts_service.dart';
import 'package:autism_avc_flutter/core/services/unsplash_service.dart';

// ── Database ────────────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ── Services ────────────────────────────────────────────────────────────────

final recurrenceServiceProvider = Provider<RecurrenceService>((ref) {
  return RecurrenceService();
});

final ttsServiceProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  ref.onDispose(() => tts.dispose());
  return tts;
});

final imageStorageServiceProvider = Provider<ImageStorageService>((ref) {
  return ImageStorageService();
});

final unsplashServiceProvider = Provider<UnsplashService>((ref) {
  final service = UnsplashService();
  ref.onDispose(() => service.dispose());
  return service;
});

final profanityFilterProvider = Provider<ProfanityFilterService>((ref) {
  return ProfanityFilterService();
});

// ── Preferences ─────────────────────────────────────────────────────────────

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final languageProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('language') ?? 'en';
});

final timeZoneProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('timeZone') ?? 'UTC';
});

final ttsPitchProvider = StateProvider<double>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getDouble('ttsPitch') ?? 1.0;
});

final ttsRateProvider = StateProvider<double>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getDouble('ttsRate') ?? 0.5;
});

// ── Data streams ────────────────────────────────────────────────────────────

final allItemsProvider = StreamProvider<List<Item>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchAllItems();
});

final allExceptionsProvider = FutureProvider<List<ItemException>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getAllExceptions();
});
