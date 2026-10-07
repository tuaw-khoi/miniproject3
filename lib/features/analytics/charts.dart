import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/design.dart';
import '../transactions/expense.dart';

class DonutChart extends StatefulWidget {
  const DonutChart({super.key, required this.values});
  final Map<ExpenseCategory, int> values;
  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  ExpenseCategory? selected;
  @override
  void didUpdateWidget(DonutChart old) {
    super.didUpdateWidget(old);
    if (ExpenseCategory.values.any((c) => old.values[c] != widget.values[c])) {
      selected = null;
      _animation.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.values.values.fold(0, (a, b) => a + b);
    final value = selected == null ? total : widget.values[selected] ?? 0;
    return Column(
      children: [
        SizedBox(
          height: 230,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapUp: (details) {
                  final center = Offset(constraints.maxWidth / 2, 115);
                  final delta = details.localPosition - center;
                  if (delta.distance < 69 ||
                      delta.distance > 108 ||
                      total == 0) {
                    return;
                  }
                  final angle =
                      (math.atan2(delta.dy, delta.dx) +
                          math.pi / 2 +
                          math.pi * 2) %
                      (math.pi * 2);
                  var cursor = 0.0;
                  for (final category in ExpenseCategory.values) {
                    cursor +=
                        (widget.values[category] ?? 0) / total * math.pi * 2;
                    if (angle <= cursor) {
                      setState(() => selected = category);
                      break;
                    }
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: AnimatedBuilder(
                        animation: _animation,
                        builder: (_, _) => CustomPaint(
                          painter: DonutPainter(
                            values: widget.values,
                            progress: MediaQuery.disableAnimationsOf(context)
                                ? 1
                                : Curves.easeOutCubic.transform(
                                    _animation.value,
                                  ),
                            selected: selected,
                            emptyColor: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: SizedBox(
                        width: 145,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selected == null
                                  ? context.l.total
                                  : context.categoryName(selected!),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: context.foreground.withValues(alpha: .6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                context.money(value),
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (selected != null && total > 0)
                              Text(
                                '${(value * 100 / total).toStringAsFixed(1)}%',
                                style: const TextStyle(color: teal),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (total == 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(context.l.noChart),
          ),
        ...ExpenseCategory.values.map((category) {
          final amount = widget.values[category] ?? 0;
          return Semantics(
            selected: selected == category,
            button: true,
            label:
                '${context.categoryName(category)}, ${context.money(amount)}',
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(
                () => selected = selected == category ? null : category,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: categoryColors[category.index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(context.categoryName(category))),
                    Text(
                      context.money(amount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      width: 45,
                      child: Text(
                        '${total == 0 ? 0 : (amount * 100 / total).round()}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: context.foreground.withValues(alpha: .5),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class DonutPainter extends CustomPainter {
  DonutPainter({
    required this.values,
    required this.progress,
    required this.emptyColor,
    this.selected,
  });
  final Map<ExpenseCategory, int> values;
  final double progress;
  final Color emptyColor;
  final ExpenseCategory? selected;
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final total = values.values.fold(0, (a, b) => a + b);
    final radius = math.min(size.width / 2 - 12, 92.0);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 25
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius, paint..color = emptyColor);
    var start = -math.pi / 2;
    if (total > 0) {
      final count = values.values.where((v) => v > 0).length;
      for (final category in ExpenseCategory.values) {
        final sweep = (values[category] ?? 0) / total * math.pi * 2 * progress;
        final gap = count <= 1 ? 0.0 : math.min(.035, sweep * .15);
        paint
          ..color = categoryColors[category.index].withValues(
            alpha: selected == null || selected == category ? 1 : .3,
          )
          ..strokeWidth = selected == category ? 31 : 25;
        if (sweep > 0) {
          canvas.drawArc(rect, start + gap / 2, sweep - gap, false, paint);
        }
        start += sweep;
      }
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) =>
      old.values != values ||
      old.progress != progress ||
      old.selected != selected ||
      old.emptyColor != emptyColor;
}

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({super.key, required this.values});
  final List<int> values;
  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> {
  int? selected;
  @override
  Widget build(BuildContext context) {
    final labels = [
      context.l.mon,
      context.l.tue,
      context.l.wed,
      context.l.thu,
      context.l.fri,
      context.l.sat,
      context.l.sun,
    ];
    return Column(
      children: [
        SizedBox(
          height: 28,
          child: Text(
            selected == null
                ? context.money(widget.values.fold<int>(0, (a, b) => a + b))
                : '${labels[selected!]} · ${context.money(widget.values[selected!])}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
        ),
        SizedBox(
          height: 185,
          child: LayoutBuilder(
            builder: (_, box) => GestureDetector(
              onTapUp: (details) {
                setState(
                  () =>
                      selected = ((details.localPosition.dx / box.maxWidth) * 7)
                          .floor()
                          .clamp(0, 6),
                );
              },
              child: TweenAnimationBuilder<double>(
                key: ValueKey(widget.values.join(',')),
                tween: Tween(begin: 0, end: 1),
                duration: Duration(
                  milliseconds: MediaQuery.disableAnimationsOf(context)
                      ? 0
                      : 650,
                ),
                curve: Curves.easeOutCubic,
                builder: (_, value, _) => CustomPaint(
                  size: Size(box.maxWidth, 185),
                  painter: BarPainter(
                    values: widget.values,
                    progress: value,
                    selected: selected,
                    grid: context.foreground.withValues(alpha: .07),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
        Row(
          children: List.generate(
            7,
            (i) => Expanded(
              child: Semantics(
                button: true,
                selected: selected == i,
                label: '${labels[i]}, ${context.money(widget.values[i])}',
                child: InkWell(
                  onTap: () => setState(() => selected = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BarPainter extends CustomPainter {
  BarPainter({
    required this.values,
    required this.progress,
    required this.grid,
    required this.color,
    this.selected,
  });
  final List<int> values;
  final double progress;
  final int? selected;
  final Color grid, color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = 10 + (size.height - 12) * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final maxValue = math.max(1, values.reduce(math.max));
    final slot = size.width / 7;
    for (var i = 0; i < 7; i++) {
      final height = math.max(
        3.0,
        values[i] / maxValue * (size.height - 20) * progress,
      );
      final rect = Rect.fromLTWH(
        slot * i + slot * .22,
        size.height - height,
        slot * .56,
        height,
      );
      paint.color = color.withValues(
        alpha: selected == null || selected == i ? 1 : .25,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(7)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(BarPainter old) =>
      old.values != values ||
      old.progress != progress ||
      old.selected != selected ||
      old.color != color ||
      old.grid != grid;
}
