import 'package:flutter/material.dart';

/// Result of the recurring edit dialog.
enum RecurringEditChoice {
  /// Edit all occurrences (the original item).
  all,

  /// Edit only this occurrence (create exception + duplicate).
  thisOne,
}

/// Shows a dialog asking whether to edit all occurrences or just this one.
/// Returns null if cancelled.
Future<RecurringEditChoice?> showRecurringEditDialog(
    BuildContext context) async {
  return showDialog<RecurringEditChoice>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Edit Recurring Event'),
      content: const Text(
          'Do you want to edit all occurrences or just this one?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, RecurringEditChoice.thisOne),
          child: const Text('Just This One'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, RecurringEditChoice.all),
          child: const Text('All Events'),
        ),
      ],
    ),
  );
}
