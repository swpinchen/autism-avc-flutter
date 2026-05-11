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

class ChildScreen extends ConsumerStatefulWidget {
  const ChildScreen({super.key});

  @override
  ConsumerState<ChildScreen> createState() => _ChildScreenState();
}

class _ChildScreenState extends ConsumerState<ChildScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  // Build the 7-day list once per build cycle
  late final List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _days = List.generate(7, (i) => today.add(Duration(days: i)));
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

          final today = _days.first;
          final tomorrow = _days[1];
          final weekEnd = _days.last
              .add(const Duration(hours: 23, minutes: 59, seconds: 59));

          final occurrences = recurrenceService.expandItems(
            items: items,
            start: today,
            end: weekEnd,
            exceptions: exceptions,
          );

          // Group occurrences by calendar day
          final occsByDay = <DateTime, List<ItemOccurrence>>{};
          for (final day in _days) {
            occsByDay[day] = occurrences
                .where((o) =>
                    o.occurrenceStart.year == day.year &&
                    o.occurrenceStart.month == day.month &&
                    o.occurrenceStart.day == day.day)
                .toList();
          }

          return Column(
            children: [
              // ── Day-selector strip ─────────────────────────────────
              _DayStrip(
                days: _days,
                today: today,
                tomorrow: tomorrow,
                selectedIndex: _currentPage,
                onDayTap: (i) {
                  setState(() => _currentPage = i);
                  _pageController.animateToPage(
                    i,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),

              // ── Day pages ──────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _days.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, i) {
                    final day = _days[i];
                    final dayOccs = occsByDay[day] ?? [];

                    if (dayOccs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No events today',
                          style: TextStyle(fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding:
                          const EdgeInsets.fromLTRB(12, 8, 12, 32),
                      itemCount: dayOccs.length,
                      itemBuilder: (context, j) {
                        final occ = dayOccs[j];
                        return _ChildCard(
                          occurrence: occ,
                          lastReview: lastReviewMap[occ.item.id],
                          onTap: () =>
                              context.push('/items/${occ.item.id}'),
                          onRate: (rating) async {
                            final db = ref.read(databaseProvider);
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
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Day-selector strip ────────────────────────────────────────────────────────

class _DayStrip extends StatelessWidget {
  final List<DateTime> days;
  final DateTime today;
  final DateTime tomorrow;
  final int selectedIndex;
  final ValueChanged<int> onDayTap;

  const _DayStrip({
    required this.days,
    required this.today,
    required this.tomorrow,
    required this.selectedIndex,
    required this.onDayTap,
  });

  String _label(DateTime day) {
    if (day == today) return 'Today';
    if (day == tomorrow) return 'Tomorrow';
    return DateFormat.E().format(day); // Mon, Tue …
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: List.generate(days.length, (i) {
            final day = days[i];
            final isSelected = i == selectedIndex;
            final isToday = day == today;
            return GestureDetector(
              onTap: () => onDayTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.primary
                      : isToday
                          ? cs.primaryContainer
                          : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _label(day),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? cs.onPrimary
                                : isToday
                                    ? cs.onPrimaryContainer
                                    : cs.onSurface,
                          ),
                    ),
                    Text(
                      DateFormat('M/d').format(day),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: isSelected
                                ? cs.onPrimary.withValues(alpha: 0.8)
                                : cs.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── Individual event card ─────────────────────────────────────────────────────

class _ChildCard extends StatelessWidget {
  final ItemOccurrence occurrence;
  final Review? lastReview;
  final VoidCallback onTap;
  final Future<void> Function(int rating) onRate;

  const _ChildCard({
    required this.occurrence,
    required this.lastReview,
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
