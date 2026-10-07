import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/design.dart';
import 'expense.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, required this.onTap});
  final Expense expense;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    onTap: onTap,
    leading: Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: categoryColors[expense.category.index].withValues(alpha: .12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: expense.thumbnailPath == null
          ? Icon(
              categoryIcons[expense.category.index],
              color: categoryColors[expense.category.index],
            )
          : Image.file(
              File(expense.thumbnailPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.receipt_long_outlined),
            ),
    ),
    title: Text(
      expense.merchant,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    subtitle: Text(
      '${context.categoryName(expense.category)} · ${DateFormat('dd/MM').format(expense.date)}',
      style: const TextStyle(fontSize: 12),
    ),
    trailing: Text(
      context.money(expense.amount),
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
    ),
  );
}
