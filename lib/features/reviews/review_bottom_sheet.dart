import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:autism_avc_flutter/core/database/database.dart';
import 'package:autism_avc_flutter/core/providers/providers.dart';
import 'package:autism_avc_flutter/l10n/app_localizations.dart';

class ReviewBottomSheet extends ConsumerStatefulWidget {
  final int itemId;

  const ReviewBottomSheet({super.key, required this.itemId});

  @override
  ConsumerState<ReviewBottomSheet> createState() => _ReviewBottomSheetState();
}

class _ReviewBottomSheetState extends ConsumerState<ReviewBottomSheet> {
  int? _selectedRating;
  String? _happyMessage;
  bool _submitted = false;

  // Emoji labels matching the Rails 1–4 scale
  static const _ratingEmojis = ['😢', '😐', '🙂', '😄'];

  List<String> _ratingLabels(AppLocalizations l10n) =>
      [l10n.ratingSad, l10n.ratingOkay, l10n.ratingGood, l10n.ratingGreat];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _submitted ? _buildResult(l10n) : _buildRatingPicker(l10n),
    );
  }

  Widget _buildRatingPicker(AppLocalizations l10n) {
    final labels = _ratingLabels(l10n);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.howDoYouFeel,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            final rating = index + 1; // 1–4
            final isSelected = _selectedRating == rating;
            return GestureDetector(
              onTap: () => setState(() => _selectedRating = rating),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primaryContainer
                          : null,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            )
                          : null,
                    ),
                    child: Text(
                      _ratingEmojis[index],
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _selectedRating != null ? _submit : null,
          child: Text(l10n.submit),
        ),
      ],
    );
  }

  Widget _buildResult(AppLocalizations l10n) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _ratingEmojis[_selectedRating! - 1],
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.thankYou,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        if (_happyMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _happyMessage!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.done),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final db = ref.read(databaseProvider);

    // Save the review
    await db.insertReview(ReviewsCompanion.insert(
      itemId: widget.itemId,
      rating: _selectedRating!,
      date: DateTime.now(),
    ));

    // MakeSentence: if rating == 1, show encouraging message
    String? happy;
    if (_selectedRating == 1) {
      final happyItem = await db.getNextHappyItem();
      if (happyItem != null && mounted) {
        final l10n = AppLocalizations.of(context)!;
        happy = l10n.happyMessage(happyItem.details);
      }
    }

    setState(() {
      _submitted = true;
      _happyMessage = happy;
    });
  }
}
