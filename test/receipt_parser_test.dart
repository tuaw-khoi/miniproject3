import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_flow/features/receipts/receipt_parser.dart';
import 'package:receipt_flow/features/transactions/expense.dart';

void main() {
  final parser = ReceiptParser();
  final fixtures = <String, int?>{
    'Total: 150,000 VND': 150000,
    'Tổng thanh toán 150.000 đ': 150000,
    'TOTAL 150000': 150000,
    'TOTAL 150 000': 150000,
    'Tổng cộng 1.250.000 đ': 1250000,
    'Grand total 150,000.00': 150000,
    'Grand total 150.000,00': 150000,
    'Amount due 75000': 75000,
    'Total due 75000': 75000,
    'Phải trả: 25000': 25000,
    'Tổng tiền: 59000': 59000,
    'Thành tiền: 95000': 95000,
    'Tổng thanh toán\n150.000 VND': 150000,
    'TOTAL 30000\nCash 100000\nChange 70000': 30000,
    'Tổng thanh toán 150000\nTiền khách đưa 500000\nTiền thừa 350000': 150000,
    'Tạm tính 200000\nGiảm giá 50000\nTổng thanh toán 150000': 150000,
    'Subtotal 300000': null,
    'Tiền khách đưa 500000 VND': null,
    'VAT 10% 15000 VND': null,
    'Tel 0901234567': null,
    '07/10/2026': null,
    '': null,
    'TOTAL 0': null,
    'TOTAL 100000\nTOTAL 120000': null,
    'TOTAL 150000\nTOTAL 150000': 150000,
    'Total 100000\nGrand total 110000': 110000,
    'Thành tiền 50000\nTổng thanh toán 100000': 100000,
    'TỔNG THANH TOÁN 350.000 Đ': 350000,
    'TOTAL: 123,456': 123456,
    'TOTAL 1': 1,
    'TOTAL 1000000000000': null,
    'TOTAL\nCash 500000': null,
  };
  for (final fixture in fixtures.entries) {
    test(
      'amount: ${fixture.key}',
      () => expect(parser.parse(fixture.key).amount, fixture.value),
    );
  }
  test('full Vietnamese receipt', () {
    final result = parser.parse(
      'Minimart Campus\nHÓA ĐƠN\nNgày 07/10/2026\nTổng thanh toán: 150.000 đ\nTiền khách đưa: 200.000 đ',
    );
    expect(result.merchant, 'Minimart Campus');
    expect(result.date, DateTime(2026, 10, 7));
    expect(result.category, ExpenseCategory.food);
    expect(result.issues, isEmpty);
  });
  test(
    'skips generic header and address',
    () => expect(
      parser
          .parse('HÓA ĐƠN BÁN HÀNG\nĐịa chỉ 42 Đà Nẵng\nNHÀ SÁCH PHƯƠNG NAM')
          .merchant,
      'NHÀ SÁCH PHƯƠNG NAM',
    ),
  );
  test(
    'rejects impossible date',
    () => expect(parser.parse('31/02/2026').date, isNull),
  );
  test(
    'rejects non-leap February',
    () => expect(parser.parse('29/02/2025').date, isNull),
  );
  test(
    'accepts leap February',
    () => expect(parser.parse('29-02-2024').date, DateTime(2024, 2, 29)),
  );
  test('multiple dates require review', () {
    final r = parser.parse('07/10/2026\n08/10/2026');
    expect(r.date, isNull);
    expect(r.issues, contains(ParseIssue.ambiguousDate));
  });
  test(
    'fallback amount requests review',
    () => expect(
      parser.parse('150000 VND').issues,
      contains(ParseIssue.ambiguousAmount),
    ),
  );
  test('category suggestions', () {
    expect(parser.parse('ABC Company').category, isNull);
    expect(parser.parse('Grab Bike').category, ExpenseCategory.travel);
    expect(parser.parse('CGV Cinema').category, ExpenseCategory.entertainment);
  });
}
