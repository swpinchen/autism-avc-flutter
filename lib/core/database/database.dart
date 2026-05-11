import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

// ── Tables ──────────────────────────────────────────────────────────────────

class Items extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1)();
  TextColumn get details => text().withDefault(const Constant(''))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  TextColumn get recurringRule => text().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get category => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  DateTimeColumn get lastOpened => dateTime().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Reviews extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(Items, #id)();
  IntColumn get rating => integer()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class ItemExceptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId => integer().references(Items, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

// ── Database ────────────────────────────────────────────────────────────────

@DriftDatabase(tables: [Items, Reviews, ItemExceptions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  // ── Item queries ────────────────────────────────────────────────────────

  Future<List<Item>> getAllItems() => select(items).get();

  Stream<List<Item>> watchAllItems() => select(items).watch();

  Future<Item> getItem(int id) =>
      (select(items)..where((t) => t.id.equals(id))).getSingle();

  Stream<Item> watchItem(int id) =>
      (select(items)..where((t) => t.id.equals(id))).watchSingle();

  Future<List<Item>> getItemsInRange(DateTime start, DateTime end) =>
      (select(items)
            ..where(
                (t) => t.startDate.isBiggerOrEqualValue(start) &
                        t.startDate.isSmallerOrEqualValue(end)))
          .get();

  Stream<List<Item>> watchItemsForRecurrence() => select(items).watch();

  Future<int> insertItem(ItemsCompanion entry) => into(items).insert(entry);

  Future<bool> updateItem(ItemsCompanion entry) =>
      update(items).replace(entry);

  Future<int> deleteItem(int id) =>
      (delete(items)..where((t) => t.id.equals(id))).go();

  Future<List<Item>> searchItemsByTitle(String query) =>
      (select(items)
            ..where((t) => t.title.like('%$query%')))
          .get();

  // ── Review queries ──────────────────────────────────────────────────────

  Future<List<Review>> getReviewsForItem(int itemId) =>
      (select(reviews)..where((t) => t.itemId.equals(itemId))).get();

  Stream<List<Review>> watchReviewsForItem(int itemId) =>
      (select(reviews)..where((t) => t.itemId.equals(itemId))).watch();

  Future<Review?> getLastReviewForItem(int itemId) =>
      (select(reviews)
            ..where((t) => t.itemId.equals(itemId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> insertReview(ReviewsCompanion entry) =>
      into(reviews).insert(entry);

  // ── ItemException queries ───────────────────────────────────────────────

  Future<List<ItemException>> getExceptionsForItem(int itemId) =>
      (select(itemExceptions)..where((t) => t.itemId.equals(itemId))).get();

  Stream<List<ItemException>> watchExceptionsForItem(int itemId) =>
      (select(itemExceptions)..where((t) => t.itemId.equals(itemId))).watch();

  Future<List<ItemException>> getAllExceptions() =>
      select(itemExceptions).get();

  Future<int> insertException(ItemExceptionsCompanion entry) =>
      into(itemExceptions).insert(entry);

  // ── Happy item query (MakeSentence) ─────────────────────────────────────

  /// Find the next upcoming item that has a review rating >= 3.
  Future<Item?> getNextHappyItem() async {
    final now = DateTime.now();
    final upcomingItems = await (select(items)
          ..where((t) => t.startDate.isBiggerThanValue(now))
          ..orderBy([(t) => OrderingTerm.asc(t.startDate)]))
        .get();

    for (final item in upcomingItems) {
      final lastReview = await getLastReviewForItem(item.id);
      if (lastReview != null && lastReview.rating >= 3) {
        return item;
      }
    }
    return null;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'autism_avc.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
