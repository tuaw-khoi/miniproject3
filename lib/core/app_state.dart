import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import '../features/transactions/expense.dart';
import '../features/transactions/transaction_repository.dart';
import '../features/receipts/receipt_image_store.dart';

class AppServices {
  AppServices(
    this.root,
    this.preferences,
    this.personal,
    this.demo,
    this.initial,
  );
  final Directory root;
  final SharedPreferences preferences;
  final TransactionRepository personal, demo;
  final List<Expense> initial;
  TransactionRepository repository(bool isDemo) => isDemo ? demo : personal;
  ReceiptImageStore images(bool isDemo) => ReceiptImageStore(
    Directory(p.join(root.path, isDemo ? 'demo_receipts' : 'receipts')),
  );
  static Future<AppServices> open(
    Directory root,
    SharedPreferences preferences,
  ) async {
    await root.create(recursive: true);
    final personal = await TransactionRepository.open(
      p.join(root.path, 'receiptflow.db'),
    );
    final demo = await TransactionRepository.open(p.join(root.path, 'demo.db'));
    if (!preferences.getKeys().contains('demo_seeded')) {
      if ((await demo.all()).isEmpty) {
        final now = DateTime.now();
        final samples = [
          ('The Coffee House', 59000, ExpenseCategory.food, 0),
          ('Nhà sách Phương Nam', 185000, ExpenseCategory.study, 1),
          ('Grab Bike', 32000, ExpenseCategory.travel, 1),
          ('WinMart', 247000, ExpenseCategory.food, 2),
          ('CGV Cinema', 95000, ExpenseCategory.entertainment, 3),
          ('Phụ kiện Anker', 350000, ExpenseCategory.gear, 4),
          ('Bún bò Huế', 45000, ExpenseCategory.food, 5),
          ('Highlands Coffee', 49000, ExpenseCategory.food, 6),
          ('Văn phòng phẩm', 68000, ExpenseCategory.study, 8),
          ('Grab Bike', 28000, ExpenseCategory.travel, 9),
          ('Co.opmart', 320000, ExpenseCategory.food, 11),
          ('CGV Cinema', 110000, ExpenseCategory.entertainment, 14),
        ];
        for (var i = 0; i < samples.length; i++) {
          final s = samples[i];
          await demo.save(
            Expense(
              id: 'sample-$i',
              merchant: s.$1,
              amount: s.$2,
              date: DateTime(now.year, now.month, now.day - s.$4),
              category: s.$3,
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      }
      await preferences.setBool('demo_seeded', true);
    }
    final initial =
        await (preferences.getBool('demo') == true ? demo : personal).all();
    final services = AppServices(root, preferences, personal, demo, initial);
    for (final isDemo in [false, true]) {
      final expenses = await services.repository(isDemo).all();
      await services
          .images(isDemo)
          .prune(
            expenses
                .expand((e) => [e.imagePath, e.thumbnailPath])
                .whereType<String>()
                .toSet(),
          );
    }
    return services;
  }
}

final servicesProvider = Provider<AppServices>(
  (ref) => throw UnimplementedError('Override at startup'),
);

class AppState {
  const AppState({
    required this.expenses,
    this.locale = 'vi',
    this.theme = ThemeMode.system,
    this.demo = false,
  });
  final List<Expense> expenses;
  final String locale;
  final ThemeMode theme;
  final bool demo;
  AppState copyWith({
    List<Expense>? expenses,
    String? locale,
    ThemeMode? theme,
    bool? demo,
  }) => AppState(
    expenses: expenses ?? this.expenses,
    locale: locale ?? this.locale,
    theme: theme ?? this.theme,
    demo: demo ?? this.demo,
  );
}

class AppController extends Notifier<AppState> {
  AppServices get services => ref.read(servicesProvider);
  @override
  AppState build() {
    final s = ref.watch(servicesProvider);
    return AppState(
      expenses: s.initial,
      locale: s.preferences.getString('locale') ?? 'vi',
      demo: s.preferences.getBool('demo') ?? false,
      theme: ThemeMode.values.byName(
        s.preferences.getString('theme') ?? 'system',
      ),
    );
  }

  Future<void> setLocale(String value) async {
    await services.preferences.setString('locale', value);
    state = state.copyWith(locale: value);
  }

  Future<void> setTheme(ThemeMode value) async {
    await services.preferences.setString('theme', value.name);
    state = state.copyWith(theme: value);
  }

  Future<void> setDemo(bool value) async {
    final data = await services.repository(value).all();
    await services.preferences.setBool('demo', value);
    state = state.copyWith(demo: value, expenses: data);
  }

  Future<void> refresh() async {
    state = state.copyWith(
      expenses: await services.repository(state.demo).all(),
    );
  }

  Future<void> save(Expense expense, {bool update = false}) async {
    await services.repository(state.demo).save(expense, update: update);
    final updated =
        [...state.expenses.where((e) => e.id != expense.id), expense]
          ..sort((a, b) {
            final day = b.date.compareTo(a.date);
            return day != 0 ? day : b.createdAt.compareTo(a.createdAt);
          });
    state = state.copyWith(expenses: updated);
  }

  Future<void> delete(Expense expense) async {
    await services.repository(state.demo).delete(expense.id);
    state = state.copyWith(
      expenses: state.expenses.where((e) => e.id != expense.id).toList(),
    );
    // If file cleanup fails, startup pruning retries without resurrecting the row.
    try {
      await services.images(state.demo).remove([
        expense.imagePath,
        expense.thumbnailPath,
      ]);
    } on FileSystemException {
      /* retry on next launch */
    }
  }
}

final appProvider = NotifierProvider<AppController, AppState>(
  AppController.new,
);
