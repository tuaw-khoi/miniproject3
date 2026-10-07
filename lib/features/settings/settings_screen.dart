import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_state.dart';
import '../../core/design.dart';
import '../transactions/transactions_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  Future<void> perform(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (_) {
      if (context.mounted) {
        context.message(context.l.genericError);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider),
        controller = ref.read(appProvider.notifier);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
      children: [
        Text(
          context.l.settings,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 26),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.language_rounded, color: teal),
                    const SizedBox(width: 12),
                    Text(
                      context.l.language,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
                    ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {state.locale},
                  onSelectionChanged: (set) =>
                      perform(context, () => controller.setLocale(set.first)),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Icon(Icons.palette_outlined, color: teal),
                    const SizedBox(width: 12),
                    Text(
                      context.l.appearance,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ThemeMode>(
                  initialValue: state.theme,
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(context.l.system),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(context.l.light),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(context.l.dark),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      perform(context, () => controller.setTheme(v));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.science_outlined, color: teal),
                title: Text(context.l.demo),
                subtitle: Text(context.l.demoHint),
                value: state.demo,
                onChanged: (value) =>
                    perform(context, () => controller.setDemo(value)),
              ),
              const Divider(indent: 20, endIndent: 20, height: 1),
              ListTile(
                leading: const Icon(Icons.ios_share_rounded, color: teal),
                title: Text(context.l.export),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => exportExpenses(context, state.expenses),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: teal.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined, color: teal, size: 30),
              const SizedBox(height: 14),
              Text(
                context.l.privacy,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(context.l.privacyBody, style: const TextStyle(height: 1.6)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l.about),
          subtitle: Text(
            context.l.aboutBody,
            style: const TextStyle(height: 1.5),
          ),
          onTap: () => showLicensePage(
            context: context,
            applicationName: 'ReceiptFlow',
            applicationVersion: '1.0.0',
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'RECEIPTFLOW / 1.0.0',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, letterSpacing: 2, color: teal),
        ),
      ],
    );
  }
}
