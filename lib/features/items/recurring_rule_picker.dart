import 'package:flutter/material.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

/// A bottom sheet picker that lets the user configure a recurrence rule
/// and returns an RRULE string (RFC 5545).
class RecurringRulePicker extends StatefulWidget {
  final String? initialRule;

  const RecurringRulePicker({super.key, this.initialRule});

  @override
  State<RecurringRulePicker> createState() => _RecurringRulePickerState();
}

enum _Frequency { none, daily, weekly, monthly }

class _RecurringRulePickerState extends State<RecurringRulePicker> {
  _Frequency _frequency = _Frequency.none;
  int _interval = 1;
  final Set<int> _weekdays = {}; // 0=Mon .. 6=Sun (ISO)
  int _monthDay = 1;
  DateTime? _until;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _rruleDays = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

  @override
  void initState() {
    super.initState();
    if (widget.initialRule != null) {
      _parseRule(widget.initialRule!);
    }
  }

  void _parseRule(String rule) {
    if (rule.contains('FREQ=DAILY')) {
      _frequency = _Frequency.daily;
    } else if (rule.contains('FREQ=WEEKLY')) {
      _frequency = _Frequency.weekly;
      final byDayMatch = RegExp(r'BYDAY=([A-Z,]+)').firstMatch(rule);
      if (byDayMatch != null) {
        for (final day in byDayMatch.group(1)!.split(',')) {
          final idx = _rruleDays.indexOf(day);
          if (idx >= 0) _weekdays.add(idx);
        }
      }
    } else if (rule.contains('FREQ=MONTHLY')) {
      _frequency = _Frequency.monthly;
      final byMonthDayMatch =
          RegExp(r'BYMONTHDAY=(\d+)').firstMatch(rule);
      if (byMonthDayMatch != null) {
        _monthDay = int.parse(byMonthDayMatch.group(1)!);
      }
    }

    final intervalMatch = RegExp(r'INTERVAL=(\d+)').firstMatch(rule);
    if (intervalMatch != null) {
      _interval = int.parse(intervalMatch.group(1)!);
    }

    final untilMatch = RegExp(r'UNTIL=(\d{8})').firstMatch(rule);
    if (untilMatch != null) {
      final s = untilMatch.group(1)!;
      _until = DateTime(
        int.parse(s.substring(0, 4)),
        int.parse(s.substring(4, 6)),
        int.parse(s.substring(6, 8)),
      );
    }
  }

  String? _buildRule() {
    if (_frequency == _Frequency.none) return null;

    final parts = <String>[];

    switch (_frequency) {
      case _Frequency.daily:
        parts.add('FREQ=DAILY');
      case _Frequency.weekly:
        parts.add('FREQ=WEEKLY');
        if (_weekdays.isNotEmpty) {
          final sorted = _weekdays.toList()..sort();
          parts.add('BYDAY=${sorted.map((i) => _rruleDays[i]).join(',')}');
        }
      case _Frequency.monthly:
        parts.add('FREQ=MONTHLY');
        parts.add('BYMONTHDAY=$_monthDay');
      case _Frequency.none:
        return null;
    }

    if (_interval > 1) {
      parts.add('INTERVAL=$_interval');
    }

    if (_until != null) {
      final u = _until!;
      parts.add(
          'UNTIL=${u.year.toString().padLeft(4, '0')}${u.month.toString().padLeft(2, '0')}${u.day.toString().padLeft(2, '0')}T235959Z');
    }

    return 'RRULE:${parts.join(';')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.repeat, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          // Frequency selector
          SegmentedButton<_Frequency>(
            segments: [
              ButtonSegment(value: _Frequency.none, label: Text(l10n.none)),
              ButtonSegment(value: _Frequency.daily, label: Text(l10n.daily)),
              ButtonSegment(value: _Frequency.weekly, label: Text(l10n.weekly)),
              ButtonSegment(
                  value: _Frequency.monthly, label: Text(l10n.monthly)),
            ],
            selected: {_frequency},
            onSelectionChanged: (v) =>
                setState(() => _frequency = v.first),
          ),
          const SizedBox(height: 12),

          // Interval
          if (_frequency != _Frequency.none)
            Row(
              children: [
                Text('${l10n.every} '),
                SizedBox(
                  width: 60,
                  child: DropdownButton<int>(
                    value: _interval,
                    isExpanded: true,
                    items: List.generate(
                        12, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (v) => setState(() => _interval = v!),
                  ),
                ),
                Text(_frequency == _Frequency.daily
                    ? ' ${l10n.dayUnit}'
                    : _frequency == _Frequency.weekly
                        ? ' ${l10n.weekUnit}'
                        : ' ${l10n.monthUnit}'),
              ],
            ),

          // Weekly: day selector
          if (_frequency == _Frequency.weekly) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              children: List.generate(7, (i) {
                final selected = _weekdays.contains(i);
                return FilterChip(
                  label: Text(_dayLabels[i]),
                  selected: selected,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        _weekdays.add(i);
                      } else {
                        _weekdays.remove(i);
                      }
                    });
                  },
                );
              }),
            ),
          ],

          // Monthly: day of month
          if (_frequency == _Frequency.monthly) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${l10n.onDay} '),
                SizedBox(
                  width: 60,
                  child: DropdownButton<int>(
                    value: _monthDay,
                    isExpanded: true,
                    items: List.generate(
                        31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
                    onChanged: (v) => setState(() => _monthDay = v!),
                  ),
                ),
              ],
            ),
          ],

          // Until date
          if (_frequency != _Frequency.none) ...[
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy),
              title: Text(_until != null
                  ? l10n.endsOn('${_until!.month}/${_until!.day}/${_until!.year}')
                  : l10n.noEndDate),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_until != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _until = null),
                    ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _until ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _until = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Save / Cancel
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.pop(context, _buildRule()),
                child: Text(l10n.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
