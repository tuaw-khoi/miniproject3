import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/app_state.dart';
import '../../core/design.dart';
import 'expense.dart';
import 'expense_tile.dart';

Future<void> exportExpenses(
  BuildContext context,
  List<Expense> expenses,
) async {
  if (expenses.isEmpty) {
    context.message(context.l.exportEmpty);
    return;
  }
  try {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/receiptflow-${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(expensesCsv(expenses));
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], title: 'ReceiptFlow CSV'),
    );
  } catch (_) {
    if (context.mounted) {
      context.message(context.l.genericError);
    }
  }
}

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});
  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final search = TextEditingController();
  ExpenseCategory? category;
  DateTimeRange? range;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = filterExpenses(
      ref.watch(appProvider).expenses,
      query: search.text,
      category: category,
      start: range?.start,
      end: range?.end,
    );
    final groups = <String, List<Expense>>{};
    for (final e in items) {
      groups.putIfAbsent(dayKey(e.date), () => []).add(e);
    }
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
          sliver: SliverList.list(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l.transactions,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l.export,
                    onPressed: () => exportExpenses(context, items),
                    icon: const Icon(Icons.ios_share_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              TextField(
                controller: search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: context.l.search,
                  prefixIcon: const Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(context.l.all),
                      selected: category == null,
                      onSelected: (_) => setState(() => category = null),
                    ),
                    ...ExpenseCategory.values.map(
                      (c) => ChoiceChip(
                        label: Text(context.categoryName(c)),
                        selected: category == c,
                        onSelected: (_) => setState(() => category = c),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final selected = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        initialDateRange: range,
                      );
                      if (selected != null) {
                        setState(() => range = selected);
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined, size: 16),
                    label: Text(
                      range == null
                          ? context.l.dateRange
                          : '${DateFormat('dd/MM').format(range!.start)} – ${DateFormat('dd/MM').format(range!.end)}',
                    ),
                  ),
                  if (range != null ||
                      category != null ||
                      search.text.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() {
                        range = null;
                        category = null;
                        search.clear();
                      }),
                      child: Text(context.l.clear),
                    ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${items.length} ${context.l.receipts.toLowerCase()}',
                      style: TextStyle(
                        color: context.foreground.withValues(alpha: .6),
                      ),
                    ),
                  ),
                  Text(
                    context.money(items.fold<int>(0, (s, e) => s + e.amount)),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: EmptyState(
              title: context.l.noResults,
              body: context.l.emptyBody,
              action: FilledButton.icon(
                onPressed: () => context.push('/edit'),
                icon: const Icon(Icons.add),
                label: Text(context.l.manual),
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          sliver: SliverList.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final entry = groups.entries.elementAt(index);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      DateFormat.yMMMMd(
                        context.l.localeName,
                      ).format(DateTime.parse(entry.key)),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Card(
                    child: Column(
                      children: entry.value
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
              );
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 110)),
      ],
    );
  }
}
