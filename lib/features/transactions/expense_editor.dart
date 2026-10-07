import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_state.dart';
import '../../core/design.dart';
import '../receipts/receipt_parser.dart';
import 'expense.dart';

class EditorInput {
  const EditorInput({
    this.expense,
    this.parsed,
    this.imagePath,
    this.rawText = '',
    this.ocrMilliseconds,
    this.ownsTemporaryImage = false,
  });
  final Expense? expense;
  final ParsedReceipt? parsed;
  final String? imagePath;
  final String rawText;
  final int? ocrMilliseconds;
  final bool ownsTemporaryImage;
}

class ExpenseEditor extends ConsumerStatefulWidget {
  const ExpenseEditor({super.key, this.input = const EditorInput()});
  final EditorInput input;
  @override
  ConsumerState<ExpenseEditor> createState() => _ExpenseEditorState();
}

class _ExpenseEditorState extends ConsumerState<ExpenseEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController merchant, amount, note;
  DateTime? date;
  ExpenseCategory? category;
  bool saving = false, dirty = false, leaving = false;
  @override
  void initState() {
    super.initState();
    final input = widget.input;
    merchant = TextEditingController(
      text: input.expense?.merchant ?? input.parsed?.merchant ?? '',
    );
    amount = TextEditingController(
      text: (input.expense?.amount ?? input.parsed?.amount)?.toString() ?? '',
    );
    note = TextEditingController(text: input.expense?.note ?? '');
    date =
        input.expense?.date ??
        input.parsed?.date ??
        (input.parsed == null ? DateTime.now() : null);
    category = input.expense?.category ?? input.parsed?.category;
    dirty = input.parsed != null;
    for (final controller in [merchant, amount, note]) {
      controller.addListener(() {
        if (!dirty) {
          setState(() => dirty = true);
        }
      });
    }
  }

  @override
  void dispose() {
    merchant.dispose();
    amount.dispose();
    note.dispose();
    if (widget.input.ownsTemporaryImage && widget.input.imagePath != null) {
      File(
        widget.input.imagePath!,
      ).delete().catchError((_) => File(widget.input.imagePath!));
    }
    super.dispose();
  }

  Future<void> leave() async {
    if (saving) {
      return;
    }
    if (dirty) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          title: Text(context.l.discard),
          content: Text(context.l.discardBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: Text(context.l.keep),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialog, true),
              child: Text(context.l.leave),
            ),
          ],
        ),
      );
      if (discard != true) {
        return;
      }
    }
    if (mounted) {
      setState(() => leaving = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  String issueLabel(ParseIssue issue) => switch (issue) {
    ParseIssue.missingAmount => context.l.missingAmount,
    ParseIssue.ambiguousAmount => context.l.ambiguousAmount,
    ParseIssue.missingDate => context.l.missingDate,
    ParseIssue.ambiguousDate => context.l.ambiguousDate,
    ParseIssue.missingMerchant => context.l.missingMerchant,
  };
  Future<void> save() async {
    if (saving || !form.currentState!.validate()) {
      return;
    }
    setState(() => saving = true);
    final controller = ref.read(appProvider.notifier);
    final images = ref
        .read(servicesProvider)
        .images(ref.read(appProvider).demo);
    final existing = widget.input.expense;
    final id = existing?.id ?? const Uuid().v4();
    ({String image, String thumbnail})? stored;
    try {
      if (existing == null && widget.input.imagePath != null) {
        stored = await images.save(widget.input.imagePath!, id);
      }
      final now = DateTime.now();
      final expense = Expense(
        id: id,
        merchant: merchant.text.trim(),
        amount: int.parse(amount.text.trim()),
        date: date!,
        category: category!,
        note: note.text.trim(),
        imagePath: existing?.imagePath ?? stored?.image,
        thumbnailPath: existing?.thumbnailPath ?? stored?.thumbnail,
        rawText: existing?.rawText ?? widget.input.rawText,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      await controller.save(expense, update: existing != null);
      if (mounted) {
        setState(() {
          leaving = true;
          dirty = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pop();
            context.message(context.l.saved);
          }
        });
      }
    } catch (_) {
      // Only remove images when the database does not reference the new record.
      if (stored != null) {
        final persisted = await ref
            .read(servicesProvider)
            .repository(ref.read(appProvider).demo)
            .all();
        if (!persisted.any((e) => e.id == id)) {
          await images.remove([stored.image, stored.thumbnail]);
        }
      }
      if (mounted) {
        setState(() => saving = false);
        context.message(context.l.genericError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final input = widget.input;
    final imagePath = input.imagePath ?? input.expense?.imagePath;
    return PopScope(
      canPop: leaving || (!dirty && !saving),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          leave();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: saving ? null : leave,
          ),
          title: Text(
            input.expense != null
                ? context.l.edit
                : input.parsed != null
                ? context.l.review
                : context.l.manual,
          ),
        ),
        body: Form(
          key: form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (imagePath != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(imagePath),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 60,
                      child: Icon(Icons.receipt_long),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(context.l.reviewHint, style: const TextStyle(height: 1.5)),
                if (input.ocrMilliseconds != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      'OCR · ${input.ocrMilliseconds} ms',
                      style: const TextStyle(color: teal, fontSize: 12),
                    ),
                  ),
                if (input.parsed?.issues.isNotEmpty == true)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: input.parsed!.issues
                          .map(
                            (issue) => Text(
                              '• ${issueLabel(issue)}',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onTertiaryContainer,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                key: const Key('merchant'),
                controller: merchant,
                enabled: !saving,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: context.l.merchant,
                  prefixIcon: const Icon(Icons.storefront_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? context.l.requiredField
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('amount'),
                controller: amount,
                enabled: !saving,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l.amount,
                  prefixIcon: const Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');
                  return parsed == null || parsed <= 0 || parsed > 999999999999
                      ? context.l.invalidAmount
                      : null;
                },
              ),
              const SizedBox(height: 16),
              FormField<DateTime>(
                validator: (_) => date == null ? context.l.requiredField : null,
                builder: (field) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tileColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerLow,
                      leading: const Icon(Icons.calendar_today_outlined),
                      title: Text(context.l.date),
                      subtitle: Text(
                        date == null
                            ? context.l.chooseDate
                            : DateFormat.yMMMMd(
                                context.l.localeName,
                              ).format(date!),
                      ),
                      trailing: const Icon(Icons.expand_more),
                      onTap: saving
                          ? null
                          : () async {
                              final result = await showDatePicker(
                                context: context,
                                initialDate: date ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100, 12, 31),
                              );
                              if (result != null) {
                                setState(() {
                                  date = result;
                                  dirty = true;
                                });
                                field.didChange(result);
                              }
                            },
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8, left: 16),
                        child: Text(
                          field.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ExpenseCategory>(
                key: const Key('category'),
                initialValue: category,
                decoration: InputDecoration(
                  labelText: context.l.category,
                  prefixIcon: const Icon(Icons.category_outlined),
                ),
                hint: Text(context.l.chooseCategory),
                items: ExpenseCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(context.categoryName(c)),
                      ),
                    )
                    .toList(),
                onChanged: saving
                    ? null
                    : (value) => setState(() {
                        category = value;
                        dirty = true;
                      }),
                validator: (value) =>
                    value == null ? context.l.requiredField : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: note,
                enabled: !saving,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: context.l.note,
                  alignLabelWithHint: true,
                ),
              ),
              if (input.rawText.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: ExpansionTile(
                    title: Text(context.l.rawText),
                    children: [SelectableText(input.rawText)],
                  ),
                ),
              const SizedBox(height: 28),
              FilledButton.icon(
                key: const Key('save'),
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(context.l.save),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
