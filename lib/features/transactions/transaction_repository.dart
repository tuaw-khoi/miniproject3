import 'package:sqflite/sqflite.dart';
import 'expense.dart';

class TransactionRepository {
  TransactionRepository(this.db);
  final Database db;
  static Future<TransactionRepository> open(
    String path, {
    DatabaseFactory? factory,
  }) async {
    final db = await (factory ?? databaseFactory).openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''CREATE TABLE expenses (
          id TEXT PRIMARY KEY, merchant TEXT NOT NULL, amount INTEGER NOT NULL CHECK(amount > 0),
          date TEXT NOT NULL, category TEXT NOT NULL, note TEXT NOT NULL DEFAULT '',
          image_path TEXT, thumbnail_path TEXT, raw_text TEXT NOT NULL DEFAULT '',
          created_at TEXT NOT NULL, updated_at TEXT NOT NULL)''');
          await db.execute('CREATE INDEX expenses_date ON expenses(date DESC)');
        },
      ),
    );
    return TransactionRepository(db);
  }

  Future<List<Expense>> all() async => (await db.query(
    'expenses',
    orderBy: 'date DESC, created_at DESC',
  )).map(Expense.fromMap).toList();
  Future<void> save(Expense e, {bool update = false}) async {
    if (e.merchant.trim().isEmpty || e.amount <= 0 || e.amount > 999999999999) {
      throw ArgumentError('Invalid expense');
    }
    if (update) {
      final count = await db.update(
        'expenses',
        e.toMap(),
        where: 'id = ?',
        whereArgs: [e.id],
      );
      if (count != 1) {
        throw StateError('Expense no longer exists');
      }
    } else {
      await db.insert('expenses', e.toMap());
    }
  }

  Future<void> delete(String id) =>
      db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  Future<void> close() => db.close();
}
