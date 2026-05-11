import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:drift/drift.dart' hide Column;
import 'package:autism_avc_flutter/core/database/database.dart';
import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/features/items/recurring_edit_dialog.dart';
import 'package:autism_avc_flutter/features/reviews/review_bottom_sheet.dart';

class ItemDetailScreen extends ConsumerWidget {
  final int itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return StreamBuilder(
      stream: db.watchItem(itemId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final item = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: Text(item.title),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  if (item.recurringRule != null &&
                      item.recurringRule!.isNotEmpty) {
                    final choice =
                        await showRecurringEditDialog(context);
                    if (choice == null || !context.mounted) return;

                    if (choice == RecurringEditChoice.thisOne) {
                      // Create exception for this date + duplicate
                      await db.insertException(
                          ItemExceptionsCompanion.insert(
                        itemId: item.id,
                        startTime: item.startDate,
                      ));
                      final newId = await db.insertItem(
                          ItemsCompanion.insert(
                        title: item.title,
                        details: Value(item.details),
                        startDate: item.startDate,
                        endDate: Value(item.endDate),
                        imagePath: Value(item.imagePath),
                      ));
                      if (context.mounted) {
                        context.push('/items/$newId/edit');
                      }
                      return;
                    }
                  }
                  context.push('/items/${item.id}/edit');
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Event'),
                      content: const Text(
                          'Are you sure you want to delete this event?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true && context.mounted) {
                    await db.deleteItem(item.id);
                    if (context.mounted) context.pop();
                  }
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photo
                if (item.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item.imagePath!),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),

                // Date/time
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.yMMMd().add_jm().format(item.startDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                if (item.endDate != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const SizedBox(width: 26),
                      Text(
                        'to ${DateFormat.jm().format(item.endDate!)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                if (item.recurringRule != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.repeat, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Recurring: ${item.recurringRule}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),

                // Details
                Text(
                  item.details,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // TTS button
                FilledButton.icon(
                  onPressed: () => ttsService.speak(item.details),
                  icon: const Icon(Icons.volume_up),
                  label: const Text('Read Aloud'),
                ),
                const SizedBox(height: 12),

                // Review button
                OutlinedButton.icon(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => ReviewBottomSheet(itemId: item.id),
                    );
                  },
                  icon: const Icon(Icons.star),
                  label: const Text('Review'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
