import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/services/recurrence_service.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(allItemsProvider);
    final exceptionsAsync = ref.watch(allExceptionsProvider);
    final recurrenceService = ref.watch(recurrenceServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final date = _selectedDay ?? _focusedDay;
          context.push('/items/new?date=${date.toIso8601String()}');
        },
        child: const Icon(Icons.add),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          final exceptions = exceptionsAsync.valueOrNull ?? [];

          // Expand items for the visible month range
          final monthStart = DateTime(_focusedDay.year, _focusedDay.month, 1);
          final monthEnd = DateTime(_focusedDay.year, _focusedDay.month + 1, 0,
              23, 59, 59);

          final allOccurrences = recurrenceService.expandItems(
            items: items,
            start: monthStart,
            end: monthEnd,
            exceptions: exceptions,
          );

          // Group by date
          final eventsByDay = <DateTime, List<ItemOccurrence>>{};
          for (final occ in allOccurrences) {
            final day = DateTime(occ.occurrenceStart.year,
                occ.occurrenceStart.month, occ.occurrenceStart.day);
            eventsByDay.putIfAbsent(day, () => []).add(occ);
          }

          // Selected day's events
          final selectedDayKey = _selectedDay != null
              ? DateTime(_selectedDay!.year, _selectedDay!.month,
                  _selectedDay!.day)
              : DateTime(
                  _focusedDay.year, _focusedDay.month, _focusedDay.day);
          final selectedEvents = eventsByDay[selectedDayKey] ?? [];

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime(2020),
                lastDay: DateTime(2030),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    _selectedDay != null && isSameDay(day, _selectedDay),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                onPageChanged: (focused) {
                  _focusedDay = focused;
                },
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return eventsByDay[key] ?? [];
                },
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: selectedEvents.isEmpty
                    ? const Center(child: Text('No events on this day'))
                    : ListView.builder(
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          final occ = selectedEvents[index];
                          final timeStr = DateFormat.jm()
                              .format(occ.occurrenceStart);
                          return ListTile(
                            leading: occ.item.imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.file(
                                      File(occ.item.imagePath!),
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.event)),
                            title: Text(occ.item.title),
                            subtitle: Text(timeStr),
                            onTap: () =>
                                context.push('/items/${occ.item.id}'),
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
