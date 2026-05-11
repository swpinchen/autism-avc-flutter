import 'package:flutter/material.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

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
  final l10n = AppLocalizations.of(context)!;
  return showDialog<RecurringEditChoice>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.editRecurringEvent),
      content: Text(l10n.editRecurringMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, RecurringEditChoice.thisOne),
          child: Text(l10n.justThisOne),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, RecurringEditChoice.all),
          child: Text(l10n.allEvents),
        ),
      ],
    ),
  );
}
