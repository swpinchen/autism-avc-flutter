import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/router/app_router.dart';
import 'package:autism_avc_flutter/core/services/tts_service.dart';
import 'package:autism_avc_flutter/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize TTS with saved preferences
  final ttsService = TtsService();
  await ttsService.init(
    language: prefs.getString('language') == 'ja' ? 'ja-JP' : 'en-US',
    pitch: prefs.getDouble('ttsPitch') ?? 1.0,
    rate: prefs.getDouble('ttsRate') ?? 0.5,
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const AutismAvcApp(),
    ),
  );
}

class AutismAvcApp extends StatelessWidget {
  const AutismAvcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Autism AVC',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
