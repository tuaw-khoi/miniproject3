import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/app_state.dart';
import '../../core/design.dart';
import '../transactions/expense.dart';
import 'charts.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime week = weekStart(DateTime.now());
  @override
  Widget build(BuildContext context) {
    final items = ref.watch(appProvider).expenses;
    final selected = items
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 105),
      children: [
        Text(
          context.l.analytics,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(context.l.insightHint),
        SectionTitle(context.l.distribution),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _Period(
                  label: DateFormat.yMMMM(context.l.localeName).format(month),
                  previous: () => setState(
                    () => month = DateTime(month.year, month.month - 1),
                  ),
                  next: () => setState(
                    () => month = DateTime(month.year, month.month + 1),
                  ),
                ),
                DonutChart(values: categoryTotals(selected)),
              ],
            ),
          ),
        ),
        SectionTitle(context.l.thisWeek),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                _Period(
                  label:
                      '${DateFormat('dd/MM').format(week)} – ${DateFormat('dd/MM/yyyy').format(DateTime(week.year, week.month, week.day + 6))}',
                  previous: () => setState(
                    () => week = DateTime(week.year, week.month, week.day - 7),
                  ),
                  next: () => setState(
                    () => week = DateTime(week.year, week.month, week.day + 7),
                  ),
                ),
                const SizedBox(height: 16),
                WeeklyBarChart(values: weeklyTotals(items, week)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Period extends StatelessWidget {
  const _Period({
    required this.label,
    required this.previous,
    required this.next,
  });
  final String label;
  final VoidCallback previous, next;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: context.l.previous,
        onPressed: previous,
        icon: const Icon(Icons.chevron_left),
      ),
      Expanded(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      IconButton(
        tooltip: context.l.next,
        onPressed: next,
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}
