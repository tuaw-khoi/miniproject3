import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_flow/features/transactions/expense.dart';

Expense e(
  String id,
  int amount,
  DateTime date,
  ExpenseCategory category, {
  String merchant = 'Shop',
  String note = '',
}) => Expense(
  id: id,
  merchant: merchant,
  amount: amount,
  date: date,
  category: category,
  note: note,
  createdAt: date,
  updatedAt: date,
);
void main() {
  final items = [
    e('1', 100, DateTime(2026, 12, 31), ExpenseCategory.food),
    e('2', 200, DateTime(2027, 1, 1), ExpenseCategory.study),
    e(
      '3',
      300,
      DateTime(2027, 1, 3),
      ExpenseCategory.food,
      merchant: 'Coffee Campus',
      note: 'Friends',
    ),
  ];
  test('weekly grouping crosses year and includes zero days', () {
    expect(weekStart(DateTime(2027, 1, 3)), DateTime(2026, 12, 28));
    expect(weeklyTotals(items, DateTime(2026, 12, 28)), [
      0,
      0,
      0,
      100,
      200,
      0,
      300,
    ]);
  });
  test('combined filter with inclusive end date', () {
    expect(
      filterExpenses(
        items,
        query: 'friends',
        category: ExpenseCategory.food,
        start: DateTime(2027),
        end: DateTime(2027, 1, 3),
      ).map((e) => e.id),
      ['3'],
    );
    expect(
      filterExpenses(items, query: 'friends', category: ExpenseCategory.study),
      isEmpty,
    );
  });
  test('exact category sums', () {
    expect(categoryTotals(items)[ExpenseCategory.food], 400);
    expect(categoryTotals(items)[ExpenseCategory.gear], 0);
  });
  test('CSV quotes text and neutralizes formulas', () {
    final csv = expensesCsv([
      e(
        'x',
        150000,
        DateTime(2026, 10, 7),
        ExpenseCategory.food,
        merchant: '=SUM(1,2)',
        note: 'A "quote"\nB',
      ),
    ]);
    expect(csv, startsWith('\uFEFF'));
    expect(csv, contains('"\'=SUM(1,2)"'));
    expect(csv, contains('"A ""quote""\nB"'));
  });
  test(
    'serialization round trip',
    () =>
        expect(Expense.fromMap(items.last.toMap()).toMap(), items.last.toMap()),
  );
}
