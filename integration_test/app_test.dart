import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:receipt_flow/core/app_state.dart';
import 'package:receipt_flow/main.dart';
import 'package:receipt_flow/features/receipts/ocr_service.dart';
import 'package:receipt_flow/features/receipts/receipt_parser.dart';
import 'package:receipt_flow/features/receipts/receipt_image_store.dart';
import 'package:receipt_flow/features/transactions/expense.dart';
import 'package:receipt_flow/features/transactions/transaction_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native OCR, thumbnail, SQLite persistence and UI', (
    tester,
  ) async {
    final root = Directory(
      '${(await getTemporaryDirectory()).path}/receiptflow_integration',
    );
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
    await root.create(recursive: true);
    final bytes = await rootBundle.load('assets/receipts/sample_receipt.jpg');
    final source = File('${root.path}/sample.jpg');
    await source.writeAsBytes(bytes.buffer.asUint8List());
    final ocr = OcrService();
    final elapsed = <int>[];
    final whole = Stopwatch()..start();
    final first = await ocr.recognize(source.path);
    final parsed = ReceiptParser().parse(first.text);
    whole.stop();
    expect(parsed.amount, 150000);
    expect(parsed.date, DateTime(2026, 10, 7));
    expect(parsed.merchant, contains('MINIMART'));
    for (var i = 0; i < 10; i++) {
      elapsed.add((await ocr.recognize(source.path)).elapsed.inMicroseconds);
    }
    elapsed.sort();
    final metrics = {
      'device': Platform.operatingSystem,
      'fixture': 'sample_receipt.jpg (1000x1500)',
      'cold_ocr_ms': first.elapsed.inMicroseconds / 1000,
      'warm_runs': elapsed.length,
      'warm_median_ms': (elapsed[4] + elapsed[5]) / 2000,
      'warm_p95_ms': elapsed[9] / 1000,
      'cold_ocr_and_parse_ms': whole.elapsedMicroseconds / 1000,
      'raw_text': first.text,
      'parsed_amount': parsed.amount,
    };
    // Captured in the integration runner log; no production telemetry.
    debugPrint('RECEIPTFLOW_BENCHMARK ${jsonEncode(metrics)}');
    await ocr.close();
    final images = ReceiptImageStore(Directory('${root.path}/receipts'));
    final stored = await images.save(source.path, 'integration-receipt');
    expect(await File(stored.thumbnail).exists(), true);
    var repo = await TransactionRepository.open('${root.path}/test.db');
    final date = DateTime.now();
    await repo.save(
      Expense(
        id: 'native',
        merchant: parsed.merchant!,
        amount: parsed.amount!,
        date: parsed.date!,
        category: ExpenseCategory.food,
        imagePath: stored.image,
        thumbnailPath: stored.thumbnail,
        rawText: first.text,
        createdAt: date,
        updatedAt: date,
      ),
    );
    await repo.close();
    repo = await TransactionRepository.open('${root.path}/test.db');
    expect((await repo.all()).single.amount, 150000);
    final demo = await TransactionRepository.open('${root.path}/demo.db');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', 'vi');
    await prefs.setBool('demo', false);
    final services = AppServices(root, prefs, repo, demo, await repo.all());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [servicesProvider.overrideWithValue(services)],
        child: const ReceiptFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ReceiptFlow'), findsOneWidget);
    await tester.tap(find.text('Giao dịch').last);
    await tester.pumpAndSettle();
    expect(find.text(parsed.merchant!), findsOneWidget);
    await tester.tap(find.text(parsed.merchant!));
    await tester.pumpAndSettle();
    expect(find.text('150.000 ₫'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await repo.close();
    await demo.close();
    await root.delete(recursive: true);
  });
}
