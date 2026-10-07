import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:receipt_flow/core/app_state.dart';
import 'package:receipt_flow/main.dart';
import 'package:receipt_flow/features/transactions/transaction_repository.dart';
import 'package:receipt_flow/features/analytics/charts.dart';
import 'package:receipt_flow/features/transactions/expense.dart';
import 'package:receipt_flow/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late AppServices services;
  late Directory dir;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('receiptflow-ui-');
    final personal = await TransactionRepository.open(
      inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    final demo = await TransactionRepository.open(
      inMemoryDatabasePath,
      factory: databaseFactoryFfi,
    );
    services = AppServices(
      dir,
      await SharedPreferences.getInstance(),
      personal,
      demo,
      [],
    );
  });
  tearDown(() async {
    await services.personal.close();
    await services.demo.close();
    await dir.delete(recursive: true);
  });
  testWidgets('manual validation, save, and language switch', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [servicesProvider.overrideWithValue(services)],
        child: const ReceiptFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ReceiptFlow'), findsOneWidget);
    await tester.tap(find.byTooltip('Nhập thủ công'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('save')));
    await tester.tap(find.byKey(const Key('save')));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập thông tin'), findsWidgets);
    await tester.enterText(find.byKey(const Key('merchant')), 'Campus Coffee');
    await tester.enterText(find.byKey(const Key('amount')), '59000');
    await tester.ensureVisible(find.byKey(const Key('category')));
    await tester.tap(find.byKey(const Key('category')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ăn uống').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('save')));
    await tester.tap(find.byKey(const Key('save')));
    await tester.runAsync(() async {
      expect((await services.personal.all()).single.amount, 59000);
    });
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cài đặt').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
  testWidgets('empty charts and legend selection', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                DonutChart(values: categoryTotals([])),
                const WeeklyBarChart(values: [0, 0, 0, 0, 0, 0, 0]),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No spending in this period'), findsOneWidget);
    await tester.tap(find.text('Food'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
