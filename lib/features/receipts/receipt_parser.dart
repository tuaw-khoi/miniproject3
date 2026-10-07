import '../transactions/expense.dart';

enum ParseIssue {
  missingAmount,
  ambiguousAmount,
  missingDate,
  ambiguousDate,
  missingMerchant,
}

class ParsedReceipt {
  const ParsedReceipt({
    this.merchant,
    this.amount,
    this.date,
    this.category,
    required this.issues,
  });
  final String? merchant;
  final int? amount;
  final DateTime? date;
  final ExpenseCategory? category;
  final Set<ParseIssue> issues;
}

String normalizeReceipt(String text) {
  const groups = {
    'a': 'àáạảãâầấậẩẫăằắặẳẵ',
    'e': 'èéẹẻẽêềếệểễ',
    'i': 'ìíịỉĩ',
    'o': 'òóọỏõôồốộổỗơờớợởỡ',
    'u': 'ùúụủũưừứựửữ',
    'y': 'ỳýỵỷỹ',
    'd': 'đ',
  };
  var result = text.toLowerCase();
  groups.forEach((letter, accents) {
    for (final rune in accents.runes) {
      result = result.replaceAll(String.fromCharCode(rune), letter);
    }
  });
  return result
      .replaceAll(RegExp(r'[^a-z0-9\n.,/\-:]'), ' ')
      .replaceAll(RegExp(r'[ \t]+'), ' ')
      .trim();
}

class ReceiptParser {
  static final _date = RegExp(r'\b(\d{1,2})[/\-](\d{1,2})[/\-](\d{4})\b');
  static final _money = RegExp(
    r'(?<![\d/\-])(?:\d{1,3}(?:[., ]\d{3})+|\d+)(?:[.,]00)?(?![\d/\-])',
  );
  static final _negative = RegExp(
    r'tam tinh|sub\s*total|tien (khach|thua|tra lai)|khach (dua|tra)|cash|change|vat|thue|giam gia|discount|so dt|dien thoai|tel|phone|ma so|mst|tax|tiet kiem',
  );

  ParsedReceipt parse(String text) {
    final original = text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final lines = original.map(normalizeReceipt).toList();
    final issues = <ParseIssue>{};
    final candidates = <({int amount, int score})>[];
    final dates = <DateTime>{};
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      for (final m in _date.allMatches(line)) {
        final d = int.parse(m[1]!), mo = int.parse(m[2]!), y = int.parse(m[3]!);
        final date = DateTime(y, mo, d);
        if (y >= 2000 &&
            y <= 2100 &&
            date.year == y &&
            date.month == mo &&
            date.day == d) {
          dates.add(date);
        }
      }
      if (_negative.hasMatch(line)) {
        continue;
      }
      var score = 0;
      if (RegExp(
        r'tong thanh toan|grand total|amount due|total due|phai tra',
      ).hasMatch(line)) {
        score = 100;
      } else if (RegExp(
        r'tong cong|tong tien|\btotal\b|thanh toan',
      ).hasMatch(line)) {
        score = 85;
      } else if (line.startsWith('thanh tien')) {
        score = 60;
      }
      var amounts = _amounts(line);
      if (score > 0 &&
          amounts.isEmpty &&
          i + 1 < lines.length &&
          !_negative.hasMatch(lines[i + 1])) {
        amounts = _amounts(lines[i + 1]);
      }
      if (score == 0 && RegExp(r'vnd|\bd\b').hasMatch(line)) {
        score = 10;
      }
      if (score > 0) {
        for (final amount in amounts) {
          candidates.add((amount: amount, score: score));
        }
      }
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));
    int? amount;
    if (candidates.isEmpty) {
      issues.add(ParseIssue.missingAmount);
    } else {
      final best = candidates
          .where((c) => c.score == candidates.first.score)
          .map((c) => c.amount)
          .toSet();
      if (best.length == 1) {
        amount = best.single;
      }
      if (best.length > 1 || candidates.first.score < 60) {
        issues.add(ParseIssue.ambiguousAmount);
      }
    }
    if (dates.isEmpty) {
      issues.add(ParseIssue.missingDate);
    }
    if (dates.length > 1) {
      issues.add(ParseIssue.ambiguousDate);
    }
    String? merchant;
    for (var i = 0; i < original.length && i < 6; i++) {
      final l = lines[i];
      if (l.length >= 3 &&
          RegExp(r'[a-z]{2}').hasMatch(l) &&
          !RegExp(
            r'hoa don|receipt|invoice|dia chi|address|\bdc\b|\btel\b|phone|\bdt\b|ngay|date|mst|ma so|thank|cam on|tong|total',
          ).hasMatch(l) &&
          !_date.hasMatch(l) &&
          !RegExp(r'^\d').hasMatch(l)) {
        merchant = original[i];
        break;
      }
    }
    if (merchant == null) {
      issues.add(ParseIssue.missingMerchant);
    }
    final all = lines.join(' ');
    ExpenseCategory? category;
    if (RegExp(r'sach|book|stationery|van phong pham|hoc phi').hasMatch(all)) {
      category = ExpenseCategory.study;
    } else if (RegExp(r'grab|taxi|petrol|xang|bus|parking').hasMatch(all)) {
      category = ExpenseCategory.travel;
    } else if (RegExp(r'cinema|movie|cgv|game|bhd').hasMatch(all)) {
      category = ExpenseCategory.entertainment;
    } else if (RegExp(
      r'electronic|dien may|computer|gear|phu kien',
    ).hasMatch(all)) {
      category = ExpenseCategory.gear;
    } else if (RegExp(
      r'coffee|cafe|mart|food|\bcom\b|\bbun\b|\bpho\b|tra sua|restaurant',
    ).hasMatch(all)) {
      category = ExpenseCategory.food;
    }
    return ParsedReceipt(
      merchant: merchant,
      amount: amount,
      date: dates.length == 1 ? dates.single : null,
      category: category,
      issues: issues,
    );
  }

  List<int> _amounts(String line) {
    final clean = line
        .replaceAll(_date, '')
        .replaceAll(RegExp(r'\b\d{1,2}:\d{2}(?::\d{2})?\b'), '');
    return _money
        .allMatches(clean)
        .map((m) {
          var value = m[0]!;
          if (RegExp(r'[.,]00$').hasMatch(value)) {
            value = value.substring(0, value.length - 3);
          }
          return int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        })
        .where((v) => v > 0 && v <= 999999999999)
        .toList();
  }
}
