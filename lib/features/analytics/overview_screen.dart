import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/app_state.dart';
import '../../core/design.dart';
import '../transactions/expense.dart';
import '../transactions/expense_tile.dart';
import 'charts.dart';

class OverviewScreen extends ConsumerWidget {
  const OverviewScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final now = DateTime.now();
    final month = state.expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .toList();
    final total = month.fold<int>(0, (sum, e) => sum + e.amount);
    final today = state.expenses
        .where((e) => dayKey(e.date) == dayKey(now))
        .fold<int>(0, (sum, e) => sum + e.amount);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
      children: [
        Text(
          context.l.greeting,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          context.l.subtitle,
          style: TextStyle(
            color: context.foreground.withValues(alpha: .6),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF194E42), Color(0xFF102F2C)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l.monthSpend,
                      style: const TextStyle(color: Color(0xFFC0D8CD)),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      DateFormat('MM / yyyy').format(now),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              FittedBox(
                child: Text(
                  context.money(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Container(height: 1, color: Colors.white.withValues(alpha: .12)),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _Metric(
                      label: context.l.today,
                      value: context.money(today),
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: context.l.receipts,
                      value: '${month.length}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => context.push('/capture'),
                icon: const Icon(Icons.document_scanner_outlined),
                label: Text(context.l.scan),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              tooltip: context.l.manual,
              onPressed: () => context.push('/edit'),
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                minimumSize: const Size(54, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
        if (state.expenses.isEmpty)
          EmptyState(
            title: context.l.emptyTitle,
            body: context.l.emptyBody,
            action: TextButton(
              onPressed: () async {
                try {
                  await ref.read(appProvider.notifier).setDemo(true);
                } catch (_) {
                  if (context.mounted) {
                    context.message(context.l.genericError);
                  }
                }
              },
              child: Text(context.l.demoStart),
            ),
          )
        else ...[
          SectionTitle(context.l.thisWeek),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: WeeklyBarChart(
                values: weeklyTotals(state.expenses, weekStart(now)),
              ),
            ),
          ),
          SectionTitle(
            context.l.recent,
            action: TextButton(
              onPressed: () => context.go('/transactions'),
              child: Text(context.l.viewAll),
            ),
          ),
          Card(
            child: Column(
              children: state.expenses
                  .take(5)
                  .map(
                    (e) => ExpenseTile(
                      expense: e,
                      onTap: () => context.push('/detail/${e.id}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield_outlined, size: 14, color: teal),
            const SizedBox(width: 6),
            Text(
              context.l.offline,
              style: const TextStyle(fontSize: 12, color: teal),
            ),
          ],
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFFAAC6BB), fontSize: 12),
      ),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
      ),
    ],
  );
}
