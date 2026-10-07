import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../features/transactions/expense.dart';

const ink = Color(0xFF163B36);
const teal = Color(0xFF147D68);
const categoryColors = [
  Color(0xFF238C73),
  Color(0xFF6B7FDA),
  Color(0xFFDEAD50),
  Color(0xFFE58770),
  Color(0xFFAD83BC),
];
const categoryIcons = [
  Icons.restaurant_rounded,
  Icons.auto_stories_rounded,
  Icons.directions_bus_rounded,
  Icons.headphones_rounded,
  Icons.movie_rounded,
];

extension UiContext on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this)!;
  String money(num amount) =>
      '${NumberFormat.decimalPattern(l.localeName).format(amount)} ₫';
  String categoryName(ExpenseCategory c) =>
      [l.food, l.study, l.travel, l.gear, l.entertainment][c.index];
  Color get foreground => Theme.of(this).colorScheme.onSurface;
  void message(String text) => ScaffoldMessenger.of(this).showSnackBar(
    SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
  );
}

ThemeData appTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: teal, brightness: brightness);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: dark
        ? const Color(0xFF111D1B)
        : const Color(0xFFF5F6F1),
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? const Color(0xFF111D1B) : const Color(0xFFF5F6F1),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: dark ? const Color(0xFF1B2D29) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
      ),
      headlineSmall: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        letterSpacing: -.6,
      ),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF1B2D29) : Colors.white,
      indicatorColor: dark ? teal : const Color(0xFFDDEEE5),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action});
  final String title;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 14),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        ?action,
      ],
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.body,
    this.action,
  });
  final String title, body;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: teal.withValues(alpha: .1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.receipt_long_rounded, size: 46, color: teal),
        ),
        const SizedBox(height: 22),
        Text(
          title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.foreground.withValues(alpha: .65),
            height: 1.5,
          ),
        ),
        if (action != null)
          Padding(padding: const EdgeInsets.only(top: 20), child: action),
      ],
    ),
  );
}
