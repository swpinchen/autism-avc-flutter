import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:autism_avc_flutter/core/database/database.dart';
import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/services/recurrence_service.dart';

// Rating emojis matching the Rails 1–4 scale (same as ReviewBottomSheet)
const _kEmojis = ['😢', '😐', '🙂', '😄'];

class ChildScreen extends ConsumerWidget {
  const ChildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allItemsProvider);
    final exceptionsAsync = ref.watch(allExceptionsProvider);
    final reviewsAsync = ref.watch(allReviewsProvider);
    final recurrenceService = ref.watch(recurrenceServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('This Week')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final exceptions = exceptionsAsync.valueOrNull ?? [];
          final allReviews = reviewsAsync.valueOrNull ?? [];

          // Build itemId → most-recent review map
          final lastReviewMap = <int, Review>{};
          for (final review in allReviews) {
            final existing = lastReviewMap[review.itemId];
            if (existing == null ||
                review.createdAt.isAfter(existing.createdAt)) {
              lastReviewMap[review.itemId] = review;
            }
          }

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final tomorrow = today.add(const Duration(days: 1));

          // 7-day window: today … today+6
          final days = List.generate(7, (i) => today.add(Duration(days: i)));
          final weekEnd = days.last
              .add(const Duration(hours: 23, minutes: 59, seconds: 59));

          final occurrences = recurrenceService.expandItems(
            items: items,
            start: today,
            end: weekEnd,
            exceptions: exceptions,
          );

          // Group occurrences by calendar day
          final occsByDay = <DateTime, List<ItemOccurrence>>{};
          for (final day in days) {
            occsByDay[day] = occurrences
                .where((o) =>
                    o.occurrenceStart.year == day.year &&
                    o.occurrenceStart.month == day.month &&
                    o.occurrenceStart.day == day.day)
                .toList();
          }

          // Each column is ~40 % of screen width; clamp to a sensible range
          final columnWidth =
              (MediaQuery.of(context).size.width * 0.42).clamp(140.0, 220.0);

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: days.map((day) {
                      final isToday = day == today;
                      final isTomorrow = day == tomorrow;
                      final label = isToday
                          ? 'Today'
                          : isTomorrow
                              ? 'Tomorrow'
                              : DateFormat.EEEE().format(day);
                      final dateLabel = DateFormat('M/d').format(day);
                      final dayOccs = occsByDay[day] ?? [];

                      return SizedBox(
                        width: columnWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ── Day header ──────────────────────────────
                            _DayHeader(
                              label: label,
                              dateLabel: dateLabel,
                              isToday: isToday,
                            ),

                            // ── Event cards (independently scrollable) ──
                            Expanded(
                              child: dayOccs.isEmpty
                                  ? const Center(
                                      child: Text(
                                        '—',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(
                                          bottom: 16, top: 4),
                                      itemCount: dayOccs.length,
                                      itemBuilder: (context, i) {
                                        final occ = dayOccs[i];
                                        return _ChildCard(
                                          occurrence: occ,
                                          lastReview:
                                              lastReviewMap[occ.item.id],
                                          columnWidth: columnWidth,
                                          onTap: () => context
                                              .push('/items/${occ.item.id}'),
                                          onRate: (rating) async {
                                            final db =
                                                ref.read(databaseProvider);
                                            await db.insertReview(
                                              ReviewsCompanion.insert(
                                                itemId: occ.item.id,
                                                rating: rating,
                                                date: DateTime.now(),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Day column header ─────────────────────────────────────────────────────────

class _DayHeader extends StatelessWidget {
  final String label;
  final String dateLabel;
  final bool isToday;

  const _DayHeader({
    required this.label,
    required this.dateLabel,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: isToday ? cs.primaryContainer : cs.surfaceContainerHighest,
        border: Border(
          right: BorderSide(color: cs.outlineVariant, width: 0.5),
          bottom: BorderSide(color: cs.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isToday ? cs.onPrimaryContainer : null,
                ),
            textAlign: TextAlign.center,
          ),
          Text(
            dateLabel,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isToday
                      ? cs.onPrimaryContainer.withValues(alpha: 0.7)
                      : cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Individual event card ─────────────────────────────────────────────────────

class _ChildCard extends StatelessWidget {
  final ItemOccurrence occurrence;
  final Review? lastReview;
  final double columnWidth;
  final VoidCallback onTap;
  final Future<void> Function(int rating) onRate;

  const _ChildCard({
    required this.occurrence,
    required this.lastReview,
    required this.columnWidth,
    required this.onTap,
    required this.onRate,
  });

  static const double _imageHeight = 180.0;
  static const double _pillOverhang = 22.0;

  @override
  Widget build(BuildContext context) {
    final item = occurrence.item;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        // Extra bottom padding makes room for the pill that floats below image
        padding: const EdgeInsets.fromLTRB(6, 10, 6, _pillOverhang + 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Image / placeholder ─────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: item.imagePath != null
                  ? Image.file(
                      File(item.imagePath!),
                      width: double.infinity,
                      height: _imageHeight,
                      fit: BoxFit.cover,
                      errorBuilder: (context, e, st) =>
                          _Placeholder(title: item.title),
                    )
                  : _Placeholder(title: item.title),
            ),

            // ── Emoji pill — floats below image ─────────────────────
            Positioned(
              bottom: -_pillOverhang,
              left: 0,
              right: 0,
              child: Center(
                child: _EmojiPill(
                  lastReview: lastReview,
                  onRate: onRate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── No-image placeholder ──────────────────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      height: _ChildCard._imageHeight,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              height: 1.2,
            ),
        textAlign: TextAlign.center,
        maxLines: 5,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// ── Emoji pill ────────────────────────────────────────────────────────────────

class _EmojiPill extends StatelessWidget {
  final Review? lastReview;
  final Future<void> Function(int rating) onRate;

  const _EmojiPill({required this.lastReview, required this.onRate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: lastReview != null
          // Already reviewed — show the emoji
          ? Text(
              _kEmojis[(lastReview!.rating - 1).clamp(0, 3)],
              style: const TextStyle(fontSize: 26),
            )
          // Not yet reviewed — show 4 tap-to-rate buttons
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (i) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onRate(i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Text(
                      _kEmojis[i],
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                );
              }),
            ),
    );
  }
}
