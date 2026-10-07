import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:receipt_flow/features/transactions/transaction_repository.dart';
import 'package:receipt_flow/features/transactions/expense.dart';

void main() {
  sqfliteFfiInit();
  late Directory temp;
  late TransactionRepository repo;
  final date = DateTime(2026, 10, 7);
  Expense expense(int amount) => Expense(
    id: 'one',
    merchant: 'Campus',
    amount: amount,
    date: date,
    category: ExpenseCategory.food,
    createdAt: date,
    updatedAt: date,
  );
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('receiptflow-test-');
    repo = await TransactionRepository.open(
      '${temp.path}/test.db',
      factory: databaseFactoryFfi,
    );
  });
  tearDown(() async {
    await repo.close();
    await temp.delete(recursive: true);
  });
  test('CRUD survives reopen', () async {
    await repo.save(expense(150000));
    await repo.close();
    repo = await TransactionRepository.open(
      '${temp.path}/test.db',
      factory: databaseFactoryFfi,
    );
    expect((await repo.all()).single.amount, 150000);
    await repo.save(expense(125000), update: true);
    expect((await repo.all()).single.amount, 125000);
    await repo.delete('one');
    expect(await repo.all(), isEmpty);
  });
  test('duplicate insert preserves original', () async {
    await repo.save(expense(100));
    await expectLater(
      repo.save(expense(200)),
      throwsA(isA<DatabaseException>()),
    );
    expect((await repo.all()).single.amount, 100);
  });
  test('invalid amount and missing update', () async {
    await expectLater(repo.save(expense(0)), throwsArgumentError);
    await expectLater(repo.save(expense(100), update: true), throwsStateError);
  });
  test('demo and personal DB isolated', () async {
    final demo = await TransactionRepository.open(
      '${temp.path}/demo.db',
      factory: databaseFactoryFfi,
    );
    await demo.save(expense(500));
    expect(await repo.all(), isEmpty);
    expect((await demo.all()).length, 1);
    await demo.close();
  });
}
