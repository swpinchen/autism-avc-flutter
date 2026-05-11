import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/services/recurrence_service.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allItemsProvider);
    final exceptionsAsync = ref.watch(allExceptionsProvider);
    final recurrenceService = ref.watch(recurrenceServiceProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.today)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/items/new'),
        child: const Icon(Icons.add),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final exceptions = exceptionsAsync.valueOrNull ?? [];
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd = todayStart
              .add(const Duration(hours: 23, minutes: 59, seconds: 59));

          final occurrences = recurrenceService.expandItems(
            items: items,
            start: todayStart,
            end: todayEnd,
            exceptions: exceptions,
          );

          if (occurrences.isEmpty) {
            return Center(
              child: Text(
                l10n.noEventsToday,
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: occurrences.length,
            itemBuilder: (context, index) {
              final occ = occurrences[index];
              return _ItemCard(
                occurrence: occ,
                onTap: () => context.push('/items/${occ.item.id}'),
                onPlayTts: () => ttsService.speak(occ.item.details),
              );
            },
          );
        },
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final ItemOccurrence occurrence;
  final VoidCallback onTap;
  final VoidCallback onPlayTts;

  const _ItemCard({
    required this.occurrence,
    required this.onTap,
    required this.onPlayTts,
  });

  @override
  Widget build(BuildContext context) {
    final item = occurrence.item;
    final locale = AppLocalizations.of(context)!.localeName;
    final timeStr = DateFormat.jm(locale).format(occurrence.occurrenceStart);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Photo thumbnail
              if (item.imagePath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(item.imagePath!),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, st) => const SizedBox(
                      width: 56,
                      height: 56,
                      child: Icon(Icons.image_not_supported),
                    ),
                  ),
                )
              else
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.event),
                ),
              const SizedBox(width: 12),

              // Title + time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // TTS play button
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: onPlayTts,
                tooltip: AppLocalizations.of(context)!.readAloud,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
