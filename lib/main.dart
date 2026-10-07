import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/app_state.dart';
import 'core/design.dart';
import 'l10n/app_localizations.dart';
import 'features/analytics/overview_screen.dart';
import 'features/analytics/analytics_screen.dart';
import 'features/capture/capture_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/transactions/transactions_screen.dart';
import 'features/transactions/expense_editor.dart';
import 'features/transactions/expense_detail.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final root = await getApplicationSupportDirectory();
    final preferences = await SharedPreferences.getInstance();
    final services = await AppServices.open(root, preferences);
    final temporary = Directory(
      '${(await getTemporaryDirectory()).path}/receiptflow_scans',
    );
    if (await temporary.exists()) {
      await temporary.delete(recursive: true);
    }
    runApp(
      ProviderScope(
        overrides: [servicesProvider.overrideWithValue(services)],
        child: const ReceiptFlowApp(),
      ),
    );
  } catch (_) {
    runApp(
      MaterialApp(
        theme: appTheme(Brightness.light),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.storage_rounded, size: 48),
                  const SizedBox(height: 20),
                  const Text(
                    'Không mở được dữ liệu / Unable to open local data',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: main,
                    child: const Text('Thử lại / Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            _AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const OverviewScreen()),
          GoRoute(
            path: '/transactions',
            builder: (_, _) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (_, _) => const AnalyticsScreen(),
          ),
          GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        ],
      ),
      GoRoute(path: '/capture', builder: (_, _) => const CaptureScreen()),
      GoRoute(
        path: '/edit',
        builder: (_, state) => ExpenseEditor(
          input: state.extra as EditorInput? ?? const EditorInput(),
        ),
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (_, state) => ExpenseDetail(id: state.pathParameters['id']!),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

class ReceiptFlowApp extends ConsumerWidget {
  const ReceiptFlowApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    return MaterialApp.router(
      title: 'ReceiptFlow',
      debugShowCheckedModeBanner: false,
      theme: appTheme(Brightness.light),
      darkTheme: appTheme(Brightness.dark),
      themeMode: state.theme,
      locale: Locale(state.locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

class _AppShell extends ConsumerWidget {
  const _AppShell({required this.child, required this.location});
  final Widget child;
  final String location;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const paths = ['/', '/transactions', '/analytics', '/settings'];
    final state = ref.watch(appProvider);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 76,
        titleSpacing: 22,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: teal,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Colors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'ReceiptFlow',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                letterSpacing: -.7,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 22),
            child: Icon(
              Icons.offline_bolt_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            if (state.demo)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 7),
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Text(
                  context.l.demoBanner,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
      floatingActionButton: location == '/transactions'
          ? FloatingActionButton(
              onPressed: () => context.push('/edit'),
              tooltip: context.l.manual,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: paths.indexOf(location).clamp(0, 3),
        onDestinationSelected: (index) => context.go(paths[index]),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.space_dashboard_outlined),
            selectedIcon: const Icon(Icons.space_dashboard_rounded),
            label: context.l.overview,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long_rounded),
            label: context.l.transactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.donut_large_outlined),
            selectedIcon: const Icon(Icons.donut_small_rounded),
            label: context.l.analytics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.tune_rounded),
            label: context.l.settings,
          ),
        ],
      ),
    );
  }
}
