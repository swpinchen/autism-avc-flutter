import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/services/recurrence_service.dart';
import 'package:autism_avc_flutter/core/theme/app_colors.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

/// The three calendar views available.
enum _CalendarView { month, week, day }

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  _CalendarView _view = _CalendarView.month;

  DateTime get _effectiveDay {
    final d = _selectedDay ?? _focusedDay;
    return DateTime(d.year, d.month, d.day);
  }

  ({DateTime start, DateTime end}) _visibleRange() {
    switch (_view) {
      case _CalendarView.month:
        final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
        final end = DateTime(
            _focusedDay.year, _focusedDay.month + 1, 0, 23, 59, 59);
        return (start: start, end: end);
      case _CalendarView.week:
        final weekday = _focusedDay.weekday;
        final start = DateTime(
            _focusedDay.year, _focusedDay.month, _focusedDay.day - weekday + 1);
        final end = start
            .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return (start: start, end: end);
      case _CalendarView.day:
        final d = _effectiveDay;
        return (
          start: DateTime(d.year, d.month, d.day),
          end: DateTime(d.year, d.month, d.day, 23, 59, 59),
        );
    }
  }

  void _goToPreviousDay() => setState(() {
        final prev = _effectiveDay.subtract(const Duration(days: 1));
        _selectedDay = prev;
        _focusedDay = prev;
      });

  void _goToNextDay() => setState(() {
        final next = _effectiveDay.add(const Duration(days: 1));
        _selectedDay = next;
        _focusedDay = next;
      });

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDay = DateTime(now.year, now.month, now.day);
      _focusedDay = now;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(allItemsProvider);
    final exceptionsAsync = ref.watch(allExceptionsProvider);
    final recurrenceService = ref.watch(recurrenceServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = l10n.localeName;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calendar),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: l10n.today,
            onPressed: _goToToday,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/items/new?date=${_effectiveDay.toIso8601String()}');
        },
        child: const Icon(Icons.add),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final exceptions = exceptionsAsync.valueOrNull ?? [];
          final range = _visibleRange();

          final allOccurrences = recurrenceService.expandItems(
            items: items,
            start: range.start,
            end: range.end,
            exceptions: exceptions,
          );

          // Group by date
          final eventsByDay = <DateTime, List<ItemOccurrence>>{};
          for (final occ in allOccurrences) {
            final day = DateTime(occ.occurrenceStart.year,
                occ.occurrenceStart.month, occ.occurrenceStart.day);
            eventsByDay.putIfAbsent(day, () => []).add(occ);
          }

          final selectedEvents = eventsByDay[_effectiveDay] ?? [];

          return Column(
            children: [
              // ── View switcher ──────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SegmentedButton<_CalendarView>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlueLighter30,
                    foregroundColor: AppColors.primaryBlueDarker10,
                    selectedBackgroundColor: AppColors.primaryBlueBase,
                    selectedForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  segments: [
                    ButtonSegment(
                      value: _CalendarView.month,
                      label: Text(l10n.month),
                      icon: const Icon(Icons.calendar_view_month, size: 18),
                    ),
                    ButtonSegment(
                      value: _CalendarView.week,
                      label: Text(l10n.week),
                      icon: const Icon(Icons.calendar_view_week, size: 18),
                    ),
                    ButtonSegment(
                      value: _CalendarView.day,
                      label: Text(l10n.day),
                      icon: const Icon(Icons.calendar_view_day, size: 18),
                    ),
                  ],
                  selected: {_view},
                  onSelectionChanged: (s) =>
                      setState(() => _view = s.first),
                ),
              ),

              // ── Calendar grid or day header ────────────────────
              if (_view == _CalendarView.day)
                _DayHeader(
                  day: _effectiveDay,
                  locale: locale,
                  onPrevious: _goToPreviousDay,
                  onNext: _goToNextDay,
                )
              else
                  ExcludeSemantics(
                  child: TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDay,
                    calendarFormat: _view == _CalendarView.week
                        ? CalendarFormat.week
                        : CalendarFormat.month,
                    selectedDayPredicate: (day) =>
                        _selectedDay != null && isSameDay(day, _selectedDay),
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                    onPageChanged: (focused) {
                      setState(() => _focusedDay = focused);
                    },
                    eventLoader: (day) {
                      final key = DateTime(day.year, day.month, day.day);
                      return eventsByDay[key] ?? [];
                    },
                    locale: locale,
                    calendarStyle: CalendarStyle(
                      todayDecoration: const BoxDecoration(
                        color: AppColors.primaryBlueBase,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppColors.primaryBlueDarker10,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: AppColors.blossomPinkBase,
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: const TextStyle(
                        color: AppColors.neutralGrayDarker30,
                      ),
                      weekendTextStyle: TextStyle(
                        color: AppColors.neutralGrayDarker30
                            .withValues(alpha: 0.7),
                      ),
                      outsideTextStyle: const TextStyle(
                        color: AppColors.neutralGrayBase,
                      ),
                    ),
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleTextStyle: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlueDarker10,
                      ),
                      leftChevronIcon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.primaryBlueBase,
                      ),
                      rightChevronIcon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.primaryBlueBase,
                      ),
                    ),
                    availableCalendarFormats: _view == _CalendarView.week
                        ? const {CalendarFormat.week: ''}
                        : const {CalendarFormat.month: ''},
                  ),
                ),

              const Divider(height: 1),

              // ── Event list ─────────────────────────────────────
              Expanded(
                child: selectedEvents.isEmpty
                    ? Center(child: Text(l10n.noEventsOnDay))
                    : _view == _CalendarView.day
                        ? _DayTimeline(
                            events: selectedEvents,
                            locale: locale,
                            onTap: (id) => context.push('/items/$id'),
                          )
                        : _CompactEventList(
                            events: selectedEvents,
                            locale: locale,
                            onTap: (id) => context.push('/items/$id'),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Day header with prev/next navigation ──────────────────────────────────────

class _DayHeader extends StatelessWidget {
  final DateTime day;
  final String locale;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _DayHeader({
    required this.day,
    required this.locale,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final dayName = DateFormat.EEEE(locale).format(day);
    final dateStr = DateFormat.yMMMd(locale).format(day);
    final isToday = isSameDay(day, DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isToday ? AppColors.primaryBlueLighter20 : null,
        borderRadius: BorderRadius.circular(40),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left,
                color: AppColors.primaryBlueBase),
            onPressed: onPrevious,
          ),
          Column(
            children: [
              Text(dayName,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlueDarker10,
                  )),
              const SizedBox(height: 2),
              Text(dateStr,
                  style: GoogleFonts.karla(
                    fontSize: 14,
                    color: AppColors.neutralGrayDarker20,
                  )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right,
                color: AppColors.primaryBlueBase),
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

// ── Day timeline — detailed event cards with time column ──────────────────────

class _DayTimeline extends StatelessWidget {
  final List<ItemOccurrence> events;
  final String locale;
  final void Function(int itemId) onTap;

  const _DayTimeline({
    required this.events,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final occ = events[index];
        final item = occ.item;
        final startStr = DateFormat.jm(locale).format(occ.occurrenceStart);
        final endStr = occ.occurrenceEnd != null
            ? DateFormat.jm(locale).format(occ.occurrenceEnd!)
            : null;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => onTap(item.id),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time column
                    SizedBox(
                      width: 80,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(startStr,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryBlueDarker10,
                              )),
                          if (endStr != null)
                            Text(endStr,
                                style: GoogleFonts.karla(
                                  fontSize: 12,
                                  color: AppColors.neutralGrayDarker10,
                                )),
                        ],
                      ),
                    ),
                    // Accent bar
                    Container(
                      width: 3,
                      height: 48,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueBase,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              if (item.imagePath != null) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: Image.file(
                                      File(item.imagePath!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, e, st) =>
                                          const Icon(
                                              Icons.image_not_supported,
                                              size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (item.details.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.details,
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Compact event list for month & week views ─────────────────────────────────

class _CompactEventList extends StatelessWidget {
  final List<ItemOccurrence> events;
  final String locale;
  final void Function(int itemId) onTap;

  const _CompactEventList({
    required this.events,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final occ = events[index];
        final timeStr = DateFormat.jm(locale).format(occ.occurrenceStart);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(occ.item.id),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Accent bar
                    Container(
                      width: 3,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlueBase,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Image
                    if (occ.item.imagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Image.file(
                            File(occ.item.imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, e, st) => const Icon(
                                Icons.image_not_supported,
                                size: 24),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryBlueLighter20,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.event, size: 20,
                            color: AppColors.primaryBlueDarker10),
                      ),
                    const SizedBox(width: 12),
                    // Title + time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(occ.item.title,
                              style:
                                  Theme.of(context).textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(timeStr,
                              style:
                                  Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
