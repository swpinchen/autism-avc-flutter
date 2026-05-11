import 'package:flutter_test/flutter_test.dart';

import 'package:autism_avc_flutter/core/database/database.dart';
import 'package:autism_avc_flutter/core/services/recurrence_service.dart';

void main() {
  late RecurrenceService service;

  setUp(() {
    service = RecurrenceService();
  });

  Item makeItem({
    int id = 1,
    required DateTime startDate,
    DateTime? endDate,
    String? recurringRule,
  }) {
    return Item(
      id: id,
      title: 'Test',
      details: 'Details',
      startDate: startDate,
      endDate: endDate,
      recurringRule: recurringRule,
      completed: false,
      category: null,
      imagePath: null,
      lastOpened: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  group('RecurrenceService', () {
    test('non-recurring item within range is returned', () {
      final item = makeItem(startDate: DateTime(2025, 6, 15, 10, 0));
      final result = service.expandItems(
        items: [item],
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 30),
        exceptions: [],
      );
      expect(result.length, 1);
      expect(result.first.item.id, 1);
      expect(result.first.isRecurringInstance, false);
    });

    test('non-recurring item outside range is excluded', () {
      final item = makeItem(startDate: DateTime(2025, 7, 1, 10, 0));
      final result = service.expandItems(
        items: [item],
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 30),
        exceptions: [],
      );
      expect(result, isEmpty);
    });

    test('daily recurring item expands correctly', () {
      final item = makeItem(
        startDate: DateTime(2025, 6, 1, 9, 0),
        recurringRule: 'RRULE:FREQ=DAILY',
      );
      final result = service.expandItems(
        items: [item],
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 3, 23, 59),
        exceptions: [],
      );
      expect(result.length, 3);
      expect(result[0].occurrenceStart.day, 1);
      expect(result[1].occurrenceStart.day, 2);
      expect(result[2].occurrenceStart.day, 3);
      expect(result.every((o) => o.isRecurringInstance), true);
    });

    test('exceptions are excluded from recurring expansion', () {
      final item = makeItem(
        startDate: DateTime(2025, 6, 1, 9, 0),
        recurringRule: 'RRULE:FREQ=DAILY',
      );
      final exception = ItemException(
        id: 1,
        itemId: 1,
        startTime: DateTime(2025, 6, 2, 9, 0),
        createdAt: DateTime.now(),
      );
      final result = service.expandItems(
        items: [item],
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 3, 23, 59),
        exceptions: [exception],
      );
      expect(result.length, 2);
      expect(result.any((o) => o.occurrenceStart.day == 2), false);
    });

    test('weekly recurring item with BYDAY expands correctly', () {
      final item = makeItem(
        startDate: DateTime(2025, 6, 2, 10, 0), // Monday
        recurringRule: 'RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR',
      );
      final result = service.expandItems(
        items: [item],
        start: DateTime(2025, 6, 2),
        end: DateTime(2025, 6, 8, 23, 59),
        exceptions: [],
      );
      // Mon June 2, Wed June 4, Fri June 6
      expect(result.length, 3);
      expect(result[0].occurrenceStart.weekday, DateTime.monday);
      expect(result[1].occurrenceStart.weekday, DateTime.wednesday);
      expect(result[2].occurrenceStart.weekday, DateTime.friday);
    });

    test('occurrences are sorted by start time', () {
      final item1 = makeItem(
          id: 1, startDate: DateTime(2025, 6, 15, 14, 0));
      final item2 = makeItem(
          id: 2, startDate: DateTime(2025, 6, 15, 9, 0));
      final result = service.expandItems(
        items: [item1, item2],
        start: DateTime(2025, 6, 15),
        end: DateTime(2025, 6, 15, 23, 59),
        exceptions: [],
      );
      expect(result.length, 2);
      expect(result[0].item.id, 2); // 9am first
      expect(result[1].item.id, 1); // 2pm second
    });
  });
}
