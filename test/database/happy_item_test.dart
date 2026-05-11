import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autism_avc_flutter/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('getNextHappyItem', () {
    test('returns null when no items exist', () async {
      final result = await db.getNextHappyItem();
      expect(result, isNull);
    });

    test('returns null when future items have no reviews', () async {
      await db.insertItem(ItemsCompanion.insert(
        title: 'Future event',
        startDate: DateTime.now().add(const Duration(days: 1)),
      ));

      final result = await db.getNextHappyItem();
      expect(result, isNull);
    });

    test('returns null when future items have only low ratings', () async {
      final id = await db.insertItem(ItemsCompanion.insert(
        title: 'Future event',
        startDate: DateTime.now().add(const Duration(days: 1)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: id,
        rating: 2,
        date: DateTime.now(),
      ));

      final result = await db.getNextHappyItem();
      expect(result, isNull);
    });

    test('returns item whose latest review has rating >= 3', () async {
      final id = await db.insertItem(ItemsCompanion.insert(
        title: 'Happy event',
        startDate: DateTime.now().add(const Duration(days: 1)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: id,
        rating: 3,
        date: DateTime.now(),
      ));

      final result = await db.getNextHappyItem();
      expect(result, isNotNull);
      expect(result!.title, 'Happy event');
    });

    test('returns the closest future happy item (not the farthest)', () async {
      // Farther item (10 days out)
      final farId = await db.insertItem(ItemsCompanion.insert(
        title: 'Far future happy',
        startDate: DateTime.now().add(const Duration(days: 10)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: farId,
        rating: 4,
        date: DateTime.now(),
      ));

      // Closer item (2 days out)
      final nearId = await db.insertItem(ItemsCompanion.insert(
        title: 'Near future happy',
        startDate: DateTime.now().add(const Duration(days: 2)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: nearId,
        rating: 3,
        date: DateTime.now(),
      ));

      final result = await db.getNextHappyItem();
      expect(result, isNotNull);
      expect(result!.title, 'Near future happy');
    });

    test('ignores past items even if they have high ratings', () async {
      final pastId = await db.insertItem(ItemsCompanion.insert(
        title: 'Past happy event',
        startDate: DateTime.now().subtract(const Duration(days: 1)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: pastId,
        rating: 4,
        date: DateTime.now(),
      ));

      final result = await db.getNextHappyItem();
      expect(result, isNull);
    });

    test('skips items with rating < 3 and picks the next happy one', () async {
      // Closest future item has low rating
      final lowId = await db.insertItem(ItemsCompanion.insert(
        title: 'Sad future event',
        startDate: DateTime.now().add(const Duration(days: 1)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: lowId,
        rating: 1,
        date: DateTime.now(),
      ));

      // Next future item has high rating
      final happyId = await db.insertItem(ItemsCompanion.insert(
        title: 'Happy future event',
        startDate: DateTime.now().add(const Duration(days: 3)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: happyId,
        rating: 4,
        date: DateTime.now(),
      ));

      final result = await db.getNextHappyItem();
      expect(result, isNotNull);
      expect(result!.title, 'Happy future event');
    });
  });

  group('getNextHappyItem with after parameter', () {
    test('searches relative to the given date, not now', () async {
      // Event between now and the 'after' date — should be skipped
      final earlyId = await db.insertItem(ItemsCompanion.insert(
        title: 'Early happy',
        startDate: DateTime.now().add(const Duration(days: 2)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: earlyId,
        rating: 4,
        date: DateTime.now(),
      ));

      // Event after the 'after' date — should be returned
      final lateId = await db.insertItem(ItemsCompanion.insert(
        title: 'Late happy',
        startDate: DateTime.now().add(const Duration(days: 10)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: lateId,
        rating: 3,
        date: DateTime.now(),
      ));

      final after = DateTime.now().add(const Duration(days: 5));
      final result = await db.getNextHappyItem(after: after);
      expect(result, isNotNull);
      expect(result!.title, 'Late happy');
    });

    test('returns null when no happy items exist after the given date',
        () async {
      final id = await db.insertItem(ItemsCompanion.insert(
        title: 'Happy but before after-date',
        startDate: DateTime.now().add(const Duration(days: 1)),
      ));
      await db.insertReview(ReviewsCompanion.insert(
        itemId: id,
        rating: 4,
        date: DateTime.now(),
      ));

      final after = DateTime.now().add(const Duration(days: 5));
      final result = await db.getNextHappyItem(after: after);
      expect(result, isNull);
    });
  });
}
