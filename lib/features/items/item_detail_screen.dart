import 'dart:io';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:drift/drift.dart' hide Column;
import 'package:autism_avc_flutter/core/database/database.dart';
import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/core/theme/app_colors.dart';
import 'package:autism_avc_flutter/features/items/recurring_edit_dialog.dart';
import 'package:autism_avc_flutter/features/reviews/review_bottom_sheet.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

/// Rating emojis matching the Rails 1–4 scale.
const _kRatingEmojis = ['😢', '😐', '🙂', '😄'];

class ItemDetailScreen extends ConsumerStatefulWidget {
  final int itemId;

  const ItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  late final ConfettiController _confettiController;
  Review? _lastReview;

  static const _confettiColors = [
    AppColors.primaryBlueLighter20,
    AppColors.primaryBlueLighter10,
    AppColors.primaryBlueBase,
    AppColors.blossomPinkLighter10,
    AppColors.blossomPinkBase,
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
    _loadLastReview();
  }

  Future<void> _loadLastReview() async {
    final db = ref.read(databaseProvider);
    final review = await db.getLastReviewForItem(widget.itemId);
    if (mounted) setState(() => _lastReview = review);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);
    final ttsService = ref.watch(ttsServiceProvider);

    return StreamBuilder(
      stream: db.watchItem(widget.itemId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final item = snapshot.data!;
        final l10n = AppLocalizations.of(context)!;

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
                      title: Text(l10n.deleteEvent),
                      content: Text(l10n.deleteConfirm),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.cancel),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(l10n.delete),
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
          body: Stack(
            children: [
              // ── Confetti layer ────────────────────────────────────
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirection: pi / 2, // downward
                  emissionFrequency: 0.04,
                  numberOfParticles: 12,
                  maxBlastForce: 20,
                  minBlastForce: 8,
                  gravity: 0.15,
                  colors: _confettiColors,
                ),
              ),

              // ── Content ──────────────────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Centered image
                    if (item.imagePath != null)
                      FractionallySizedBox(
                        widthFactor: 0.85,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26000000),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              File(item.imagePath!),
                              height: 240,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, e, st) => Container(
                                height: 240,
                                decoration: BoxDecoration(
                                  color: AppColors.neutralGrayLighter20,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                    Icons.image_not_supported,
                                    size: 48,
                                    color: AppColors.neutralGrayBase),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Mood emoji indicator
                    const SizedBox(height: 12),
                    if (_lastReview != null)
                      Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: AppColors.neutralGrayLighter20,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x26484848),
                              blurRadius: 4,
                              offset: Offset(1, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _kRatingEmojis[
                              (_lastReview!.rating - 1).clamp(0, 3)],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Date/time
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.schedule, size: 18,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7)),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat.yMMMd(l10n.localeName)
                              .add_jm()
                              .format(item.startDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    if (item.endDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'to ${DateFormat.jm(l10n.localeName).format(item.endDate!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (item.recurringRule != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.repeat, size: 18,
                              color: AppColors.primaryBlueBase),
                          const SizedBox(width: 8),
                          Text(
                            '${l10n.recurringLabel}: ${item.recurringRule}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Details
                    if (item.details.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          item.details,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              ttsService.speak(item.details),
                          icon: const Icon(Icons.volume_up, size: 20),
                          label: Text(l10n.readAloud),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (_) =>
                                  ReviewBottomSheet(itemId: item.id),
                            ).then((_) => _loadLastReview());
                          },
                          icon: const Icon(Icons.star, size: 20),
                          label: Text(l10n.review),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Go back button (Figma style)
                    FilledButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.chevron_left, size: 20),
                      label: Text(l10n.goBack),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
