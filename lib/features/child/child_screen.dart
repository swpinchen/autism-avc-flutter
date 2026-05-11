import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:autism_avc_flutter/core/database/database.dart';
import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/services/recurrence_service.dart';
import 'package:autism_avc_flutter/core/theme/app_colors.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

// ── Design tokens (via AppColors) ─────────────────────────────────────────────
const _kPrimaryBlueDarker = AppColors.primaryBlueDarker10;
const _kPrimaryBlueLighter20 = AppColors.primaryBlueLighter20;
const _kPageBg = AppColors.neutralGrayLighter30;
const _kNeutralLighter20 = AppColors.neutralGrayLighter20;
const _kNeutralLighter10 = AppColors.neutralGrayLighter10;
const _kPink = AppColors.highlightPink;

// Rating emojis matching Rails 1–4 scale
const _kEmojis = ['😢', '😐', '🙂', '😄'];

// Column width mirrors Rails 300 px fixed table column
const double _kColumnWidth = 300.0;

// ── Screen ────────────────────────────────────────────────────────────────────

class ChildScreen extends ConsumerWidget {
  const ChildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allItemsProvider);
    final exceptionsAsync = ref.watch(allExceptionsProvider);
    final reviewsAsync = ref.watch(allReviewsProvider);
    final recurrenceService = ref.watch(recurrenceServiceProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: _kPageBg,
      appBar: AppBar(
        title: Text(l10n.thisWeek),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: const Color(0x1A000000),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final exceptions = exceptionsAsync.valueOrNull ?? [];
          final allReviews = reviewsAsync.valueOrNull ?? [];

          // itemId → most-recent review
          final lastReviewMap = <int, Review>{};
          for (final review in allReviews) {
            final existing = lastReviewMap[review.itemId];
            if (existing == null ||
                review.createdAt.isAfter(existing.createdAt)) {
              lastReviewMap[review.itemId] = review;
            }
          }

          final weekEnd = days.last
              .add(const Duration(hours: 23, minutes: 59, seconds: 59));
          final occurrences = recurrenceService.expandItems(
            items: items, start: today, end: weekEnd, exceptions: exceptions,
          );

          final occsByDay = <DateTime, List<ItemOccurrence>>{};
          for (final day in days) {
            occsByDay[day] = occurrences
                .where((o) =>
                    o.occurrenceStart.year == day.year &&
                    o.occurrenceStart.month == day.month &&
                    o.occurrenceStart.day == day.day)
                .toList();
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                // Rails .simple-calendar: margin-top 0.8em → ~12 dp
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 12),
                child: SizedBox(
                  // Fix height so Expanded inside each column works
                  height: constraints.maxHeight - 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: days.map((day) {
                      final isToday = day == today;
                      final isTomorrow = day == tomorrow;
                      final label = isToday
                          ? l10n.today
                          : isTomorrow
                              ? l10n.tomorrow
                              : DateFormat.EEEE(l10n.localeName).format(day);
                      final dayOccs = occsByDay[day] ?? [];

                      return _DayColumn(
                        label: label,
                        isToday: isToday,
                        occurrences: dayOccs,
                        lastReviewMap: lastReviewMap,
                        onTtsSpeakDay: () => ttsService.speak(label),
                        onTtsSpeakDetails: (d) => ttsService.speak(d),
                        onNavigate: (id) => context.push('/items/$id'),
                        onRate: (itemId, rating) async {
                          final db = ref.read(databaseProvider);
                          await db.insertReview(ReviewsCompanion.insert(
                            itemId: itemId, rating: rating,
                            date: DateTime.now(),
                          ));
                        },
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

// ── Day column (<th> header + <td> content) ───────────────────────────────────

class _DayColumn extends StatelessWidget {
  final String label;
  final bool isToday;
  final List<ItemOccurrence> occurrences;
  final Map<int, Review> lastReviewMap;
  final VoidCallback onTtsSpeakDay;
  final void Function(String details) onTtsSpeakDetails;
  final void Function(int itemId) onNavigate;
  final Future<void> Function(int itemId, int rating) onRate;

  const _DayColumn({
    required this.label,
    required this.isToday,
    required this.occurrences,
    required this.lastReviewMap,
    required this.onTtsSpeakDay,
    required this.onTtsSpeakDetails,
    required this.onNavigate,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    // Rails border-spacing: 1.5em ≈ 12 dp each side
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: _kColumnWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── <th>: pill day header ──────────────────────────────
            GestureDetector(
              onTap: onTtsSpeakDay,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: isToday ? _kPrimaryBlueLighter20 : Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(color: Color(0x26000000), blurRadius: 5),
                  ],
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: _kPrimaryBlueDarker,
                  ),
                ),
              ),
            ),

            // Rails border-spacing vertical ≈ 1em → 16 dp
            const SizedBox(height: 16),

            // ── <td>: white rounded content panel ─────────────────
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(color: Color(0x26000000), blurRadius: 5),
                  ],
                ),
                child: occurrences.isEmpty
                    ? const Center(
                        child: Text(
                          '—',
                          style: TextStyle(
                            fontSize: 28,
                            color: Color(0xFFCACACA),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        // Rails .daycontainer: padding 16px
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                        child: Column(
                          children: occurrences.map((occ) {
                            return _ChildCard(
                              occurrence: occ,
                              lastReview: lastReviewMap[occ.item.id],
                              onTtsSpeak: () =>
                                  onTtsSpeakDetails(occ.item.details),
                              onNavigate: () => onNavigate(occ.item.id),
                              onRate: (rating) =>
                                  onRate(occ.item.id, rating),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event card ────────────────────────────────────────────────────────────────

class _ChildCard extends StatefulWidget {
  final ItemOccurrence occurrence;
  final Review? lastReview;
  final VoidCallback onTtsSpeak;
  final VoidCallback onNavigate;
  final Future<void> Function(int rating) onRate;

  const _ChildCard({
    required this.occurrence,
    required this.lastReview,
    required this.onTtsSpeak,
    required this.onNavigate,
    required this.onRate,
  });

  @override
  State<_ChildCard> createState() => _ChildCardState();
}

class _ChildCardState extends State<_ChildCard> {
  bool _highlighted = false;
  Timer? _timer;

  static const double _imageHeight = 200.0;
  static const double _pillOverhang = 16.0; // Rails bottom: -16px

  void _triggerHighlight() {
    if (!mounted) return;
    setState(() => _highlighted = true);
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _highlighted = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.occurrence.item;

    return Container(
      // Rails .card-trip in index: width 90%, margin auto, margin-bottom 36px
      margin: EdgeInsets.fromLTRB(
        _kColumnWidth * 0.05, 0, _kColumnWidth * 0.05, 36,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Image / placeholder with animated pink glow ───────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: _highlighted
                  ? [
                      BoxShadow(
                        color: _kPink.withValues(alpha: 0.9),
                        blurRadius: 10,
                        spreadRadius: 10,
                      ),
                    ]
                  : [
                      const BoxShadow(
                        // Rails: 2px 4px 8px rgba(0,0,0,0.15)
                        color: Color(0x26000000),
                        blurRadius: 8,
                        offset: Offset(2, 4),
                      ),
                    ],
            ),
            child: GestureDetector(
              onTap: () {
                widget.onTtsSpeak(); // voiceitems.js: click image → TTS
                _triggerHighlight(); // highlightborder.js: pink glow 2s
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: item.imagePath != null
                    ? Image.file(
                        File(item.imagePath!),
                        width: double.infinity,
                        height: _imageHeight,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, e, st) =>
                            _Placeholder(title: item.title),
                      )
                    : _Placeholder(title: item.title),
              ),
            ),
          ),

          // ── Emoji pill: Rails bottom -16px ────────────────────────
          Positioned(
            bottom: -_pillOverhang,
            left: 0,
            right: 0,
            child: Center(
              child: _EmojiPill(
                lastReview: widget.lastReview,
                onNavigate: () {
                  _triggerHighlight();
                  widget.onNavigate();
                },
                onRate: (r) {
                  _triggerHighlight();
                  widget.onRate(r);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image placeholder ─────────────────────────────────────────────────────────
// Rails .placeholder-txt: centered bold title in $neutralgray-base.

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _ChildCardState._imageHeight,
      decoration: BoxDecoration(
        color: _kPageBg, // $neutralgray-lighter-30
        border: Border.all(color: _kNeutralLighter10),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFFCACACA), // $neutralgray-base
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
// Rails .card-trip-infos: bg $neutralgray-lighter-20, border-radius 40px,
// max-width 200px, shadow.

class _EmojiPill extends StatelessWidget {
  final Review? lastReview;
  final VoidCallback onNavigate;
  final void Function(int rating) onRate;

  const _EmojiPill({
    required this.lastReview,
    required this.onNavigate,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: _kNeutralLighter20,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26484848), // $flatpickr-black015
            blurRadius: 4,
            offset: Offset(1, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: lastReview != null
          // Reviewed → tap pill navigates to detail (Rails .itemlink)
          ? GestureDetector(
              onTap: onNavigate,
              child: Text(
                _kEmojis[(lastReview!.rating - 1).clamp(0, 3)],
                // Rails .card-emoji-small max-height 36px
                style: const TextStyle(fontSize: 30),
              ),
            )
          // Not reviewed → 4 rating buttons (Rails rating forms)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(4, (i) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onRate(i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _kEmojis[i],
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                );
              }),
            ),
    );
  }
}
