import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/app_state.dart';
import '../../core/design.dart';
import 'expense_editor.dart';

class ExpenseDetail extends ConsumerStatefulWidget {
  const ExpenseDetail({super.key, required this.id});
  final String id;
  @override
  ConsumerState<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends ConsumerState<ExpenseDetail> {
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    final expense = ref
        .watch(appProvider)
        .expenses
        .where((e) => e.id == widget.id)
        .firstOrNull;
    if (expense == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l.noResults)),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l.receipts),
        actions: [
          IconButton(
            tooltip: context.l.edit,
            onPressed: deleting
                ? null
                : () => context.push(
                    '/edit',
                    extra: EditorInput(expense: expense),
                  ),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: categoryColors[expense.category.index].withValues(
                  alpha: .15,
                ),
              ),
              child: Icon(
                categoryIcons[expense.category.index],
                color: categoryColors[expense.category.index],
                size: 36,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            context.money(expense.amount),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 8),
          Text(
            expense.merchant,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                spacing: 15,
                children: [
                  _Row(
                    context.l.date,
                    DateFormat.yMMMMd(
                      context.l.localeName,
                    ).format(expense.date),
                  ),
                  _Row(
                    context.l.category,
                    context.categoryName(expense.category),
                  ),
                  if (expense.note.isNotEmpty)
                    _Row(context.l.note, expense.note),
                ],
              ),
            ),
          ),
          SectionTitle(context.l.receiptImage),
          if (expense.imagePath == null)
            Text(context.l.noReceipt)
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(
                File(expense.imagePath!),
                fit: BoxFit.fitWidth,
                errorBuilder: (_, _, _) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(context.l.genericError),
                ),
              ),
            ),
          if (expense.rawText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                child: ExpansionTile(
                  title: Text(context.l.rawText),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(expense.rawText),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: deleting
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialog) => AlertDialog(
                        title: Text(context.l.confirmDelete),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialog, false),
                            child: Text(context.l.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialog, true),
                            child: Text(context.l.delete),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !mounted) {
                      return;
                    }
                    setState(() => deleting = true);
                    try {
                      await ref.read(appProvider.notifier).delete(expense);
                      if (context.mounted) {
                        context.pop();
                        context.message(context.l.deleted);
                      }
                    } catch (_) {
                      if (mounted) {
                        setState(() => deleting = false);
                        if (context.mounted) {
                          context.message(context.l.genericError);
                        }
                      }
                    }
                  },
            icon: const Icon(Icons.delete_outline),
            label: Text(context.l.delete),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(color: context.foreground.withValues(alpha: .6)),
        ),
      ),
      const SizedBox(width: 12),
      Flexible(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}
