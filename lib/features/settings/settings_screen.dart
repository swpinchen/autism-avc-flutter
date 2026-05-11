import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final pitch = ref.watch(ttsPitchProvider);
    final rate = ref.watch(ttsRateProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          // Language
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(language == 'ja' ? '日本語' : 'English'),
            trailing: Switch(
              value: language == 'ja',
              onChanged: (isJa) {
                final newLang = isJa ? 'ja' : 'en';
                ref.read(languageProvider.notifier).state = newLang;
                prefs.setString('language', newLang);
                ttsService.setLanguage(newLang);
              },
            ),
          ),
          const Divider(),

          // Timezone
          ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(l10n.timezone),
            subtitle: Text(ref.watch(timeZoneProvider)),
            onTap: () async {
              final timezones = [
                'UTC',
                'America/New_York',
                'America/Chicago',
                'America/Denver',
                'America/Los_Angeles',
                'America/Anchorage',
                'Pacific/Honolulu',
                'Europe/London',
                'Europe/Paris',
                'Europe/Berlin',
                'Asia/Tokyo',
                'Asia/Shanghai',
                'Asia/Kolkata',
                'Asia/Dubai',
                'Australia/Sydney',
                'Pacific/Auckland',
              ];
              final current = ref.read(timeZoneProvider);
              final picked = await showDialog<String>(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: Text(l10n.selectTimezone),
                  children: timezones.map((tz) {
                    return SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, tz),
                      child: Text(
                        tz,
                        style: TextStyle(
                          fontWeight:
                              tz == current ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
              if (picked != null) {
                ref.read(timeZoneProvider.notifier).state = picked;
                prefs.setString('timeZone', picked);
              }
            },
          ),
          const Divider(),

          // TTS section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.textToSpeech,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Pitch
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(l10n.pitch),
            subtitle: Slider(
              value: pitch,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: pitch.toStringAsFixed(1),
              onChanged: (v) {
                ref.read(ttsPitchProvider.notifier).state = v;
                prefs.setDouble('ttsPitch', v);
                ttsService.setPitch(v);
              },
            ),
          ),

          // Rate
          ListTile(
            leading: const Icon(Icons.speed),
            title: Text(l10n.speed),
            subtitle: Slider(
              value: rate,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: rate.toStringAsFixed(1),
              onChanged: (v) {
                ref.read(ttsRateProvider.notifier).state = v;
                prefs.setDouble('ttsRate', v);
                ttsService.setRate(v);
              },
            ),
          ),

          // Preview button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {
                ttsService.speak(l10n.voicePreviewText);
              },
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.previewVoice),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
