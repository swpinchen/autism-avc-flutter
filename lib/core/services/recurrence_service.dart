import 'package:intl/intl.dart';
import 'package:rrule/rrule.dart';
import 'package:autism_avc_flutter/core/database/database.dart';

/// Represents a single occurrence of an item (recurring or not) within a range.
class ItemOccurrence {
  final Item item;
  final DateTime occurrenceStart;
  final DateTime? occurrenceEnd;

  /// True if this occurrence comes from a recurring rule expansion.
  final bool isRecurringInstance;

  const ItemOccurrence({
    required this.item,
    required this.occurrenceStart,
    this.occurrenceEnd,
    this.isRecurringInstance = false,
  });
}

class RecurrenceService {
  /// Expand a list of items into individual occurrences within [start, end],
  /// excluding dates present in [exceptions].
  List<ItemOccurrence> expandItems({
    required List<Item> items,
    required DateTime start,
    required DateTime end,
    required List<ItemException> exceptions,
  }) {
    final occurrences = <ItemOccurrence>[];

    for (final item in items) {
      if (item.recurringRule == null || item.recurringRule!.isEmpty) {
        // Non-recurring: include if start date falls within range
        if (!item.startDate.isBefore(start) && !item.startDate.isAfter(end)) {
          occurrences.add(ItemOccurrence(
            item: item,
            occurrenceStart: item.startDate,
            occurrenceEnd: item.endDate,
          ));
        }
      } else {
        // Recurring: expand RRULE within the range
        occurrences.addAll(
          _expandRecurring(item, start, end, exceptions),
        );
      }
    }

    occurrences.sort(
        (a, b) => a.occurrenceStart.compareTo(b.occurrenceStart));
    return occurrences;
  }

  List<ItemOccurrence> _expandRecurring(
    Item item,
    DateTime rangeStart,
    DateTime rangeEnd,
    List<ItemException> allExceptions,
  ) {
    final results = <ItemOccurrence>[];

    try {
      final rrule = RecurrenceRule.fromString(item.recurringRule!);
      final duration = item.endDate != null
          ? item.endDate!.difference(item.startDate)
          : Duration.zero;

      // Get occurrences from the RRULE starting at the item's original start
      final instances = rrule.getInstances(
        start: item.startDate.toUtc(),
        before: rangeEnd.toUtc().add(const Duration(days: 1)),
      );

      // Exceptions for this specific item
      final itemExceptions = allExceptions
          .where((e) => e.itemId == item.id)
          .map((e) => _dateOnly(e.startTime))
          .toSet();

      for (final instance in instances) {
        final localInstance = instance.toLocal();

        // Skip if before range start
        if (localInstance.isBefore(rangeStart)) continue;
        // Stop if past range end
        if (localInstance.isAfter(rangeEnd)) break;

        // Skip excepted dates
        if (itemExceptions.contains(_dateOnly(localInstance))) continue;

        // Preserve original time-of-day from the item
        final occurrenceStart = DateTime(
          localInstance.year,
          localInstance.month,
          localInstance.day,
          item.startDate.hour,
          item.startDate.minute,
        );

        final occurrenceEnd = duration != Duration.zero
            ? occurrenceStart.add(duration)
            : null;

        results.add(ItemOccurrence(
          item: item,
          occurrenceStart: occurrenceStart,
          occurrenceEnd: occurrenceEnd,
          isRecurringInstance: true,
        ));
      }
    } catch (_) {
      // If RRULE parsing fails, treat as non-recurring
      if (!item.startDate.isBefore(rangeStart) &&
          !item.startDate.isAfter(rangeEnd)) {
        results.add(ItemOccurrence(
          item: item,
          occurrenceStart: item.startDate,
          occurrenceEnd: item.endDate,
        ));
      }
    }

    return results;
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  // ── Human-readable RRULE description ─────────────────────────────────

  static const _enDays = {
    'MO': 'Mon', 'TU': 'Tue', 'WE': 'Wed', 'TH': 'Thu',
    'FR': 'Fri', 'SA': 'Sat', 'SU': 'Sun',
  };
  static const _jaDays = {
    'MO': '月', 'TU': '火', 'WE': '水', 'TH': '木',
    'FR': '金', 'SA': '土', 'SU': '日',
  };

  /// Convert an RRULE string (e.g. `RRULE:FREQ=WEEKLY;BYDAY=MO,WE`) to a
  /// locale-aware natural-language description.
  static String describeRule(String rule, String locale) {
    final isJa = locale.startsWith('ja');

    // ── Frequency ────────────────────────────────────────────────────
    String freq;
    if (rule.contains('FREQ=DAILY')) {
      freq = 'DAILY';
    } else if (rule.contains('FREQ=WEEKLY')) {
      freq = 'WEEKLY';
    } else if (rule.contains('FREQ=MONTHLY')) {
      freq = 'MONTHLY';
    } else {
      return rule; // unknown → return raw
    }

    // ── Interval ─────────────────────────────────────────────────────
    int interval = 1;
    final im = RegExp(r'INTERVAL=(\d+)').firstMatch(rule);
    if (im != null) interval = int.parse(im.group(1)!);

    // ── Build core description ───────────────────────────────────────
    String desc;
    switch (freq) {
      case 'DAILY':
        desc = interval == 1
            ? (isJa ? '毎日' : 'Every day')
            : (isJa ? '$interval日ごと' : 'Every $interval days');
      case 'WEEKLY':
        final base = interval == 1
            ? (isJa ? '毎週' : 'Every week')
            : (isJa ? '$interval週間ごと' : 'Every $interval weeks');
        final bm = RegExp(r'BYDAY=([A-Z,]+)').firstMatch(rule);
        if (bm != null) {
          final days = bm.group(1)!.split(',');
          final names = isJa ? _jaDays : _enDays;
          final sep = isJa ? '・' : ', ';
          final dayStr = days.map((d) => names[d] ?? d).join(sep);
          desc = isJa ? '$base $dayStr' : '$base on $dayStr';
        } else {
          desc = base;
        }
      case 'MONTHLY':
        final base = interval == 1
            ? (isJa ? '毎月' : 'Every month')
            : (isJa ? '$intervalヶ月ごと' : 'Every $interval months');
        final mm = RegExp(r'BYMONTHDAY=(\d+)').firstMatch(rule);
        if (mm != null) {
          final day = mm.group(1)!;
          desc = isJa ? '$base$day日' : '$base on day $day';
        } else {
          desc = base;
        }
      default:
        desc = rule;
    }

    // ── UNTIL ────────────────────────────────────────────────────────
    final um = RegExp(r'UNTIL=(\d{8})').firstMatch(rule);
    if (um != null) {
      final s = um.group(1)!;
      final until = DateTime(
        int.parse(s.substring(0, 4)),
        int.parse(s.substring(4, 6)),
        int.parse(s.substring(6, 8)),
      );
      final fd = DateFormat.yMMMd(locale).format(until);
      desc += isJa ? '（$fdまで）' : ' until $fd';
    }

    return desc;
  }
}
