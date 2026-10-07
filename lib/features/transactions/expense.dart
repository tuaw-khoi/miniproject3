import 'package:intl/intl.dart';

enum ExpenseCategory { food, study, travel, gear, entertainment }

String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
DateTime weekStart(DateTime day) =>
    DateTime(day.year, day.month, day.day - day.weekday + 1);

class Expense {
  const Expense({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.date,
    required this.category,
    this.note = '',
    this.imagePath,
    this.thumbnailPath,
    this.rawText = '',
    required this.createdAt,
    required this.updatedAt,
  });
  final String id, merchant, note, rawText;
  final int amount;
  final DateTime date, createdAt, updatedAt;
  final ExpenseCategory category;
  final String? imagePath, thumbnailPath;

  Map<String, Object?> toMap() => {
    'id': id,
    'merchant': merchant,
    'amount': amount,
    'date': dayKey(date),
    'category': category.name,
    'note': note,
    'image_path': imagePath,
    'thumbnail_path': thumbnailPath,
    'raw_text': rawText,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
  factory Expense.fromMap(Map<String, Object?> m) => Expense(
    id: m['id'] as String,
    merchant: m['merchant'] as String,
    amount: m['amount'] as int,
    date: DateTime.parse(m['date'] as String),
    category: ExpenseCategory.values.byName(m['category'] as String),
    note: m['note'] as String,
    imagePath: m['image_path'] as String?,
    thumbnailPath: m['thumbnail_path'] as String?,
    rawText: m['raw_text'] as String,
    createdAt: DateTime.parse(m['created_at'] as String),
    updatedAt: DateTime.parse(m['updated_at'] as String),
  );
}

List<Expense> filterExpenses(
  List<Expense> items, {
  String query = '',
  ExpenseCategory? category,
  DateTime? start,
  DateTime? end,
}) {
  final q = query.toLowerCase().trim();
  return items
      .where(
        (e) =>
            (q.isEmpty ||
                '${e.merchant} ${e.note}'.toLowerCase().contains(q)) &&
            (category == null || e.category == category) &&
            (start == null || !e.date.isBefore(start)) &&
            (end == null ||
                e.date.isBefore(DateTime(end.year, end.month, end.day + 1))),
      )
      .toList();
}

Map<ExpenseCategory, int> categoryTotals(List<Expense> items) => {
  for (final c in ExpenseCategory.values)
    c: items.where((e) => e.category == c).fold(0, (s, e) => s + e.amount),
};
List<int> weeklyTotals(List<Expense> items, DateTime week) =>
    List.generate(7, (i) {
      final key = dayKey(DateTime(week.year, week.month, week.day + i));
      return items
          .where((e) => dayKey(e.date) == key)
          .fold(0, (s, e) => s + e.amount);
    });

String expensesCsv(List<Expense> items) {
  String cell(String value) {
    // Neutralize spreadsheet formula injection in user-entered text.
    final safe = RegExp(r'^[\s]*[=+@-]').hasMatch(value) ? "'$value" : value;
    return '"${safe.replaceAll('"', '""')}"';
  }

  return '\uFEFFdate,merchant,amount_vnd,category,note\r\n${items.map((e) => [dayKey(e.date), e.merchant, e.amount.toString(), e.category.name, e.note].map(cell).join(',')).join('\r\n')}';
}
